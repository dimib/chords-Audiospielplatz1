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
        min(200, CGFloat(data.max) * 255)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path  in
                    path.move(to: CGPoint(x: 5, y: 5))
                    path.addLine(to: CGPoint(x: volumeWidth, y: 5))
                    path.addLine(to: CGPoint(x: volumeWidth, y: geometry.size.height - 5))
                    path.addLine(to: CGPoint(x: 5, y: geometry.size.height - 5))
                    path.addLine(to: CGPoint(x: 5, y: 5))
                }
                .fill(Color.green)
            }
            .background(Color.black)
            .border(Color.gray)
        }
    }
}

struct VolumeView_Previews: PreviewProvider {
    @State var playerState: PlayerState = .idle
    static var previews: some View {
        VolumeView(data: AudioAnalyzerData(min: -3.0, max: 1.0, time: 0, samples: []))
    }
}
