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
    @Published var outputDirectory: String = ""
    @Published var audioAnalyzerData: AudioAnalyzerData = .zero
    @Published var inputFiles: [String] = []
    @Published var splitProgress: Double = 0.0
    
    init() {
        sessionDirectory = AppConfiguration().config.sessionDirectory ?? ""
        outputDirectory = AppConfiguration().config.splitterOutputDirectory ?? ""
        if !sessionDirectory.isEmpty {
            readSessionDirectory()
        }
    }
    
    func setSessionDirectory(_ sessionDirectory: String) {
        self.sessionDirectory = sessionDirectory
        readSessionDirectory()
    }
    
    func setOutputDirectory(_ outputDirectory: String) {
        self.outputDirectory = outputDirectory
    }
    
    var splitter: AudioFileSplitter?
    
    func splitAudioFiles() {
        
        guard !inputFiles.isEmpty, !outputDirectory.isEmpty else { return }
        
        Task {
            let numberOfFiles = Double(self.inputFiles.count)
            
            inputFiles.enumerated().forEach { (index, element) in
                let percentDone = Double(index + 1) / numberOfFiles
                debugPrint("File: \(index) \(element) \(percentDone)")
                DispatchQueue.main.async { self.splitProgress = percentDone }
                do {
                    let audioFileURL = URL(fileURLWithPath: element)
                    let outputFilePath = element.replacingOccurrences(of: sessionDirectory, with: outputDirectory)
                    let outputPathURL = URL(fileURLWithPath: outputFilePath).deletingLastPathComponent()
                    splitter = try AudioFileSplitter(audioFile: audioFileURL, outputPath: outputPathURL, seconds: 1)
                    try splitter?.splitAudioFile()
                } catch {
                    //
                }
            }
        }
        
    }
    
    private func readSessionDirectory() {
        let files = readDirectory(path: sessionDirectory)
        self.inputFiles = files
    }
    
    private func readDirectory(path: String) -> [String] {
        do {
            let content = try FileManager.default.contentsOfDirectory(atPath: path).filter { $0.starts(with: ".") == false }
            
            let directories = content.filter { item in
                var isDirectory: ObjCBool = false
                let fileExists = FileManager.default.fileExists(atPath: absolutePath(path, item),
                                                                isDirectory: &isDirectory)
                return fileExists && isDirectory.boolValue == true
            }

            var files: [String] = content.filter { item in
                var isDirectory: ObjCBool = false
                let fileExists = FileManager.default.fileExists(atPath: absolutePath(path, item), isDirectory: &isDirectory)
                return fileExists && isDirectory.boolValue == false
            }.map { absolutePath(path, $0) }

            let moreFiles: [String] = directories.flatMap { directory in
                return readDirectory(path: absolutePath(path, directory))
            }
            
            files.append(contentsOf: moreFiles)
            
            return files
        } catch {
            debugPrint("☠️ error \(error.localizedDescription)")
            return []
        }
    }
    
    private func absolutePath(_ path: String, _ file: String) -> String {
        path.hasSuffix("/") ? "\(path)\(file)" : "\(path)/\(file)"
    }
}
