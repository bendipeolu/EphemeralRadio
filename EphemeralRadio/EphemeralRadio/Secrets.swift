//
//  Secrets.swift
//  EphemeralRadio
//
//  Created by Benjamin Dipeolu on 18/07/2025.
//

import Foundation

func getSecret(_ key: String) -> String {
    guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
          let dict = NSDictionary(contentsOfFile: path),
          let value = dict[key] as? String else {
        fatalError("Missing or invalid key '\(key)' in Secrets.plist")
    }
    return value
}
