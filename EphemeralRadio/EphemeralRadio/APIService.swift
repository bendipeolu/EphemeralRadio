import Foundation
import UIKit


class APIService: ObservableObject {
    static let shared = APIService()
    
    @Published var accessToken: String? {
        didSet {
            if let token = accessToken {
                UserDefaults.standard.set(token, forKey: "SpotifyAccessToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "SpotifyAccessToken")
            }
        }
    }
    
    private var refreshToken: String? {
        get {
            UserDefaults.standard.string(forKey: "SpotifyRefreshToken")
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: "SpotifyRefreshToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "SpotifyRefreshToken")
            }
        }
    }
    
    @Published var isLoggedIn = false
    
    private var timer: Timer?
       @Published var currentTrack: Track?

       // Call this after login succeeds
       func startPollingCurrentTrack() {
           stopPolling()
           timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
               self.fetchCurrentlyPlaying()
           }
           print("🕒 Started polling current track")
       }

       func stopPolling() {
           timer?.invalidate()
           timer = nil
           print("🛑 Stopped polling")
       }

    private func fetchCurrentlyPlaying(market: String? = nil) {
        guard let accessToken = accessToken else {
            print("❌ No access token available")
            return
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spotify.com"
        components.path = "/v1/me/player/currently-playing"
        components.queryItems = [URLQueryItem(name: "additional_types", value: "track,episode")]

        if let market = market {
            components.queryItems?.append(URLQueryItem(name: "market", value: market))
        }

        guard let url = components.url else {
            print("❌ Failed to build URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }

            if httpResponse.statusCode == 204 {
                print("📭 No content — nothing is currently playing")
                return
            }

            guard let data = data else {
                print("❌ No response body")
                return
            }

            do {
                let track = try JSONDecoder().decode(CurrentlyPlayingResponse.self, from: data)
                print("🎶 Now playing: \(track.item.name) by \(track.item.artists.map { $0.name }.joined(separator: ", "))")

                DispatchQueue.main.async {
                    self.currentTrack = track.item
                    self.sendTrackDataToBackend(track: track.item)
                }
            } catch {
                print("❌ JSON decode failed: \(error)")
            }
        }.resume()
    }

    private func sendTrackDataToBackend(track: Track) {
        guard let url = URL(string: "http://localhost:8080/track") else {
            print("❌ Invalid backend URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "track_name": track.name,
            "artist_name": track.artists.first?.name ?? "Unknown",
            "album_name": track.album.name,
            "duration_ms": track.durationMs,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
            // Add more fields here, including geolocation if available
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("❌ Failed to encode JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to send track to backend: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Sent track to backend: HTTP \(httpResponse.statusCode)")
            }
        }.resume()
    }


    
    func getAccessToken() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIConstants.authHost
        components.path = "/authorize"
        
        components.queryItems = APIConstants.authParams.map({URLQueryItem(name: $0, value: $1)})
        
        print("🔗 \(components.url!)")
        
        if let url = components.url {
            UIApplication.shared.open(url)
        }
    }
    
    func handleRedirectURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("❌ No code in redirect URL")
            return
        }

        print("🔹 Code:\(code)")
        requestAccessToken(using: code)
    }
    
    private func requestAccessToken(using code: String) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let bodyParams = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": APIConstants.redirectUri
        ]
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        let authString = "\(APIConstants.clientID):\(APIConstants.clientSecret)"
        let authData = authString.data(using: .utf8)!
        let authHeader = "Basic \(authData.base64EncodedString())"

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                print("❌ No response data from token request")
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("🔁 TOKEN RESPONSE: \(json)")
                DispatchQueue.main.async {
                    if let token = json["access_token"] as? String {
                        self.accessToken = token
                        self.isLoggedIn = true
                        print("✅ ACCESS TOKEN: \(token)")
                        APIService.shared.startPollingCurrentTrack()

                    }
                    if let refresh = json["refresh_token"] as? String {
                        self.refreshToken = refresh
                        print("🔁 REFRESH TOKEN saved")
                    }
                }
            } else {
                print("❌ Failed to get token: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }.resume()
    }
    
}

struct CurrentlyPlayingResponse: Codable {
    let item: Track
    let isPlaying: Bool
    let progressMs: Int?
    let timestamp: Int
    let currentlyPlayingType: String

    enum CodingKeys: String, CodingKey {
        case item
        case isPlaying = "is_playing"
        case progressMs = "progress_ms"
        case timestamp
        case currentlyPlayingType = "currently_playing_type"
    }
}

struct Track: Codable {
    let name: String
    let artists: [Artist]
    let album: Album
    let durationMs: Int

    enum CodingKeys: String, CodingKey {
        case name, artists, album
        case durationMs = "duration_ms"
    }
}

struct Artist: Codable {
    let name: String
}

struct Album: Codable {
    let name: String
    let images: [SpotifyImage]
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}
