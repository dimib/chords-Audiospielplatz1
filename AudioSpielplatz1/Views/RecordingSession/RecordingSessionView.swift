//
//  RecordingSessionView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import SwiftUI

/// This view is the container for recording session.
struct RecordingSessionView: View {
    
    @Environment(\.openWindow) var openWindow
    
    @StateObject var viewModel = RecordingSessionViewModel()
    
    @State var audioAnalyzerData = AudioAnalyzerData(min: -2, max: 2.0, time: 400, frameLength: 0, channelCount: 0, samples: [])
    
    var body: some View {
        VStack {
            Grid(alignment: .leading, verticalSpacing: 0) {
                GridRow(alignment: .center) {
                    Button(action: {
                        chooseSessionDirectory()
                    }, label: {
                        Image(systemName: "folder")
                            .imageScale(.large)
                    }).buttonStyle(.plain)

                    Text("\(viewModel.sessionDirectory)")
                        .font(.headline)
                }
                .frame(height: 20)
                .padding(10)
                
                GridRow(alignment: .center) {
                    Button(action: {
                        chooseSessionTemplate()
                    } , label: {
                        Image(systemName: "doc.plaintext")
                            .imageScale(.large)
                    }).buttonStyle(.plain)

                    Text("\(viewModel.sessionTemplate)")
                        .font(.headline)
                }
                .frame(height: 20)
                .padding(10)
            }
            .border(Color.white)
            .padding(.top, 20)
            .padding(.horizontal, 12)
            
            // -- Chords to play
            
            HStack {
                VStack {
                    Text(viewModel.previousChord)
                        .foregroundColor(Color.black)
                        .font(Font.system(size: 60))
                }
                .frame(width: 180, height: 180)
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)

                VStack {
                    Text(viewModel.currentChord)
                        .foregroundColor(Color.black)
                        .font(Font.system(size: 100))
                }
                .frame(width: 240, height: 240)
                .background(Color.white.opacity(0.8))
                .cornerRadius(24)

                VStack {
                    Text(viewModel.nextChord)
                        .foregroundColor(Color.black)
                        .font(Font.system(size: 60))
                }
                .frame(width: 180, height: 180)
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
            }

            DurationView(max: viewModel.timeExpected, current: viewModel.timeRecorded)
                .frame(width: 600, height: 42)

            VolumeView(data: viewModel.audioAnalyzerData)
                .frame(width: 600, height: 42)
            
            VStack {
                Text(viewModel.recordingState)
                    .foregroundColor(Color.black)
            }
            .frame(width: 600, height: 42)
            .background(Color.white)
            .cornerRadius(12)
            
            Spacer()
            // -- Player Controls --
            VStack {
                PlayerControlsView(playerState: viewModel.playerState,
                                   buttonSize: CGSize(width: 48, height: 48)) { action in
                    switch action {
                    case .record:
                        viewModel.startRecordingSession()
                    case .stop:
                        viewModel.stopRecordingSession()
                    default: break
                    }
                }
            }
            .padding(.bottom, 12)
        }
    }

    @MainActor
    private func chooseSessionDirectory() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            viewModel.setSessionDirectory(url)
        }
    }
    
    private func chooseSessionTemplate() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            viewModel.setSessionTemplate(url)
        }
    }
    
    /// Open an existing session
    init(open: String) {
    }
    
    /// Create a new recording session
    init() {
        print("Recording Session")
    }
}

struct RecordingSessionView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingSessionView()
            .frame(width: 1200, height: 800)
    }
}
