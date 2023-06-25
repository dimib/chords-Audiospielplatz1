//
//  PlayerView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import SwiftUI

struct PlayerControlsView: View {
    
    static let defaultButtonSize = CGSize(width: 40, height: 40)
    
    typealias PlayerControlsActionCallback = (PlayerAction) -> Void
        
    var playerState: PlayerState

    let actionCallback: PlayerControlsActionCallback
    
    let buttonSize: CGSize
    
    var body: some View {
        HStack {
            PlayerButton(buttonType: .backward, size: buttonSize) {
                actionCallback(.backward)
            }
            PlayerButton(buttonType: .analyze(playerState == .analyzing), size: buttonSize) {
                actionCallback(.analyze)
            }
            PlayerButton(buttonType: .record(playerState == .recording), size: buttonSize) {
                actionCallback(.record)
            }
            PlayerButton(buttonType: .play(playerState == .playing), size: buttonSize) {
                actionCallback(.play)
            }
            PlayerButton(buttonType: .stop(playerState == .idle), size: buttonSize) {
                actionCallback(.stop)
            }
            PlayerButton(buttonType: .forward, size: buttonSize) {
                actionCallback(.forward)
            }
        }
    }
    
    init(playerState: PlayerState,
         buttonSize: CGSize = PlayerControlsView.defaultButtonSize,
         actionCallback: @escaping PlayerControlsActionCallback) {
        self.playerState = playerState
        self.buttonSize = buttonSize
        self.actionCallback = actionCallback
    }
}

struct PlayerButton: View {
    
    let buttonSize: CGSize
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
            .frame(width: buttonSize.width, height: buttonSize.height)
        }
    }
    
    init(buttonType: ButtonType, size: CGSize = PlayerControlsView.defaultButtonSize, action: @escaping () -> Void) {
        self.buttonType = buttonType
        self.buttonSize = size
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
