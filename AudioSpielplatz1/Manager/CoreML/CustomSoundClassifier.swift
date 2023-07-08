//
//  ChordClassifier.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 11.06.23.
//

import Foundation
import Combine
import AVFoundation
import SoundAnalysis

/// This class will try to find the correct chord from an audio stream.
final class CustomSoundClassifier: NSObject, SoundClassifier {
    
    /// A dispatch queue to asynchronously perform analysis on.
    private let analysisQueue = DispatchQueue(label: "net.ubahnstation.spielplatz.AudioSpielplatz1.AnalysisQueue")

    /// An analyzer that performs sound classification.
    private var analyzer: SNAudioStreamAnalyzer?

    /// Publisher for the sound classfier state
    private let _soundClassifierState = PassthroughSubject<SoundClassifierState, Never>()
    var soundClassifierState: AnyPublisher<SoundClassifierState, Never> {
        _soundClassifierState.eraseToAnyPublisher()
    }
    
    private var cancellable: AnyCancellable?

    private var config: CustomSoundClassifierConfiguration?

    /// Setup Sound Classifier
    func setupClassifier(config: CustomSoundClassifierConfiguration, audioFormat: AVAudioFormat, audioStream: AnyPublisher<AudioData, AudioManagerError>) throws {
        
        self.config = config
        do {
            let newAnalyzer = SNAudioStreamAnalyzer(format: audioFormat)
            analyzer = newAnalyzer
            
            let request = try SNClassifySoundRequest(mlModel: config.model)
            request.windowDuration = CMTimeMakeWithSeconds(config.inferenceWindowSize,
                                                           preferredTimescale: config.preferredTimescale)
            request.overlapFactor = config.overlapFactor
            try newAnalyzer.add(request, withObserver: self)
            
            cancellable = audioStream
                .filter {
                    return $0.max > config.minimumVolume }
                .sink(
                receiveCompletion: { error in
                    self.cleanup()
                }, receiveValue: { audioData in
                    self.analyzer?.analyze(audioData.buffer, atAudioFramePosition: audioData.when.sampleTime)
                })
            
            _soundClassifierState.send(.idle)
        } catch {
            _soundClassifierState.send(.error(message: error.localizedDescription))
            throw error
        }
    }
    
    private func cleanup() {
        analyzer?.removeAllRequests()
        analyzer = nil
        cancellable = nil
    }
    
    // MARK: Helper
    func translate(_ identifier: String) -> String {
        guard let config = self.config else { return identifier }
        return config.translation[identifier] ?? identifier
    }
}

extension CustomSoundClassifier: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        //debugPrint("😎 result: \(result.description)")
        if let result = result as? SNClassificationResult {
            let found = result.classifications.filter { $0.confidence > 0.8 }.sorted(by: { $0.confidence > $1.confidence })
            if !found.isEmpty {
                // debugPrint("😎 \(found)")
                _soundClassifierState.send(.classification(found))
            }
        }
    }
}

// MARK: - Process audio buffer

extension CustomSoundClassifier: AudioDataProcessor {
    func processNext(_ audioBuffer: AudioData) throws {
        //
    }
}
