//
//  ContentView.swift
//  EphemeralRadio
//
//  Created by Benjamin Dipeolu on 18/07/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var authService = SpotifyAuthService.shared

    var body: some View {
        VStack {
            Text("Ephemeral Radio")
                .font(.largeTitle)
                .padding()

            if authService.isLoggedIn {
                Text("🎧 Logged in")
                    .foregroundColor(.green)
            } else {
                Button("Login with Spotify") {
                    authService.startLogin()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
