//
//  RecordingSessionViewModel.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation
import Combine

final class RecordingSessionViewModel: ObservableObject {

    @Published var sessionDefinition: RecordingSessionDefinition?
    
    var projectDirectory: String {
        AppConfiguration().config.projectDirectory
    }
    
    // MARK: - Session settings
    @Published var sessionDirectory: String = ""
    @Published var sessionTemplate: String = ""
    @Published var sessionId: String = ""
    
    func setSessionDirectory(_ sessionDirectory: URL) {
        self.sessionDirectory = sessionDirectory.absoluteString
        AppConfiguration().config.sessionDirectory = self.sessionDirectory
        openRecordingSession()
    }
    
    func setSessionTemplate(_ sessionTemplate: URL) {
        do {
            let recordingSession = try JSONFileStorage<RecordingSession>(url: sessionTemplate).load()
            self.sessionTemplate = sessionTemplate.absoluteString
            AppConfiguration().config.sessionTemplate = self.sessionTemplate
            openRecordingSession()
        } catch {
            self.sessionTemplate = "\(error.localizedDescription)"
        }
    }
    
    // MARK: - Chords expected to play
    @Published var previousChord: String = ""
    @Published var currentChord: String = ""
    @Published var nextChord: String = ""
    
    private var currentChordIndex = 0
    
    // MARK: - Recording duration
    @Published var timeRecorded: Double = 0
    @Published var timeExpected: Double = 0
    
    // MARK: - Audio stream data
    @Published var audioAnalyzerData: AudioAnalyzerData = .zero

    @Published var recordingState: String = SessionRecorder.RecorderState.idle.description
    
    @Published var playerState: PlayerState = .idle
    
    private var sessionRecorder: SessionRecorder?
    
    private var recorderCancellable: AnyCancellable?
    private var analyzerCancellable: AnyCancellable?
    
    init() {
        let config = AppConfiguration().config
        print("Project directory: \(config.projectDirectory)")
        sessionDirectory = config.sessionDirectory ?? "- Choose session directory -"
        sessionTemplate = config.sessionTemplate ?? "- Choose session template -"
        sessionId = config.sessionId ?? ""
        openRecordingSession()
    }
    
    static func newRecordingSession(templateResource: String) -> RecordingSession? {
        do {
            let newSession: RecordingSession = try ResourceStorageLoader(name: templateResource).load()
            return newSession
        } catch {
            print("New Session, error=\(error)")
            return nil
        }
    }
    
    static func newRecordingSession(templateFile: URL) -> RecordingSession? {
        do {
            let newSession: RecordingSession = try JSONFileStorage(url: templateFile).load()
            return newSession
        } catch {
            print("New Session, error=\(error)")
            return nil
        }
    }
    
    // MARK: - Recording session
    
    func startRecordingSession() {
        currentChordIndex = 0
        recordCurrent()
    }
    
    func stopRecordingSession() {
        sessionRecorder?.stopRecording()
        playerState = .idle
    }
    
    private func recordCurrent() {
        
        guard let sessionUrl = sessionDefinition?.sessionDirectory,
              let sessionList = sessionDefinition?.recordingSession.list,
              let duration = sessionDefinition?.recordingSession.params.recordingSeconds,
              currentChordIndex < sessionList.count else {
            return
        }
        
        let sessionItem = sessionList[currentChordIndex]
        do {
            var outputUrl = sessionUrl.appendingPathComponent("\(sessionItem.prefix)", isDirectory: true)
            try RecordingSessionHelper.createDirectory(url: outputUrl)
            outputUrl.appendPathComponent("\(sessionItem.prefix).wav")
            let sessionRecorder = SessionRecorder(output: outputUrl, duration: duration, startVolume: 1.5, endVolume: 0.05)
            try sessionRecorder.setupRecording()
            
            recorderCancellable = sessionRecorder.recorderStatePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { error in
                    if error == .finished {
                        self.queueRecordNext()
                    }
                }, receiveValue: { recordingState in
                    self.recordingState = recordingState.description
                    switch recordingState {
                    case .idle, .waitingForBegin:
                        self.timeRecorded = 0
                    case .recording(let duration):
                        self.timeRecorded = duration
                    default: break
                    }
                })
            
            analyzerCancellable = sessionRecorder.recorderAnylizerPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { error in
                    self.audioAnalyzerData = .zero
                }, receiveValue: { analyzerData in
                    self.audioAnalyzerData = analyzerData
                })
            try sessionRecorder.startRecording()
            self.sessionRecorder = sessionRecorder
            self.playerState = .recording
            print("🎙️ start recording \(self.currentChordIndex)")
        } catch {
            print("☠️ session not started: \(error.localizedDescription)")
        }
    }
    
    private func queueRecordNext() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            guard let sessionList = self.sessionDefinition?.recordingSession.list,
                  self.currentChordIndex < sessionList.count - 1
            else {
                self.playerState = .idle
                return
            }

            self.currentChordIndex += 1
            self.showChords()
            self.recordCurrent()
        }
    }
    
    // MARK: - Private functions
    private func createNewRecordingSession() {
        guard let recordingSessionTemplate: RecordingSession = try? ResourceStorageLoader(name: "SimpleChordsTemplate").load() else { return }
        let config = AppConfiguration().config
        let sessionId = RecordingSessionHelper.newSessionId
        var sessionDirectoryUrl = URL(fileURLWithPath: config.projectDirectory)
        sessionDirectoryUrl.append(path: "\(recordingSessionTemplate.name)_\(sessionId)")
        let recordingSession = RecordingSessionDefinition(sessionId: sessionId, sessionDirectory: sessionDirectoryUrl, recordingSession: recordingSessionTemplate)
        do {
            try RecordingSessionHelper.createDirectory(url: recordingSession.sessionDirectory)
            self.sessionDefinition = recordingSession
        } catch {
            print("☠️ could not create directory at \(recordingSession.sessionDirectory)")
            return
        }
        
        timeRecorded = 0
        timeExpected = recordingSessionTemplate.params.recordingSeconds
        showChords()
    }
    
    private func openRecordingSession() {
        let config = AppConfiguration().config
        guard let sessionDirectory = config.sessionDirectory, let sessionUrl = URL(string: sessionDirectory),
              let sessionTemplate = config.sessionTemplate, let templateUrl = URL(string: sessionTemplate) else { return }
        
        do {
            let recordingSessionTemplate: RecordingSession = try JSONFileStorage(url: templateUrl).load()
            let sessionDefinition = RecordingSessionDefinition(sessionId: "000", sessionDirectory: sessionUrl,
                                                               recordingSession: recordingSessionTemplate)
            self.sessionDefinition = sessionDefinition
            timeRecorded = 0
            timeExpected = recordingSessionTemplate.params.recordingSeconds
            showChords()
        } catch {
            
        }
        
    }
    
    private func showChords() {
        guard let sessionDefinition else { return }
        let chordNames = sessionDefinition.recordingSession.list.map { $0.label }
        
        previousChord = currentChordIndex > 0 ? chordNames[currentChordIndex - 1] : ""
        currentChord = currentChordIndex >= 0 && currentChordIndex < chordNames.count ? chordNames[currentChordIndex] : ""
        nextChord = currentChordIndex < chordNames.count - 1 ? chordNames[currentChordIndex + 1] : ""
    }
}

struct RecordingSessionDefinition {
    let sessionId: String
    let sessionDirectory: URL
    var recordingSession: RecordingSession
}
