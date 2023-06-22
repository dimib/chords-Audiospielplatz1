//
//  AudioAnalyzer.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 19.06.23.
//

import Foundation
import Combine
import AVFoundation

// Notes:
// Sample audio engine
// https://github.com/maysamsh/avaudioengine/tree/main/audioEngine
// Visualize
// https://karenxpn.medium.com/audio-visualization-using-swift-swiftui-ffbf9aa8d577
final class AudioAnalyzer {
    
    private var cancellable: AnyCancellable?
    
    private let _analyzerValues = PassthroughSubject<AudioAnalyzerData, Never>()
    var publisher: AnyPublisher<AudioAnalyzerData, Never> {
        _analyzerValues.eraseToAnyPublisher()
    }
    
    func setupAnalyzer(audioStream: AnyPublisher<AudioData, AudioManagersError>) throws {
    
        cancellable = audioStream.sink(
            receiveCompletion: { error in
                self.cleanup()
            }, receiveValue: { audioData in
                
                let time = audioData.when.sampleTime
                let frameLength = audioData.buffer.frameLength
                let channelCount = audioData.buffer.format.channelCount
                
                let arraySize = Int(audioData.buffer.frameLength)
                guard let channelData = audioData.buffer.floatChannelData else { return }
                let samples: [Float] = Array(UnsafeBufferPointer(start: channelData[0], count: arraySize))
                let minmax: (Float, Float) = samples.reduce((0, 0)) { result, value in
                    let min = min(result.0, value)
                    let max = max(result.1, value)
                    return (min, max)
                }
            
                debugPrint("\(time) channels=\(channelCount) length=\(frameLength) min=\(minmax.0) max=\(minmax.1)")
                
                self._analyzerValues.send(AudioAnalyzerData(min: minmax.0, max: minmax.1, time: time, samples: samples))
            })
    }
    
    private func cleanup() {
        self._analyzerValues.send(AudioAnalyzerData(min: 0.0, max: 0.0, time: 0, samples: []))
        cancellable = nil
    }
}
