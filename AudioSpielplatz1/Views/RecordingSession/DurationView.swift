//
//  DurationView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import SwiftUI

struct DurationView: View {
    
    let max: Double
    let current: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                durationPath(size: geometry.size)
                Text("\(Int(current)) / \(Int(max))")
                    .font(.title)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .border(Color.white)
            
        }
    }
    
    private func durationPath(size: CGSize) -> some View {
        
        let width: CGFloat = size.width - 10
        let pointX: CGFloat = width / CGFloat(max) * CGFloat(current)
        
        return Path { path  in
            path.move(to: CGPoint(x: 5, y: 5))
            path.addLine(to: CGPoint(x: pointX, y: 5))
            path.addLine(to: CGPoint(x: pointX, y: size.height - 5))
            path.addLine(to: CGPoint(x: 5, y: size.height - 5))
            path.addLine(to: CGPoint(x: 5, y: 5))
        }
        .fill(Color.white.opacity(0.5))

    }
}

struct DurationView_Previews: PreviewProvider {
    static var previews: some View {
        DurationView(max: 60, current: 30)
            .frame(width: 600, height: 32)
    }
}
