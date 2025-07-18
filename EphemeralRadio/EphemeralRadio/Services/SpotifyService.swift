import Foundation
import Combine
import SwiftUI

class SpotifyAuthService: ObservableObject {
    static let shared = SpotifyAuthService()
    
    @Published var accessToken: String? = nil
    @Published var isLoggedIn = false

    private let clientID = getSecret("SPOTIFY_CLIENT_ID")
    private let clientSecret = getSecret("SPOTIFY_CLIENT_SECRET")
    private let redirectURI = "ephemeralradio://callback"
    private let scopes = "user-read-playback-state user-read-currently-playing"
    
    func startLogin() {
        let authURL =
        "https://accounts.spotify.com/authorize" +
        "?client_id=\(clientID)" +
        "&response_type=code" +
        "&redirect_uri=\(redirectURI)" +
        "&scope=\(scopes)" +
        "&show_dialog=true"

        if let url = URL(string: authURL) {
            UIApplication.shared.open(url)
        }
    }

    func handleRedirectURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("❌ No code in redirect URL")
            return
        }

        requestAccessToken(using: code)
    }

    private func requestAccessToken(using code: String) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let bodyParams = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "client_secret": clientSecret,
        ]
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, res, err in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["access_token"] as? String {
                DispatchQueue.main.async {
                    self.accessToken = token
                    self.isLoggedIn = true
                    print("✅ ACCESS TOKEN: \(token)")
                }
            } else {
                print("❌ Failed to get token: \(String(data: data ?? Data(), encoding: .utf8) ?? "")")
            }
        }.resume()
    }
}
