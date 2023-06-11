//
//  AudioBufferProcessor.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 11.06.23.
//

import Foundation
import AVFoundation


/// This structure is used to transport received audio data with time information
/// to audio processors or subscribers via Combine
struct AudioData {
    let buffer: AVAudioPCMBuffer
    let when: AVAudioTime
}

protocol AudioDataProcessor: AnyObject {
    func startProcessing()
    func endProcessing()
    func processNext(_ audioBuffer: AudioData) throws
}

extension AudioDataProcessor {
    func startProcessing() {}
    func endProcessing() {}
    func processNext(_ audioBuffer: AudioData) throws {}
}
