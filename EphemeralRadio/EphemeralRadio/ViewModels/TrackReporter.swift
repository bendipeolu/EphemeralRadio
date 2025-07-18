import Foundation
import SwiftUI

class TrackReporter: ObservableObject {
    func reportTrack(trackID: String, lat: Double, lon: Double) {
        let payload: [String: Any] = [
            "user_id": UUID().uuidString,
            "track_id": trackID,
            "latitude": lat,
            "longitude": lon
        ]

        guard let url = URL(string: "http://localhost:8080/api/track") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Error serializing JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request).resume()
    }
}
