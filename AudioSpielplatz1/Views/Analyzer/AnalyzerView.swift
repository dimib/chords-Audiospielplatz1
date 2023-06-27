//
//  AnalyzerView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 27.06.23.
//

import SwiftUI
import Combine

struct AnalyzerView: View {
    @Environment(\.controlActiveState) private var controlActiveState
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel = AnalyzerViewModel()
    
    var body: some View {
        VStack {
            WaveView(data: viewModel.audioData)
                .frame(height: 120)
            VolumeView(data: viewModel.audioData)
                .frame(height: 40)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { newValue in
            debugPrint("🪟 close \(newValue)")
            viewModel.stopAnalyze()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification)) { newValue in
            debugPrint("🪟 didbecomemain \(newValue)")
            viewModel.startAnalyze()
        }
    }
}

class AnalyzerViewModel: ObservableObject {
    
    @Published var audioData: AudioAnalyzerData = .zero
    
    private let audioStreamManager = AudioStreamManager()
    private let audioAnalyzer = AudioAnalyzer()
    
    private var cancellables = Set<AnyCancellable>()
    
    func startAnalyze() {
        print("🎙️ start analyze")
        do {
            try audioStreamManager.setupCaptureSession()
            try audioAnalyzer.setupAnalyzer(audioStream: audioStreamManager.audioStream)
            
            audioAnalyzer.publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { error in
                }) { audioAnalyzerData in
                    self.audioData = audioAnalyzerData
                }
                .store(in: &cancellables)
            
            try audioStreamManager.start()
        } catch {
            print("☠️ analyzer not started, error=\(error)")
        }
    }
    
    func stopAnalyze() {
        print("🎙️ stop analyze")
        audioStreamManager.stop()
    }
}

struct AnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyzerView()
            .frame(width: 300, height: 100)
    }
}
