//
//  Storable.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation

protocol Storable: Codable {
    static var resourceExtension: String { get }
}

extension Storable {
    static var resourceExtension: String { "json" }
}
