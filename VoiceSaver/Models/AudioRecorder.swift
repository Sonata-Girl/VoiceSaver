//
//  AudioRecorder.swift
//  VoiceSaver
//
//  Created by Sonata Girl on 02.10.2023.
//

import UIKit
import AVFAudio

class AudioRecorder {
    private var audioRecorder: AVAudioRecorder?
    var audioURL: URL?
    
    private var audioFileExtension = ".m4a"
   
    lazy var permissionGranted = false

    func requestPermission() -> Bool {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted: Bool) in
            if granted {
                self.permissionGranted = true
            } 
        }
        return permissionGranted
    }
    
    func startRecording() {
        guard permissionGranted else { return }
        let fileName = UUID().uuidString
        audioURL = getDocumentsDirectory().appendingPathComponent("\(fileName)\(audioFileExtension)")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.record)
            try AVAudioSession.sharedInstance().setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Error recording audio: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() -> String? {
        audioRecorder?.stop()
        return saveAudioRecording(recordURL: audioURL!)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func saveAudioRecording(recordURL: URL) -> String? {
//        let documentsDirectory = getDocumentsDirectory()
        let fileName = recordURL.absoluteString
        
        do {
            let data = try Data(contentsOf: recordURL)
            
            if FileManager.default.fileExists(atPath: recordURL.path) {
                do {
                    try FileManager.default.removeItem(at: recordURL)
                    print("Removed old file")
                } catch let error {
                    print("Couldn't remove old file with error: \(error.localizedDescription)")
                }
            }
            
            try data.write(to: recordURL)
            return fileName
        } catch let error {
            print("Error saving file with error: \(error.localizedDescription)")
            return nil
        }
    }
    
}
