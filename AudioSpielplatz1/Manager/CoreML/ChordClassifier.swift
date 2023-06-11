//
//  ChordClassifier.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 11.06.23.
//

import Foundation
import AVFoundation
import SoundAnalysis

/// This class will try to find the correct chord from an audio stream.
final class ChordClassifier: NSObject {
    
    /// A dispatch queue to asynchronously perform analysis on.
    private let analysisQueue = DispatchQueue(label: "net.ubahnstation.spielplatz.AudioSpielplatz1.AnalysisQueue")

    /// An audio engine the app uses to record system input.
    private var audioEngine: AVAudioEngine?

    /// An analyzer that performs sound classification.
    private var analyzer: SNAudioStreamAnalyzer?
    
    
    func setupClassifier(audioFormat: AVAudioFormat) {
        
    }
    
}

// MARK: - Process audio buffer

extension ChordClassifier: AudioDataProcessor {
    func processNext(_ audioBuffer: AudioData) throws {
        //
    }
}
