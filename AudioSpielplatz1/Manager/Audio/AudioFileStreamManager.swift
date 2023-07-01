//
//  AudioFileStreamManager.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 29.06.23.
//

import Foundation
import Combine
import AudioToolbox
import AVFoundation

// https://stackoverflow.com/questions/39760765/extaudiofile-into-a-float-buffer-produces-zeros

final class AudioFileStreamManager {
    
    enum AudioStreamManagerState {
        case idle
        case streaming(sampleTime: Int64)
        case error(message: String)
    }
 
    private var audioFileURL: URL?
    
    @Published var audioStreamManagerState: AudioStreamManagerState = .idle
    
    let dispatchQueue = DispatchQueue(label: "audiofile-streaming", qos: .userInitiated)
    
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

    func setupStreamingSession(audioFile: URL) throws {
        self.audioFileURL = audioFile
        audioStreamManagerState = .idle
    }
    
    func start() throws {
        Task {
            guard let audioFileURL = self.audioFileURL else { throw AudioManagerError.noAudioFile }
            
            guard let audioFile = try? AVAudioFile(forReading: audioFileURL, commonFormat: .pcmFormatFloat32,
                                                   interleaved: false) else {
                print("Failed to open audio file '\(audioFileURL)'")
                throw AudioManagerError.audioFile(0)
            }
            guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                                     frameCapacity: AUAudioFrameCount(audioFile.length)) else {
                print("Failed to create audio buffer")
                throw AudioManagerError.audioFile(0)
            }
            debugPrint("frameCount=\(AUAudioFrameCount(audioFile.length))")

            var reading = true
            while reading {
                do {
                    try audioFile.read(into: audioBuffer)
                    debugPrint("format=\(audioBuffer.format)")
                    _audioStream?.send(AudioData(buffer: audioBuffer, when: AVAudioTime(hostTime: 0)))
                } catch {
                    print("Error: \(error.localizedDescription)")
                    reading = false
                }
            }
        }
    }

    
    func startX() throws {
        Task {
            guard let audioFileURL = self.audioFileURL else { throw AudioManagerError.noAudioFile }
            
            var fileRef: ExtAudioFileRef?
            let openStatus = ExtAudioFileOpenURL(audioFileURL as CFURL, &fileRef)
            guard openStatus == noErr, let fileRef else {
                print("Failed to open audio file '\(audioFileURL)' with error \(openStatus)")
                throw AudioManagerError.audioDevice(openStatus)
            }
            
            var streamDesc: AudioStreamBasicDescription = AudioStreamBasicDescription()
            var streamDescSize: UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
            let streamDescStatus = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileDataFormat,
                                                            &streamDescSize, &streamDesc)
            guard streamDescStatus == noErr,
                  let audioFormat = AVAudioFormat(streamDescription: &streamDesc) else {
                throw AudioManagerError.audioDevice(streamDescStatus)
            }

            let numSamples = 1024 //How many samples to read in at a startTime
            let sizePerPacket:UInt32 = streamDesc.mBytesPerPacket // sizeof(Float32) = 32 byts
            let packetsPerBuffer:UInt32 = UInt32(numSamples)
            let outputBufferSize:UInt32 = packetsPerBuffer * sizePerPacket //4096
            
            let outputbuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: MemoryLayout<UInt8>.size * Int(outputBufferSize))
            
            defer {
                ExtAudioFileDispose(fileRef)
                free(outputbuffer)
            }

            var convertedData = AudioBufferList()
            convertedData.mNumberBuffers = 1
            convertedData.mBuffers.mNumberChannels = streamDesc.mChannelsPerFrame
            convertedData.mBuffers.mDataByteSize = outputBufferSize
            convertedData.mBuffers.mData = UnsafeMutableRawPointer(outputbuffer)
            
            var frameCount:UInt32 = UInt32(numSamples)
            while frameCount > 0 {
                let readStatus = ExtAudioFileRead(fileRef, &frameCount, &convertedData)
                guard readStatus == noErr else { throw AudioManagerError.audioFile(readStatus) }
                
                let ptr = convertedData.mBuffers.mData?.assumingMemoryBound(to: Float32.self)
                let samples: [Float32] = Array(UnsafeBufferPointer(start: ptr, count: Int(frameCount)))
                let max: Float32 = samples.reduce(0.0) { partialResult, sample in
                    return sample > partialResult ? sample : partialResult
                }
                debugPrint("😎 min=\(0) max=\(max)")
                
                if let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, bufferListNoCopy: &convertedData) {
                    let analyzerData = AudioAnalyzerData(audioData: AudioData(buffer: buffer, when: AVAudioTime(hostTime: 0)))
                    debugPrint("min=\(analyzerData.min) max\(analyzerData.max)")
                    _audioStream?.send(AudioData(buffer: buffer, when: AVAudioTime(hostTime: 0)))
                }
            }
        }
    }
    
    func stop() {
    }
}
