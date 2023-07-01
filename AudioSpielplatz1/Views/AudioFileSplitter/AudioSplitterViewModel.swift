//
//  AudioSplitterViewModel.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 28.06.23.
//

import Foundation
import AudioToolbox

final class AudioSplitterViewModel: ObservableObject {
    
    @Published var sessionDirectory: String = ""
    @Published var audioFilePath: String = "" {
        didSet {
            AppConfiguration().config.splitterCurrentFile = audioFilePath
        }
    }
    @Published var audioAnalyzerData: AudioAnalyzerData = .zero
    
    init() {
        sessionDirectory = AppConfiguration().config.sessionDirectory ?? ""
        audioFilePath = AppConfiguration().config.splitterCurrentFile ?? ""
    }
    
    func setSessionDirectory(_ sessionDirectory: String) {
        self.sessionDirectory = sessionDirectory
    }
    
    func setAudioFilePath(_ path: String) {
        audioFilePath = path
    }
    
    var splitter: AudioFileSplitter?
    
    func splitAudioFile() {
        do {
            let audioFileURL = URL(fileURLWithPath: audioFilePath)
            let outputPathURL = URL(fileURLWithPath: sessionDirectory)
            splitter = try AudioFileSplitter(audioFile: audioFileURL, outputPath: outputPathURL, seconds: 1)
            try splitter?.splitAudioFile()
        } catch {
            debugPrint("Error: \(error.localizedDescription)")
        }
    }
}
