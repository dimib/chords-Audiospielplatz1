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
        
        var splitterOutputDirectory: String?
        var splitterSeconds: Double = 1.0
        var splitterIgnoreLast: Bool = true
        
        enum CodingKeys: CodingKey {
            case projectDirectory
            case sessionDirectory
            case sessionId
            case sessionTemplate
            case startRecordingVolume
            case endRecordingVolume
            case splitterOutputDirectory
            case splitterSeconds
            case splitterIgnoreLast
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

            self.projectDirectory = (try? container.decodeIfPresent(String.self, forKey: .projectDirectory))
                                        ?? AppDefaults.documentDirectory
            
            self.sessionDirectory = try? container.decodeIfPresent(String.self, forKey: .sessionDirectory)
            self.sessionId = try? container.decodeIfPresent(String.self, forKey: .sessionId)

            self.sessionTemplate = try? container.decodeIfPresent(String.self, forKey: .sessionTemplate)
            
            self.startRecordingVolume = (try? container.decodeIfPresent(Float.self, forKey: .startRecordingVolume)) ?? 1.0
            self.endRecordingVolume = (try? container.decodeIfPresent(Float.self, forKey: .endRecordingVolume)) ?? 0.2
            
            self.splitterOutputDirectory = try? container.decodeIfPresent(String.self, forKey: .splitterOutputDirectory)
            self.splitterSeconds = (try? container.decodeIfPresent(Double.self, forKey: .splitterSeconds)) ?? 1.0
            self.splitterIgnoreLast = (try? container.decodeIfPresent(Bool.self, forKey: .splitterIgnoreLast)) ?? false
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.projectDirectory, forKey: .projectDirectory)
            try container.encodeIfPresent(self.sessionDirectory, forKey: .sessionDirectory)
            try container.encodeIfPresent(self.sessionId, forKey: .sessionId)
            try container.encodeIfPresent(self.sessionTemplate, forKey: .sessionTemplate)
            try container.encodeIfPresent(self.startRecordingVolume, forKey: .startRecordingVolume)
            try container.encodeIfPresent(self.endRecordingVolume, forKey: .endRecordingVolume)
            try container.encodeIfPresent(self.splitterOutputDirectory, forKey: .splitterOutputDirectory)
            try container.encodeIfPresent(self.splitterSeconds, forKey: .splitterSeconds)
            try container.encodeIfPresent(self.splitterIgnoreLast, forKey: .splitterIgnoreLast)
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


