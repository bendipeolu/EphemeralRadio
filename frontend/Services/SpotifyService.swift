class SpotifyService: ObservableObject {
    func getCurrentTrack(token: String, completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let item = json["item"] as? [String: Any],
                  let id = item["id"] as? String
            else {
                completion(nil)
                return
            }
            completion(id)
        }.resume()
    }
}
