//
//  CustomSoundClassifierConfiguration.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 04.07.23.
//

import Foundation
import CoreML

final class CustomSoundClassifierConfiguration {
    let model: MLModel
    let translation: [String: String]

    // MARK: - Classifier configuration parameters

    /// Indicates the amount of audio, in seconds, that informs a prediction.
    var inferenceWindowSize: Double = 1.0
    
    /// The amount of overlap between consecutive analysis windows.
    ///
    /// The system performs sound classification on a window-by-window basis. The system divides an
    /// audio stream into windows, and assigns labels and confidence values. This value determines how
    /// much two consecutive windows overlap. For example, 0.9 means that each window shares 90% of
    /// the audio that the previous window uses.
    var overlapFactor: Double = 0.5
    
    /// See `CMTimeMakeWithSeconds`
    var preferredTimescale: Int32 = 44_100
    
    // MARK: - Audio stream properties
    
    var minimumVolume: Float = 0.00

    // MARK: - Create models
    
    static func makeChordsConfig() throws -> CustomSoundClassifierConfiguration {
        try makeChords52()
    }

    static func makeChords52() throws -> CustomSoundClassifierConfiguration {
        let modelConfiguration = MLModelConfiguration()
        let chordClassifierModel = try Chords52(configuration: modelConfiguration).model
        return CustomSoundClassifierConfiguration(model: chordClassifierModel, translation: Self.chordsTranslation)
    }

    static func makeChords2a() throws -> CustomSoundClassifierConfiguration {
        let modelConfiguration = MLModelConfiguration()
        let chordClassifierModel = try Chords2a(configuration: modelConfiguration).model
        return CustomSoundClassifierConfiguration(model: chordClassifierModel, translation: Self.chordsTranslation)
    }

    static func makeChords3a() throws -> CustomSoundClassifierConfiguration {
        let modelConfiguration = MLModelConfiguration()
        let chordClassifierModel = try Chords3a(configuration: modelConfiguration).model
        return CustomSoundClassifierConfiguration(model: chordClassifierModel, translation: Self.chordsTranslation)
    }

    private init(model: MLModel, translation: [String : String]) {
        self.model = model
        self.translation = translation
    }
}
