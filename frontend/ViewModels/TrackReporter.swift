class TrackReporter: ObservableObject {
    func reportTrack(trackID: String, lat: Double, lon: Double) {
        let payload = [
            "user_id": UUID().uuidString,
            "track_id": trackID,
            "latitude": lat,
            "longitude": lon
        ]

        var request = URLRequest(url: URL(string: "http://localhost:8080/api/track")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request).resume()
    }
}
