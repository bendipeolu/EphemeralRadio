//
//  EphemeralRadioApp.swift
//  EphemeralRadio
//
//  Created by Benjamin Dipeolu on 21/07/2025.
//

import SwiftUI

@main
struct EphemeralRadioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    APIService.shared.handleRedirectURL(url)
                }
        }
    }
}
