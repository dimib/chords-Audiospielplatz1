//
//  ClassificationResult.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 11.06.23.
//

import Foundation

struct ClassificationResult {
    let items: [ClassificationItem]
}

struct ClassificationItem {
    let identifier: String
    let confidence: Double
}
