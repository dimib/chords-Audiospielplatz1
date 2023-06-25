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
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environmentObject(ApplicationState())
            RecordingSessionView()
                .frame(width: 800, height: 600)
                .environmentObject(ApplicationState())
        }
        .windowResizability(.contentSize)

        Window("Volume Settings", id: Self.volumeSettingsId, content: {
            VolumeSettingsView()
                .frame(minWidth: 400, minHeight: 180)
        })
        .windowResizability(.contentMinSize)
        
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Recording Session") {
                    openWindow(id: Self.recordingSessionWindowId)
                }
            }
            CommandGroup(before: .systemServices) {
                Button("Settings") {
                    // Opens the recording settings
                }
            }
            CommandMenu("Recording Session") {
                Button("New Recording Session") {
                    openWindow(id: Self.recordingSessionWindowId)
                }
            }
        }
        
    }
}


