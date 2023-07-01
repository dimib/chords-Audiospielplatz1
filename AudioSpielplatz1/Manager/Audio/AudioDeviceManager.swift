//
//  AudioDeviceManager.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 22.06.23.
//

// Taken from https://stackoverflow.com/questions/75850835/how-to-get-the-list-of-input-devices-on-macos-using-coreaudio

import Foundation
import AVFoundation
import CoreAudio

struct AudioDevice {
    let id: AudioDeviceID
    let name: String
    let inputChannels: UInt32
    let outputChannels: UInt32
    
    var description: String {
        "\(id) \(name) inputChannels=\(inputChannels) outputChannels=\(outputChannels)"
    }
}

final class AudioDeviceManager {
    
    private let audioEngine = AVAudioEngine()
    
    private(set) var devices: [AudioDevice] = []
    
    func updateDevices() throws {
        var propertySize: UInt32 = 0
        var status: OSStatus = noErr
        var propertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices,
                                                         mScope: kAudioObjectPropertyScopeGlobal,
                                                         mElement: kAudioObjectPropertyElementMain)
        status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
        guard status == noErr else { throw AudioManagerError.audioDevice(status) }
        
        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        var deviceIds = [AudioDeviceID](repeating: 0, count: deviceCount)
        status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &deviceIds)
        guard status == noErr else { throw AudioManagerError.audioDevice(status) }
        
        for deviceId in deviceIds {
            var deviceName = ""
            var inputChannels:UInt32 = 0
            var outputChannels: UInt32 = 0
            
            // Read device name
            propertyAddress.mSelector = kAudioDevicePropertyDeviceNameCFString
            propertySize = UInt32(MemoryLayout<CFString>.size)
            var name: CFString? = nil
            status = AudioObjectGetPropertyData(deviceId, &propertyAddress, 0, nil, &propertySize, &name)
            if status == noErr, let deviceNameCF = name as? String {
                deviceName = deviceNameCF
            }
            
            // Read input devices
            propertyAddress.mSelector = kAudioDevicePropertyStreamConfiguration
            propertyAddress.mScope = kAudioDevicePropertyScopeInput
            if AudioObjectGetPropertyDataSize(deviceId, &propertyAddress, 0, nil, &propertySize) == noErr {
                let bufferListPointer = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
                defer { bufferListPointer.deallocate() }
                if AudioObjectGetPropertyData(deviceId, &propertyAddress, 0, nil, &propertySize, bufferListPointer) == noErr {
                    let bufferList = UnsafeMutableAudioBufferListPointer(bufferListPointer)
                    inputChannels = bufferList.reduce(0, { partialResult, buffer in
                        return partialResult + buffer.mNumberChannels
                    })
                }
            }
            
            propertyAddress.mScope = kAudioDevicePropertyScopeOutput
            if AudioObjectGetPropertyDataSize(deviceId, &propertyAddress, 0, nil, &propertySize) == noErr {
                let bufferListPointer = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
                defer { bufferListPointer.deallocate() }
                if AudioObjectGetPropertyData(deviceId, &propertyAddress, 0, nil, &propertySize, bufferListPointer) == noErr {
                    let bufferList = UnsafeMutableAudioBufferListPointer(bufferListPointer)
                    outputChannels = bufferList.reduce(0, { partialResult, buffer in
                        return partialResult + buffer.mNumberChannels
                    })
                }
            }
            devices.append(AudioDevice(id: deviceId, name: deviceName, inputChannels: inputChannels, outputChannels: outputChannels))
        }
    }
    
    func setDefault(audioDevice: AudioDevice) throws {
        var deviceId = Int(audioDevice.id)
        guard let audioUnit = audioEngine.inputNode.audioUnit else { throw AudioManagerError.audioDevice(-1) }
        let status = AudioUnitSetProperty(audioUnit, AudioUnitPropertyID(kAudioOutputUnitProperty_CurrentDevice),
                                         AudioUnitScope(kAudioUnitScope_Input), 0,
                                         &deviceId, UInt32(MemoryLayout<AudioDeviceID>.size))
        guard status == noErr else { throw AudioManagerError.audioDevice(status) }
    }
 
    func enableInput(bus: AudioUnitElement, enable: Bool = true) throws {
        guard let audioUnit = audioEngine.inputNode.audioUnit else { throw AudioManagerError.audioDevice(-1) }
        var enableInput: UInt32 = enable ? 1 : 0
        
        let status = AudioUnitSetProperty(audioUnit, AudioUnitPropertyID(kAudioOutputUnitProperty_EnableIO),
                                          AudioUnitScope(kAudioUnitScope_Input), bus, &enableInput, UInt32(MemoryLayout<UInt32>.size))
        guard status == noErr else { throw AudioManagerError.audioDevice(status) }
    }
    
}
