//
//  VolumeSettingsViewModel.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 28.06.23.
//

import Foundation

class VolumeSettingsViewModel: ObservableObject {
    @Published var startVolume: Double = 1.0
    @Published var endVolume: Double = 0.2
    
    init() {
        load()
    }
    func load() {
        let config = AppConfiguration().config
        startVolume = Double(config.startRecordingVolume)
        endVolume = Double(config.endRecordingVolume)
    }
    
    func save() {
        AppConfiguration().config.startRecordingVolume = Float(startVolume)
        AppConfiguration().config.endRecordingVolume = Float(endVolume)
    }
    
}
