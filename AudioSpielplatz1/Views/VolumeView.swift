//
//  VolumeView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 19.06.23.
//

import SwiftUI

struct VolumeView: View {
    
    let data: AudioAnalyzerData
    
    var volumeWidth: CGFloat {
        min(100, CGFloat(data.max) * 255)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(.green)
                .frame(width: volumeWidth, height: 50)
        }
    }
}

struct VolumeView_Previews: PreviewProvider {
    @State var playerState: PlayerState = .idle
    static var previews: some View {
        VolumeView(data: AudioAnalyzerData(min: -3.0, max: 1.0, time: 0))
    }
}
