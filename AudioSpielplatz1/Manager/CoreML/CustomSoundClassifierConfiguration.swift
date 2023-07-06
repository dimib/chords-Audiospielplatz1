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
    
    static func makeChordsClassifier4() throws -> CustomSoundClassifierConfiguration {
        let modelConfiguration = MLModelConfiguration()
        let chordClassifierModel = try ChordsClassifier4(configuration: modelConfiguration).model
        return CustomSoundClassifierConfiguration(model: chordClassifierModel, translation: [:])
    }

    static func makeChordsClassifier5() throws -> CustomSoundClassifierConfiguration {
        let modelConfiguration = MLModelConfiguration()
        let chordClassifierModel = try ChordsClassifier5a(configuration: modelConfiguration).model
        return CustomSoundClassifierConfiguration(model: chordClassifierModel, translation: [:])
    }
    private init(model: MLModel, translation: [String : String]) {
        self.model = model
        self.translation = translation
    }
}
