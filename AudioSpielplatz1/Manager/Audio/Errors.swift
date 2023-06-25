//
//  Errors.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import Foundation

enum AudioManagersError: Error, Equatable {
    case illegalOutputFile
    case illegalInputFile
    case illegalState
    case notAuthorized
    case finished
    case audioDevice(OSStatus)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.illegalOutputFile, .illegalOutputFile),
            (.illegalInputFile, .illegalInputFile),
            (.illegalState, .illegalState),
            (.notAuthorized, .notAuthorized),
            (.finished, .finished): return true
        case (.audioDevice(let lstatus), .audioDevice(let rstatus)):
            return lstatus == rstatus
        default: return false
        }
    }
}
