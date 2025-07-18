struct MainView: View {
    @StateObject var spotify = SpotifyService()
    @StateObject var reporter = TrackReporter()

    var body: some View {
        Button("Share my current track") {
            // Get token and location first
            let token = "user-access-token"
            let lat = 53.3498
            let lon = -6.2603

            spotify.getCurrentTrack(token: token) { trackID in
                if let id = trackID {
                    reporter.reportTrack(trackID: id, lat: lat, lon: lon)
                }
            }
        }
    }
}
