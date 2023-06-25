//
//  UserDefaultStorage.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation

/// A simple user default storage functionality.
final class UserDefaultStorage<Storage: Storable> {
    
    let suiteName: String?
    let key: String
    
    var value: Storage? {
        get {
            let data = UserDefaults(suiteName: suiteName)?.data(forKey: key)
            guard let data,
                  let storage = try? JSONDecoder().decode(Storage.self, from: data) else {
                return nil
            }
            return storage
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("☠️ could not write \(key) to \(suiteName ?? "default")")
                return
            }
            UserDefaults(suiteName: suiteName)?.set(data, forKey: key)
        }
    }
    
    init(key: String, storage: String? = nil) {
        self.key = key
        self.suiteName = storage
    }
}
