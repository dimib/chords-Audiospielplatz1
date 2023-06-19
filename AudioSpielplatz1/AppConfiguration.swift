//
//  AppConfiguration.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 11.06.23.
//

import Foundation

struct AppConfiguration {
    
    // MARK: - Audio Classifier (from Sample)

    /// Indicates the amount of audio, in seconds, that informs a prediction.
    static var inferenceWindowSize: Double = 1.5
    
    /// The amount of overlap between consecutive analysis windows.
    ///
    /// The system performs sound classification on a window-by-window basis. The system divides an
    /// audio stream into windows, and assigns labels and confidence values. This value determines how
    /// much two consecutive windows overlap. For example, 0.9 means that each window shares 90% of
    /// the audio that the previous window uses.
    static var overlapFactor: Double = 0.9
}