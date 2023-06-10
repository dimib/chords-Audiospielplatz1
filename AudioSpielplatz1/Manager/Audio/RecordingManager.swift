//
//  AudioManager.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 10.06.23.
//

import Foundation
import AVFoundation

/// This manager will handle all audio recording stuff.
final class RecordingManager: NSObject, ObservableObject {
    
    enum RecordingManagerState {
        case idle
        case recording(filename: String)
        case error(message: String)
    }
    
    private let bitRate = 192000
    private let sampleRate = 44100.0
    private let channels = 1
    
    static var directory: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    private var recorder: AVAudioRecorder?
    
    private(set) var outputUrl: URL?
    
    @Published var recordingManagerState: RecordingManagerState = .idle
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
            }
            return isAuthorized
        }
    }
    
    func setupCaptureSession(output filename: String) async throws {
        guard await isAuthorized else { return }
        
        let settings: [String: AnyObject] = [
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatLinearPCM)),
            // Change below to any quality your app requires
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue as AnyObject,
            AVEncoderBitRateKey: bitRate as AnyObject,
            AVNumberOfChannelsKey: channels as AnyObject,
            AVSampleRateKey: sampleRate as AnyObject
        ]
        
        guard let outputUrl = NSURL(fileURLWithPath: Self.directory).appendingPathComponent("\(filename).wav") else {
            throw AudioManagersError.illegalOutputFile
        }
        
        let recorder = try AVAudioRecorder(url: outputUrl, settings: settings)
        recorder.delegate = self
        recorder.prepareToRecord()
        self.recorder = recorder
        self.outputUrl = outputUrl
    }
    
    func startRecording() async throws {
        guard let recorder else { throw AudioManagersError.illegalState }
        recorder.record()
        recordingManagerState = .recording(filename: outputUrl?.absoluteString ?? "")
    }
    
    func stopRecording() {
        guard let recorder else { return }
        recorder.stop()
    }
}

extension RecordingManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        debugPrint("🎙️ recording successful.")
        recordingManagerState = .idle
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        debugPrint("🎙️ recording error: \(error?.localizedDescription ?? "unknown")")
        recordingManagerState = .error(message: error?.localizedDescription ?? "unknown")
    }
}
