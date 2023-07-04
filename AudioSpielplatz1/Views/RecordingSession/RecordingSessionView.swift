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
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button(action: {
                        chooseSessionDirectory()
                    }, label: {
                        Image(systemName: "folder")
                            .imageScale(.large)
                    })
                    .buttonStyle(.plain)
                    .frame(width: 40)

                    Text("\(viewModel.sessionDirectory)")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
                
                HStack {
                    Button(action: {
                        chooseSessionTemplate()
                    } , label: {
                        Image(systemName: "doc.plaintext")
                            .imageScale(.large)
                    })
                    .buttonStyle(.plain)
                    .frame(width: 40)

                    Text("\(viewModel.sessionTemplate)")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
            .border(Color.gray)
            .padding(5)

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
        RecordingSessionHelper.chooseDirectory { directory in
            viewModel.setSessionDirectory(directory)
        }
    }
    
    private func chooseSessionTemplate() {
        RecordingSessionHelper.chooseFile { url in
            viewModel.setSessionTemplate(url)
        }
    }
    
    /// Open an existing session
    init(open: String) {
    }
    
    /// Create a new recording session
    init() {
    }
}

struct RecordingSessionView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingSessionView()
            .frame(width: 1200, height: 800)
    }
}
