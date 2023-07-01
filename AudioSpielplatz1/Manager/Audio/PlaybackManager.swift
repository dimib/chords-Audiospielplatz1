//
//  PlaybackManager.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import Foundation
import AVFoundation

final class PlaybackManager: NSObject, ObservableObject {
    
    enum PlaybackManagerState {
        case idle
        case playing(filename: String)
        case error(message: String)
    }
    
    private var audioPlayer: AVAudioPlayer?
    private(set) var inputUrl: URL?
    
    @Published var playbackManagerState: PlaybackManagerState = .idle
    
    func setupPlayerSession(input filename: String) throws {
        guard let inputUrl = NSURL(fileURLWithPath: RecordingManager.directory).appendingPathComponent("\(filename).wav") else {
            throw AudioManagerError.illegalInputFile
        }
        self.inputUrl = inputUrl
    }
    
    func startPlaying() throws {
        guard let inputUrl else { throw AudioManagerError.illegalState }
        let player = try AVAudioPlayer(contentsOf: inputUrl)
        player.delegate = self
        player.play()
        self.audioPlayer = player
        playbackManagerState = .playing(filename: inputUrl.absoluteString)
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

extension PlaybackManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbackManagerState = .idle
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        playbackManagerState = .error(message: error?.localizedDescription ?? "Unknown")
    }
}
