//
//  SystemSoundClassifier.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 11.06.23.
//

import Foundation
import SoundAnalysis
import Combine
import AVFoundation

/// This class will try to classify a sound from an audio stream.
final class SystemSoundClassifier: NSObject, SoundClassifier {
    
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

    /// Setup Sound Classifier
    func setupClassifier(audioFormat: AVAudioFormat, audioStream: AnyPublisher<AudioData, AudioManagerError>) throws {
        do {
            let newAnalyzer = SNAudioStreamAnalyzer(format: audioFormat)
            analyzer = newAnalyzer
            
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            request.windowDuration = CMTimeMakeWithSeconds(AppDefaults.inferenceWindowSize, preferredTimescale: 48_000)
            request.overlapFactor = AppDefaults.overlapFactor
            try newAnalyzer.add(request, withObserver: self)
            
            cancellable = audioStream.sink(
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
}

extension SystemSoundClassifier: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        //debugPrint("😎 result: \(result.description)")
        if let result = result as? SNClassificationResult {
            let found = result.classifications.filter { $0.confidence > 0.8 }.sorted(by: { $0.confidence > $1.confidence })
            if !found.isEmpty {
                debugPrint("😎 \(found)")
            }
        }
    }
}
