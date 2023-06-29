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
                .frame(minHeight: 120)
            VolumeView(data: viewModel.audioData)
                .frame(height: 40)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .onChange(of: controlActiveState) { newValue in
            switch newValue {
            case .key, .active:
                debugPrint(newValue)
                viewModel.startAnalyze()
            case .inactive:
                debugPrint(newValue)
                viewModel.stopAnalyze()
            @unknown default:
                break
            }
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
