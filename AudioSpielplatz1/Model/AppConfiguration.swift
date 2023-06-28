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
        var projectDirectory: String
        var sessionDirectory: String?
        var sessionId: String?
        var sessionTemplate: String?
        
        var startRecordingVolume: Float
        var endRecordingVolume: Float
        
        enum CodingKeys: CodingKey {
            case projectDirectory
            case sessionDirectory
            case sessionId
            case sessionTemplate
            case startRecordingVolume
            case endRecordingVolume
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<AppConfiguration.Config.CodingKeys> = try decoder.container(keyedBy: AppConfiguration.Config.CodingKeys.self)
            self.projectDirectory = (try? container.decodeIfPresent(String.self, forKey: AppConfiguration.Config.CodingKeys.projectDirectory))
            ?? AppDefaults.documentDirectory
            
            self.sessionDirectory = try? container.decodeIfPresent(String.self, forKey: AppConfiguration.Config.CodingKeys.sessionDirectory)
            self.sessionId = try? container.decodeIfPresent(String.self, forKey: AppConfiguration.Config.CodingKeys.sessionId)
            self.sessionTemplate = try? container.decodeIfPresent(String.self, forKey: AppConfiguration.Config.CodingKeys.sessionTemplate)
            
            self.startRecordingVolume = (try? container.decodeIfPresent(Float.self, forKey: AppConfiguration.Config.CodingKeys.startRecordingVolume)) ?? 1.0
            self.endRecordingVolume = (try? container.decodeIfPresent(Float.self, forKey: AppConfiguration.Config.CodingKeys.endRecordingVolume)) ?? 0.2
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: AppConfiguration.Config.CodingKeys.self)
            try container.encode(self.projectDirectory, forKey: AppConfiguration.Config.CodingKeys.projectDirectory)
            try container.encodeIfPresent(self.sessionDirectory, forKey: AppConfiguration.Config.CodingKeys.sessionDirectory)
            try container.encodeIfPresent(self.sessionId, forKey: AppConfiguration.Config.CodingKeys.sessionId)
            try container.encodeIfPresent(self.sessionTemplate, forKey: AppConfiguration.Config.CodingKeys.sessionTemplate)
            try container.encodeIfPresent(self.startRecordingVolume, forKey: AppConfiguration.Config.CodingKeys.startRecordingVolume)
            try container.encodeIfPresent(self.endRecordingVolume, forKey: AppConfiguration.Config.CodingKeys.endRecordingVolume)
        }
        
        init() {
            projectDirectory = AppDefaults.documentDirectory
            startRecordingVolume = 1.0
            endRecordingVolume = 0.2
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


