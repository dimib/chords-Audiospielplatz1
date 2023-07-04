//
//  StreamRecordingManager.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import Foundation
import AVFoundation
import Combine

final class AudioStreamManager: NSObject, ObservableObject {

    var config: AudioStreamManagerConfig?
    
    enum AudioStreamManagerState {
        case idle
        case streaming(sampleTime: Int64)
        case error(message: String)
    }
    
    private var audioEngine = AVAudioEngine()
    
    var audioFormat: AVAudioFormat? {
        guard let config else { return nil }
        return audioEngine.inputNode.inputFormat(forBus: config.busIndex)
    }
    
    @Published var audioStreamManagerState: AudioStreamManagerState = .idle
    
    /// Publisher for audio streams. The stream will be closed when the audio streaming
    /// is stopped.
    private var _audioStream: PassthroughSubject<AudioData, AudioManagerError>?
    var audioStream: AnyPublisher<AudioData, AudioManagerError> {
        guard let audioStream = _audioStream else {
            let audioStream = PassthroughSubject<AudioData, AudioManagerError>()
            _audioStream = audioStream
            return audioStream.eraseToAnyPublisher()
        }
        return audioStream.eraseToAnyPublisher()
    }
    
    func requestAuthorization() async -> Bool {
        await AudioAuthorization.awaitAuthorization
    }
    
    @discardableResult
    func setupCaptureSession(config: AudioStreamManagerConfig = .init()) throws -> AVAudioFormat {
        
        guard AudioAuthorization.isAuthorized else {
            throw AudioManagerError.notAuthorized
        }
        
        self.config = config

        let audioFormat = audioEngine.inputNode.inputFormat(forBus: config.busIndex)
        audioEngine.inputNode.installTap(onBus: config.busIndex, bufferSize: config.bufSize,
                                         format: audioFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            DispatchQueue.main.async {
                // Must change the published value on main thread
                self.audioStreamManagerState = .streaming(sampleTime: when.sampleTime)
            }
            self._audioStream?.send(AudioData(buffer: buffer, when: when))
        }
        return audioFormat
    }
    
    func start() throws {
        try audioEngine.start()
    }
    
    func stop() {
        guard let config = self.config else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: config.busIndex)
        _audioStream?.send(completion: .finished)
        _audioStream = nil
    }
}

extension AVAudioPCMBuffer {
    var data: Data {
        let channelCount = 1
        let channels = UnsafeBufferPointer(start: self.floatChannelData, count: channelCount)
        let ch0data = NSData(bytes: channels[0],
                             length: Int(self.frameCapacity * self.format.streamDescription.pointee.mBytesPerFrame))
        return ch0data as Data
    }
}
