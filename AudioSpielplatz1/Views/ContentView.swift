//
//  ContentView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var appState = ApplicationState()

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "waveform")
                Text("Audio Spielplatz Eins")
            }
            .padding()
            
            VStack {
                Text(appState.message)
            }
            VStack {
                VolumeView(data: appState.analyzerData)
                    .frame(width: 200, height: 50)
            }
            VStack {
                WaveView(data: appState.analyzerData)
                    .frame(width: 400,  height: 200)
            }
            
            Spacer()
            VStack {
                PlayerControlsView(playerState: appState.state) { action in
                    switch action {
                    case .play:
                        appState.startPlaying()
                    case .record:
                        appState.startRecording()
                    case .analyze:
                        appState.startAnalyze()
                    case .stop:
                        appState.stop()
                    case .forward: break
                    case .backward: break
                    }
                }
            }
            .padding(10)
            .border(.white)
        }
        .padding(.bottom, 10)
        .frame(width: 300, height: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
