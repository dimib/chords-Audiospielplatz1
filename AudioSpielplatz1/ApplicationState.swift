//
//  AppState.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import Foundation
import Combine

@MainActor
final class ApplicationState: ObservableObject {
    
    private var recordingManager = RecordingManager()
    private var playbackManager = PlaybackManager()

    @Published var state: PlayerState = .idle
    @Published var message: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        recordingManager.$recordingManagerState
            .receive(on: DispatchQueue.main)
            .sink { state in
            switch state {
            case .idle:
                self.state = .idle
                self.message = ""
            case let .recording(filename: filename):
                self.state = .recording
                self.message = "Recording: \(filename)"
            case let .error(message: message):
                self.state = .idle
                self.message = "Recording error: \(message)"
            }
        }.store(in: &cancellables)
        
        playbackManager.$playbackManagerState
            .receive(on: DispatchQueue.main)
            .sink { state in
            switch state {
            case .idle:
                self.state = .idle
                self.message = ""
            case let .playing(filename: filename):
                self.state = .playing
                self.message = "Playing: \(filename)"
            case let.error(message: message):
                self.state = .idle
                self.message = "Playback error: \(message)"
            }
        }.store(in: &cancellables)
    }
    
    func startRecording() {
        
        guard state == .idle else { return }
        
        Task {
            if await recordingManager.isAuthorized {

                do {
                    try await recordingManager.setupCaptureSession(output: "MyRecording")
                    try await recordingManager.startRecording()
                } catch {
                    state = .idle
                    message = error.localizedDescription
                }
            }
        }
    }
    
    func startPlaying() {
        guard state == .idle else { return }
        do {
            try playbackManager.setupPlayerSession(input: "MyRecording")
            try playbackManager.startPlaying()
        } catch {
            state = .idle
            message = error.localizedDescription
        }
    }
    
    func stop() {
        if state == .recording {
            recordingManager.stopRecording()
            message = "Stopped recording!"
        }
        if state == .playing {
            playbackManager.stopPlaying()
            message = "Stopped playing"
        }
        state = .idle
    }
}

enum PlayerState {
    case idle
    case recording
    case playing
}

enum PlayerAction {
    case play
    case stop
    case record
    case forward
    case backward
}
