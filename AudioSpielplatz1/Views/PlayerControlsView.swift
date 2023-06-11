//
//  PlayerView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import SwiftUI

struct PlayerControlsView: View {
    
    typealias PlayerControlsActionCallback = (PlayerAction) -> Void
        
    var playerState: PlayerState

    let actionCallback: PlayerControlsActionCallback
    
    var body: some View {
        HStack {
            PlayerButton(buttonType: .backward) {
                actionCallback(.backward)
            }
            PlayerButton(buttonType: .analyze(playerState == .analyzing)) {
                actionCallback(.analyze)
            }
            PlayerButton(buttonType: .record(playerState == .recording)) {
                actionCallback(.record)
            }
            PlayerButton(buttonType: .play(playerState == .playing)) {
                actionCallback(.play)
            }
            PlayerButton(buttonType: .stop(playerState == .idle)) {
                actionCallback(.stop)
            }
            PlayerButton(buttonType: .forward) {
                actionCallback(.forward)
            }
        }
    }
    
    init(playerState: PlayerState,
         actionCallback: @escaping PlayerControlsActionCallback) {
        self.playerState = playerState
        self.actionCallback = actionCallback
    }
}

struct PlayerButton: View {
    
    let buttonType: ButtonType
    let action: (() -> Void)
    
    enum ButtonType {
        case record(Bool)
        case play(Bool)
        case stop(Bool)
        case analyze(Bool)
        case forward
        case backward
        
        var imageName: String {
            switch self {
            case .record(let active):
                return active ? "record.circle.fill" : "record.circle"
            case .analyze(let active):
                return active ? "waveform.circle.fill" : "waveform.circle"
            case .play(let active):
                return active ? "play.fill" : "play"
            case .stop(let active):
                return active ? "stop.fill" : "stop"
            case .forward:
                return "forward"
            case .backward:
                return "backward"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Button(action: { action() }, label: {
                Image(systemName: buttonType.imageName)
                    .resizable()
            })
            .buttonStyle(.plain)
            .padding(10)
            .frame(width: 40, height: 40)
        }
    }
    
    init(buttonType: ButtonType, action: @escaping () -> Void) {
        self.buttonType = buttonType
        self.action = action
    }
}

/*
struct PlayerView_Previews: PreviewProvider {
    @State var playerState: PlayerState = .idle
    static var previews: some View {
        PlayerControlsView(playerState: playerState) { _ in
        }
    }
}
*/
