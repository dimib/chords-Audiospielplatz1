//
//  RecordingSessionHelper.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation
import SwiftUI

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
    
    static func chooseDirectory(completion: (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            completion(url)
        }
    }
    static func chooseFile(completion: (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            completion(url)
        }
    }
}
