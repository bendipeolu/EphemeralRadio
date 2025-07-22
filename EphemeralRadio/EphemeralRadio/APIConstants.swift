//
//  APIConstants.swift
//  EphemeralRadio
//
//  Created by Benjamin Dipeolu on 21/07/2025.
//

import Foundation

enum APIConstants {
    static let apiHost = "api.spotify.com"
    static let authHost = "accounts.spotify.com"
    static let clientID = "2eb4e1c7d53c46f6bf423bbfd3b57314"
    static let clientSecret = "0ef8f7a4d85541499abae224ee9b9456"
    static let redirectUri = "ephemeralradio://callback"
    static let responseType = "code"
    static let scopes = "user-read-currently-playing user-read-playback-state user-modify-playback-state"
    
    static var authParams = [
        "response_type": responseType,
        "client_id": clientID,
        "redirect_uri": redirectUri,
        "scope": scopes
    ]
}
