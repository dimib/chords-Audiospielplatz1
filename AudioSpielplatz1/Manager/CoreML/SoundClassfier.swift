//
//  SoundClassfier.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 11.06.23.
//

import Foundation
import AVFoundation
import Combine

enum SoundClassifierState {
    case idle
    case running
    case error(message: String)
}

protocol SoundClassifier: AnyObject {
    var soundClassifierState: AnyPublisher<SoundClassifierState, Never> { get }
}
