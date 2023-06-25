//
//  SessionRecorder.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation
import Combine
import AVFoundation

/// The session recorder is used to record one sound item, e.g. a chord.
/// The session recorder will be parameterized with the required durations
/// and minimum volule parameters.
final class SessionRecorder {
    
    // MARK: - Types
    enum RecorderState: Equatable {
        case idle
        case waitingForBegin
        case recording(Double)
        case waitingForEnd
        case end
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                (.waitingForBegin, .waitingForBegin),
                (.waitingForEnd, .waitingForEnd),
                (.recording(_), .recording(_)),
                (.end, .end): return true
            default: return false
            }
        }
        
        var description: String {
            switch self {
            case .idle: return "Idle"
            case .waitingForBegin: return "Waiting for begin"
            case .recording: return "Recording"
            case .waitingForEnd: return "Waiting for end"
            case .end: return "Recording ended."
            }
        }
    }
    
    // MARK: - Combine

    private var _recorderState = PassthroughSubject<RecorderState, AudioManagersError>()
    var recorderStatePublisher: AnyPublisher<RecorderState, AudioManagersError> {
        _recorderState.eraseToAnyPublisher()
    }
    
    private var _analyzerState = PassthroughSubject<AudioAnalyzerData, AudioManagersError>()
    var recorderAnylizerPublisher: AnyPublisher<AudioAnalyzerData, AudioManagersError> {
        _analyzerState.eraseToAnyPublisher()
    }
    
    // MARK: - Properties

    private var state: RecorderState = .idle {
        didSet {
            _recorderState.send(state)
        }
    }
    
    private let output: URL
    private let duration: Double
    private let startVolume: Float
    private let endVolume: Float
    
    private let audioStreamManager = AudioStreamManager()
    private var audioFile: AVAudioFile?
    
    private var startAudioTime: AVAudioTime?
    private var cancellable: AnyCancellable?
    
    // MARK: - Life Cycle

    init(output: URL, duration: Double, startVolume: Float, endVolume: Float) {
        self.output = output
        self.duration = duration
        self.startVolume = startVolume
        self.endVolume = endVolume
    }
    
    func setupRecording() throws {
        do {
            self.state = .idle
            
            try audioStreamManager.setupCaptureSession()
            
            cancellable = audioStreamManager.audioStream
                .filter { audioData in

                    let analyzerData = AudioAnalyzerData(audioData: audioData)
                    self._analyzerState.send(analyzerData)

                    switch self.state {
                    case .idle: return false
                    case .waitingForBegin:
                        debugPrint("😎 waitForBegin volume=\(analyzerData.max) start=\(self.startVolume)")
                        if analyzerData.max >= self.startVolume {
                            self.startAudioTime = audioData.when
                            self.state = .recording(0)
                            return true
                        }
                        return false
                    case .recording:
                        let newDuration = self.recordingDuration(audioTime: audioData.when)
                        debugPrint("😎 recording duration=\(newDuration)")
                        if newDuration < self.duration {
                            self.state = .recording(self.recordingDuration(audioTime: audioData.when))
                        } else {
                            self.state = .waitingForEnd
                        }
                        return true
                    case .waitingForEnd:
                        debugPrint("😎 waitForEnd volume=\(analyzerData.max) start=\(self.endVolume)")
                        if analyzerData.max < self.endVolume {
                            self.state = .end
                        }
                        return true
                    case .end:
                        debugPrint("😎 end")
                        return false
                    }
                }
                .sink(receiveCompletion: { error in
                    //
                }, receiveValue: { audioData in
                    switch self.state {
                    case .end:
                        self._recorderState.send(completion: .finished)
                        self._analyzerState.send(completion: .finished)
                        self.cancellable?.cancel()
                    default: break
                    }
                })
        } catch {
            print("☠️ could not setup audio session, error=\(error)")
            throw error
        }
    }
    
    func startRecording() throws {
        try audioStreamManager.start()
        state = .waitingForBegin
        _analyzerState.send(.zero)
    }
    
    func stopRecording() {
        audioStreamManager.stop()
        cancellable?.cancel()
        state = .idle
    }
    
    private func recordingDuration(audioTime: AVAudioTime) -> Double {
        guard let startAudioTime else { return 0 }
        let hostTimeDurationSeconds = AVAudioTime.seconds(forHostTime: audioTime.hostTime) - AVAudioTime.seconds(forHostTime: startAudioTime.hostTime)
        return hostTimeDurationSeconds
    }
}
