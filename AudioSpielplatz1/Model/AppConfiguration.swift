//
//  AppConfiguration.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation

final class AppConfiguration {
    
    static var key = "Config"
    
    struct Config: Storable {
        let projectDirectory: String
        
        enum CodingKeys: CodingKey {
            case projectDirectory
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<AppConfiguration.Config.CodingKeys> = try decoder.container(keyedBy: AppConfiguration.Config.CodingKeys.self)
            self.projectDirectory = (try? container.decodeIfPresent(String.self, forKey: AppConfiguration.Config.CodingKeys.projectDirectory))
                                            ?? AppDefaults.documentDirectory
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: AppConfiguration.Config.CodingKeys.self)
            try container.encode(self.projectDirectory, forKey: AppConfiguration.Config.CodingKeys.projectDirectory)
        }
        
        init() {
            projectDirectory = AppDefaults.documentDirectory
        }
    }
    
    var config: Config {
        get {
            UserDefaultStorage(key: Self.key, storage: AppDefaults.userDefaults).value ?? Config()
        }
        set {
            UserDefaultStorage(key: Self.key, storage: AppDefaults.userDefaults).value = newValue
        }
    }
    
}


