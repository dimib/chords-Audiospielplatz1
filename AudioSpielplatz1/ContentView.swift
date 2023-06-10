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
            
            Spacer()
            VStack {
                PlayerControlsView(playerState: appState.state) { action in
                    switch action {
                    case .play:
                        appState.startPlaying()
                    case .record:
                        appState.startRecording()
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
