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
    static let audioFileSplitterWindowId = "audiofile-splitter"
    static let chordSuggestionWindowId = "chord-suggestion"

    @StateObject var applicationState = ApplicationState()
    
    init() {
        Task {
            let isAuthorized = await AudioAuthorization.awaitAuthorization
            debugPrint("App is authorized? \(isAuthorized)")
        }
    }
    
    var body: some Scene {
        WindowGroup(id: Self.recordingSessionWindowId) {
            RecordingSessionView()
                .frame(width: 800, height: 600)
                .environmentObject(applicationState)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
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
        
        Window("Audiofile splitter", id: Self.audioFileSplitterWindowId) {
            AudioFileSplitterView()
                .environmentObject(applicationState)
        }
        .windowResizability(.contentMinSize)
        
        Window("Chord Suggestion", id: Self.chordSuggestionWindowId) {
            ChordSuggestionView()
                .environmentObject(applicationState)
        }
        .windowResizability(.contentSize)
        
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Recording Session") {
                    openWindow(id: Self.recordingSessionWindowId)
                }
            }
            CommandGroup(replacing: .pasteboard) {}
            CommandGroup(replacing: .sidebar) {}
            CommandGroup(replacing: .toolbar) {}
            CommandGroup(replacing: .windowArrangement) {}
            CommandGroup(replacing: .windowList) {}
            CommandGroup(replacing: .undoRedo) { }
        }
    }
}


