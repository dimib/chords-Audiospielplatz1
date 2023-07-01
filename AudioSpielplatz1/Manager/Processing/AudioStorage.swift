//
//  AudioStorage.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 21.06.23.
//

import Foundation
import AVFoundation
import Combine

final class AudioStorage {
    
    private var cancellable: AnyCancellable?
    private var audioFile: AVAudioFile?

    func setupAudioStorage(audioStream: AnyPublisher<AudioData, AudioManagerError>, output: URL) throws {
        
        cancellable = audioStream
            .sink(receiveCompletion: { error in
                self.audioFile = nil
            }, receiveValue: { audioData in
                try? self.writePCMBuffer(buffer: audioData.buffer, output: output)
            })
    }
    
    func writePCMBuffer(buffer: AVAudioPCMBuffer, output: URL) throws {
        do {
            if audioFile == nil {
                audioFile = try openAudioFile(buffer: buffer, output: output)
            }
            try audioFile?.write(from: buffer)
        } catch {
            print("Could not write file, error=\(error.localizedDescription)")
        }
    }
    
    private func openAudioFile(buffer: AVAudioPCMBuffer, output: URL) throws -> AVAudioFile {
        let settings: [String: Any] = [
            AVFormatIDKey: buffer.format.settings[AVFormatIDKey] ?? kAudioFormatLinearPCM,
            AVNumberOfChannelsKey: buffer.format.settings[AVNumberOfChannelsKey] ?? 1,
            AVSampleRateKey: buffer.format.settings[AVSampleRateKey] ?? 44100,
            AVLinearPCMBitDepthKey: buffer.format.settings[AVLinearPCMBitDepthKey] ?? 16
        ]
        do {
            let audioFile = try AVAudioFile(forWriting: output, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: false)
            self.audioFile = audioFile
            return audioFile
        } catch {
            debugPrint("☠️ error opening file at \(output.absoluteString)")
            throw error
        }
    }
}
