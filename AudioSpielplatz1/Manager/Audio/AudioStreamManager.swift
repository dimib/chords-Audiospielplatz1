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
    
    enum AudioStreamManagerState {
        case idle
        case streaming(sampleTime: Int64)
        case error(message: String)
    }
    
    private let busIndex = AVAudioNodeBus(0)
    private let bufSize = AVAudioFrameCount(4096)
    
    private var audioEngine = AVAudioEngine()
    
    @Published var audioStreamManagerState: AudioStreamManagerState = .idle
    
    /// Publisher for audio streams. The stream will be closed when the audio streaming
    /// is stopped.
    private var _audioStream: PassthroughSubject<AudioData, AudioManagersError>?
    var audioStream: AnyPublisher<AudioData, AudioManagersError> {
        guard let audioStream = _audioStream else {
            let audioStream = PassthroughSubject<AudioData, AudioManagersError>()
            _audioStream = audioStream
            return audioStream.eraseToAnyPublisher()
        }
        return audioStream.eraseToAnyPublisher()
    }
    
    var audioFormat: AVAudioFormat { audioEngine.inputNode.outputFormat(forBus: 0) }
    
    func setupCaptureSession() async throws {
        guard await AudioAuthorization.isAuthorized else { return }
        
        let audioFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: busIndex, bufferSize: bufSize,
                                         format: audioFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            DispatchQueue.main.async {
                // Must change the published value on main thread
                self.audioStreamManagerState = .streaming(sampleTime: when.sampleTime)
            }
            self._audioStream?.send(AudioData(buffer: buffer, when: when))
        }
    }
    
    func start() throws {
        try audioEngine.start()
    }
    
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: busIndex)
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
