//
//  ChordSuggestionViewModel.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 02.07.23.
//

import Foundation
import Combine
import CoreML
import SoundAnalysis

final class ChordSuggestionViewModel: ObservableObject {

    @Published var analyzerData: AudioAnalyzerData = .zero
    @Published var chordLabel: String = ""
    @Published var confidenceLabel: String = ""

    private let audioStreamManager = AudioStreamManager()
    private let soundClassifier = CustomSoundClassifier()
    private let audioAnalyzer = AudioAnalyzer()

    private var cancellables = Set<AnyCancellable>()
    
    func startAnalyze() {
        print("🎙️ start chord suggestion")
        do {
            let chordClassifierConfig = try CustomSoundClassifierConfiguration.makeChordsClassifier5()
            let audioFormat = try audioStreamManager.setupCaptureSession()
            try audioAnalyzer.setupAnalyzer(audioStream: audioStreamManager.audioStream)
            
            audioAnalyzer.publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { error in
                }) { audioAnalyzerData in
                    self.analyzerData = audioAnalyzerData
                }
                .store(in: &cancellables)
            
            
            try soundClassifier.setupClassifier(config: chordClassifierConfig,
                                            audioFormat: audioFormat,
                                            audioStream: audioStreamManager.audioStream)
            soundClassifier.soundClassifierState
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { state in
                    switch state {
                    case .classification(let classification):
                        self.updateClasssification(classification: classification)
                    default: break
                    }
                })
                .store(in: &cancellables)

            
            try audioStreamManager.start()
        } catch {
            print("☠️ chord suggestion not started, error=\(error)")
        }
    }
    
    func stopAnalyze() {
        print("🎙️ stop chord suggestion")
        audioStreamManager.stop()
    }
    
    private func updateClasssification(classification: [SNClassification]) {
        guard let chordClassification = classification.sorted(by: { $0.confidence > $1.confidence }).first else {
            return
        }
        
        if chordClassification.identifier == "Noise" {
            chordLabel = ""
        } else {
            chordLabel = chordClassification.identifier
        }
        confidenceLabel = "\(Int(chordClassification.confidence * 100)) %"
    }
}
