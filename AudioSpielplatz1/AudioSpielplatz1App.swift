//
//  AudioSpielplatz1App.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import SwiftUI

@main
struct AudioSpielplatz1App: App {
    
    @Environment (\.openWindow) var openWindow
    
    static let recordingSessionWindowId = "recording-session"
    static let volumeSettingsId = "volume-settings"
    static let analyzerWindowId = "analyzer-window"

    @StateObject var applicationState = ApplicationState()
    
    var body: some Scene {
        WindowGroup(id: Self.recordingSessionWindowId) {
            RecordingSessionView()
                .frame(width: 800, height: 600)
                .environmentObject(applicationState)
        }
        .windowResizability(.contentSize)
                
        Window("Recording Settings", id: Self.volumeSettingsId){
            VolumeSettingsView()
                .frame(minWidth: 400, minHeight: 180)
                .environmentObject(applicationState)
        }
        .windowResizability(.contentMinSize)
        
        Window("Analyzer", id: Self.analyzerWindowId) {
            AnalyzerView()
                .environmentObject(applicationState)
        }
        .windowResizability(.contentMinSize)
        
        
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Recording Session") {
                    openWindow(id: Self.recordingSessionWindowId)
                }
                Button("Open Recording Session") {
                }
            }
            CommandGroup(replacing: .pasteboard) {
            }
            CommandGroup(after: .systemServices) {
                Divider()
                Menu("Settings...") {
                    Button("Start / End Volume") {
                        openWindow(id: Self.volumeSettingsId)
                    }
                    Button("Project Settings") {
                        
                    }
                }
            }
        }
    }
}


