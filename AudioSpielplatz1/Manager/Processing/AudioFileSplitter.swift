//
//  AudioFileSpillter.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 29.06.23.
//

import Foundation
import Combine
import AVFoundation


final class AudioFileSplitter {
    
    let audioFileURL: URL
    let outputPathURL: URL
    let seconds: Double
    
    var streamCancellable: AnyCancellable?
    
    let audioFileStreamingManager = AudioFileStreamManager()
    
    init(audioFile: URL, outputPath: URL, seconds: Double) throws {
        self.audioFileURL = audioFile
        self.outputPathURL = outputPath
        self.seconds = seconds
    }
    
    func splitAudioFile() throws {
        guard let audioFile = try? AVAudioFile(forReading: audioFileURL, commonFormat: .pcmFormatFloat32,
                                               interleaved: false) else {
            print("Failed to open audio file '\(audioFileURL)'")
            throw AudioManagerError.audioFile(0)
        }
        
        debugPrint("audioFormat: \(audioFile.fileFormat)")
        let frameLength = AUAudioFrameCount(audioFile.fileFormat.sampleRate * seconds)
        
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                                 frameCapacity: frameLength) else {
            print("Failed to create audio buffer")
            throw AudioManagerError.audioFile(0)
        }
        debugPrint("frameCount=\(frameLength)")
        
        var count = 0
        var reading = true
        while reading {
            do {
                try audioFile.read(into: audioBuffer, frameCount: frameLength)
                debugPrint("read frameLength=\(audioBuffer.frameLength)")
                try write(count: count, buffer: audioBuffer)
                count += 1
            } catch {
                reading = false
            }
        }
    }
    
    private func write(count: Int, buffer: AVAudioPCMBuffer) throws {
        let pathExtension = audioFileURL.pathExtension
        let audioFileName = audioFileURL.deletingPathExtension().lastPathComponent
        let outputFileName = "\(audioFileName)[\(count)].\(pathExtension)"
        let outputUrl = outputPathURL.appendingPathComponent(outputFileName, isDirectory: false)
        debugPrint("Output to \(outputUrl.absoluteString)")

        try AudioStorage().writePCMBuffer(buffer: buffer, output: outputUrl)
    }
}
