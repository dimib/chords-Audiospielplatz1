//
//  RecordingSession.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation

final class RecordingSession: Storable {
    let name: String
    let desc: String
    let params: RecordingSessionParams
    
    var list: [RecordingSessionItem]
}

struct RecordingSessionItem: Codable {
    let label: String
    let prefix: String
    let countRequired: Int
    let countRecorded: Int
}

struct RecordingSessionParams: Codable {
    let recordingSeconds: Double
    let sampleSeconds: Double
}
