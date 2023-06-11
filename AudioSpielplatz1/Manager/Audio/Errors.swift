//
//  Errors.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import Foundation

enum AudioManagersError: Error {
    case illegalOutputFile
    case illegalInputFile
    case illegalState
    case finished
}
