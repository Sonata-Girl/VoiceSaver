//
//  AudioPlayer.swift
//  VoiceSaver
//
//  Created by Sonata Girl on 02.10.2023.
//

import UIKit
import AVFAudio

class AudioPlayer {
    private var audioPlayer: AVAudioPlayer?
    
    func startPlaying(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if let player = audioPlayer {
                player.numberOfLoops = 0
                player.play()
            }
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
    }
    
    func isPlaying() -> Bool? {
        return audioPlayer?.isPlaying
    }
}
