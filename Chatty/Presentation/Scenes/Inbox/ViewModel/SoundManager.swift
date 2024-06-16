//
//  SoundManager.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import AVFAudio
import Foundation

class SoundManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?

    func playSound(sound: String) {
        guard let url = URL(string: sound) else {
            print("Invalid URL for audio file")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
