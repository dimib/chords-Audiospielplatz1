//
//  AppState.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import Foundation
import Combine

/// This is a simple application state implementation

@MainActor
final class ApplicationState: ObservableObject {

    private let audioDeviceManager = AudioDeviceManager()
    private var audioStreamManager = AudioStreamManager()
    private var recordingManager = RecordingManager()
    private var playbackManager = PlaybackManager()
    
    private var soundClassifier: SoundClassifier?
    private var audioAnalyzer: AudioAnalyzer?

    @Published var state: PlayerState = .idle
    @Published var message: String = ""
    @Published var analyzerData: AudioAnalyzerData = .zero
    
    private var cancellables = Set<AnyCancellable>()
    private var audioStreams = Set<AnyCancellable>()
    
    private var outputFile: URL? {
        URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent("MyRecording.wav")
    }
    
    /// Initialize different recording and playback state subscribers
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
        
        audioStreamManager.$audioStreamManagerState
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .idle:
                    self.state = .idle
                    self.message = ""
                case let .streaming(sampleTime: sampleTime):
                    self.state = .analyzing
                    self.message = "Stream: \(sampleTime)"
                case let .error(message: message):
                    self.state = .idle
                    self.message = "Stream error: \(message)"
                }
            }.store(in: &cancellables)

/*
    
        do {
            try audioDeviceManager.updateDevices()
            audioDeviceManager.devices.forEach { debugPrint($0.description) }
            
            if let micro = audioDeviceManager.devices.first(where: { $0.name.starts(with: "Mikrofon von") }) {
                try audioDeviceManager.setDefault(audioDevice: micro)
                debugPrint("Default = \(micro.description)")
                try audioDeviceManager.enableInput(bus: 0)
                debugPrint("Audio should be enabled")
            }
            
        } catch {
            debugPrint("☠️ Audio Device Error \(error.localizedDescription)")
        }
 */
    }
    
    /// Start recording. This will just save the received audio data into a file.
    func startRecording() {
        
        guard state == .idle else { return }
        
        Task {
            if await AudioAuthorization.awaitAuthorization {

                do {
                    try recordingManager.setupCaptureSession(output: "MyRecording")
                    try recordingManager.startRecording()
                } catch {
                    state = .idle
                    message = error.localizedDescription
                }
            }
        }
    }
    
    /// Start playback. This will just play the previously recorded file
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
    
    func startAnalyze() {
        guard state == .idle else { return }
        
        Task {
            if await AudioAuthorization.awaitAuthorization {
                do {
                    try audioStreamManager.setupCaptureSession()
/*
                    let soundClassifier = SystemSoundClassifier()
                    try soundClassifier.setupClassifier(audioFormat: audioStreamManager.audioFormat,
                                                        audioStream: audioStreamManager.audioStream)
                    self.soundClassifier = soundClassifier
 */
                    let audioAnalyzer = AudioAnalyzer()
                    try audioAnalyzer.setupAnalyzer(audioStream: audioStreamManager.audioStream)
                    audioAnalyzer.publisher
                        .receive(on: DispatchQueue.main)
                        .sink { data in
                            self.analyzerData = data
                        }
                        .store(in: &cancellables)

                    self.audioAnalyzer = audioAnalyzer
                    
                    let audioStorage = AudioStorage()
                    try audioStorage.setupAudioStorage(audioStream: audioStreamManager.audioStream, output: outputFile!)

                    try audioStreamManager.start()
                } catch {
                    state = .idle
                    message = error.localizedDescription
                }
            }
        }
    }
    
    /// Stop recording, playback or analyzing
    func stop() {
        
        switch state {
        case .idle: break
        case .recording:
            // recordingManager.stopRecording()
            audioStreamManager.stop()
            message = "Stopped recording!"
        case .playing:
            playbackManager.stopPlaying()
            message = "Stopped playing"
        case .analyzing:
            audioStreamManager.stop()
            message = "Audio stream stopped"
        }
        
        state = .idle
    }
}

enum PlayerState {
    case idle
    case recording
    case playing
    case analyzing
}

enum PlayerAction {
    case play
    case stop
    case record
    case analyze
    case forward
    case backward
}
