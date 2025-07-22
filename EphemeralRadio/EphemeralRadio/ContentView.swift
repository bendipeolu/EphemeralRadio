//
//  ContentView.swift
//  EphemeralRadio
//
//  Created by Benjamin Dipeolu on 21/07/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var apiService = APIService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if apiService.isLoggedIn {
                Text("Logged in ✅")

            } else {
                Button("Login with Spotify") {
                    apiService.getAccessToken()
                }
            }
        }
        .padding()
    }
}
