//
//  AudioAnalyzerData.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 19.06.23.
//

import Foundation

struct AudioAnalyzerData {
    let min: Float
    let max: Float
    let time: Int64
    
    static var zero = AudioAnalyzerData(min: 0, max: 0, time: 0)
}
