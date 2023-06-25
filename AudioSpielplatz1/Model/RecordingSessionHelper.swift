//
//  RecordingSessionHelper.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation

/// This helper contains functions to create recording session ids, setup directories etc.

final class RecordingSessionHelper {
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter
    }()
    
    static var newSessionId: String {
        return dateFormatter.string(from: Date())
    }

    static func newSession(name: String) -> String {
        return "\(name)_\(newSessionId)"
    }
    
    static func createDirectory(url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
