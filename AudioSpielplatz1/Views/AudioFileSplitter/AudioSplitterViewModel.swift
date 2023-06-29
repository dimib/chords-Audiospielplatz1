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
    @Published var audioFilePath: String = ""
    @Published var audioAnalyzerData: AudioAnalyzerData = .zero
    
    init() {
        sessionDirectory = AppConfiguration().config.sessionDirectory ?? ""
    }
    
    func setSessionDirectory(_ sessionDirectory: URL) {
        self.sessionDirectory = sessionDirectory.absoluteString
    }
    
    func setAudioFilePath(url: URL) {
        audioFilePath = url.absoluteString
    }
    
    func splitAudioFile() {
        do {
            guard let url = URL(string: audioFilePath) else { return }
            let splitter = try AudioFileSplitter(input: url, outputPath: url, seconds: 1)
            splitter.splitAudioFile()
            debugPrint("Done.")
        } catch {
            debugPrint("Error: \(error.localizedDescription)")
        }
    }
}
