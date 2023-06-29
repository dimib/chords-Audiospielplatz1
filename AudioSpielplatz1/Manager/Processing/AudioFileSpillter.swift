//
//  AudioFileSpillter.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 29.06.23.
//

import Foundation
import AudioToolbox


final class AudioFileSplitter {
    
    let audioFile: URL
    let outputPath: URL
    let seconds: Int
    
    init(input: URL, outputPath: URL, seconds: Int) throws {
        self.audioFile = input
        self.outputPath = outputPath
        self.seconds = seconds
    }
    
    func splitAudioFile() {
        do {
            try readAudioFile(atURL: audioFile)
            debugPrint("Done.")
        } catch {
            debugPrint("Error: \(error.localizedDescription)")
        }
    }

/*
    private func openAudioFile() throws -> AudioFileID {
        guard !audioFilePath.isEmpty, let url = URL(string: audioFilePath) else { throw AudioManagersError.illegalInputFile }
        var audioFileId: AudioFileID?
        
        let status = AudioFileOpenURL(url as CFURL, .readPermission, kAudioFileWAVEType, &audioFileId)
        guard status == 0, let audioFileId else { throw AudioManagersError.audioDevice(status) }
        
        return audioFileId
    }
    
    private func closeAudioFile(fd: AudioFileID) {
        AudioFileClose(fd)
    }
*/
    
    func readAudioFile(atURL fileURL: URL) throws {
        var audioFileID: AudioFileID?
        
        // Open the audio file
        let status = AudioFileOpenURL(fileURL as CFURL, .readPermission, 0, &audioFileID)
        guard status == noErr, let fileID = audioFileID else {
            // Error handling
            throw AudioManagersError.audioDevice(status)
        }
        
        defer {
            // Close the audio file when finished
            AudioFileClose(fileID)
        }
        
        // Get the audio file format
        var fileFormat = AudioStreamBasicDescription()
        var formatSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        
        let formatStatus = AudioFileGetProperty(fileID, kAudioFilePropertyDataFormat, &formatSize, &fileFormat)
        guard formatStatus == noErr else {
            throw AudioManagersError.audioDevice(formatStatus)
        }
        
        // Calculate the buffer size based on desired frames
        let desiredNumFrames: UInt32 = 1024 // Number of audio frames to read
        let bufferSize = UInt32(desiredNumFrames) * fileFormat.mBytesPerFrame
        
        // Allocate memory for the audio buffer
        guard let audioBuffer = malloc(Int(bufferSize)) else {
            throw AudioManagersError.illegalState
        }
        
        var reading = true
        var timeCounter: Double = 0
        var byteCounter: Int64 = 0
        var frameCounter: Int64 = 0
        
        while reading {
            // Read the audio data from the file
            var numFrames = desiredNumFrames
            let readStatus = AudioFileReadBytes(fileID, false, byteCounter, &numFrames, audioBuffer)
            switch readStatus {
            case noErr: break
            case kAudioFileEndOfFileError:
                reading = false
                return
            default:
                free(audioBuffer)
                throw AudioManagersError.audioDevice(readStatus)
            }
            
            let theBuffer = AudioBuffer(mNumberChannels: fileFormat.mChannelsPerFrame, mDataByteSize: numFrames * fileFormat.mBytesPerFrame, mData: audioBuffer)
            
            debugPrint("😎 byteCounter=\(byteCounter) frameCounter=\(frameCounter)")
            byteCounter += Int64(numFrames * fileFormat.mBytesPerFrame)
            frameCounter += Int64(numFrames)
        }
        // processAudioBuffer(audioBuffer, frameCount: numFrames, format: fileFormat)
        // Remember to release allocated memory
        free(audioBuffer)
    }
    
    func processAudioBuffer(_ audioBuffer: UnsafeMutableRawPointer, frameCount: UInt32, format: AudioStreamBasicDescription) {
//        let floatBuffer = audioBuffer.assumingMemoryBound(to: Float.self)
        let floatArray = Array(UnsafeBufferPointer(start: audioBuffer.assumingMemoryBound(to: Float32.self), count: Int(frameCount) * Int(format.mChannelsPerFrame)))
        
//        for frame in 0..<Int(frameCount) {
//            for channel in 0..<Int(format.mChannelsPerFrame) {
//                let sample = floatBuffer[frame * Int(format.mChannelsPerFrame) + channel]
//
//                // Process the audio sample here
//                // Example: Print the sample value
//                print("Sample \(frame) in channel \(channel): \(sample)")
//            }
//        }
    }

    // Usage example
//    let audioBuffer: UnsafeMutableRawPointer = ... // Your audio buffer
//    let frameCount: UInt32 = ... // Number of audio frames in the buffer
//    let audioFormat: AudioStreamBasicDescription = ... // Format of the audio data
//
//    processAudioBuffer(audioBuffer, frameCount: frameCount, format: audioFormat)

}
