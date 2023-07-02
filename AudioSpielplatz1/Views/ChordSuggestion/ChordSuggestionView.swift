//
//  ChordSuggestionView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 02.07.23.
//

import SwiftUI

struct ChordSuggestionView: View {
    @Environment(\.controlActiveState) private var controlActiveState
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel = ChordSuggestionViewModel()
    
    var body: some View {
        VStack {
            VStack {
                Text("")
                    .foregroundColor(Color.black)
                    .font(Font.system(size: 200))
            }
            .frame(minWidth: 400, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
            .background(Color.white.opacity(0.8))
            .cornerRadius(24)
            
            VStack {
                VolumeView(data: viewModel.analyzerData)
            }
            .frame(height: 42)
            
        }
        .frame(minWidth: 450, minHeight: 450)
        .padding(24)
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

struct ChordSuggestionView_Previews: PreviewProvider {
    @State var playerState: PlayerState = .idle
    static var previews: some View {
        ChordSuggestionView()
    }
}
