//
//  ViewController.swift
//  VoiceSaver
//
//  Created by Sonata Girl on 02.10.2023.
//

import UIKit
import AVFAudio

class ViewController: UIViewController {
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var audioURL: URL?
    
    private lazy var recordStarted = false
    private lazy var playStarted = false
    private var timer: Timer?
    private lazy var startTime: TimeInterval = 0.0
       
    private let startRecordImage = UIImage(named: "startRecord")
    private let stopRecordImage = UIImage(named: "stopRecord")
    
    private let startPlayImage = UIImage(named: "startPlay")
    private let stopPlayImage = UIImage(named: "stopPlay")
    
    private lazy var recordButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = startRecordImage
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(startRecordPressed))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var playButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = startPlayImage
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(startPlayPressed))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.font = UIFont.systemFont(ofSize: 50, weight: .black)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() 
    }

    private func setupUI() {
        view.addSubview(recordButton)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 50),
            recordButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            recordButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            recordButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3)
        ])
        
        view.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height / 3),
            timeLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        view.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            playButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3)
        ])
    }

    @objc func startRecordPressed() {
        guard !playStarted else { return }
        recordStarted = !recordStarted
        if recordStarted {
            recordButton.image = stopRecordImage
            timeLabel.text = "00:00:00"
            timeLabel.textColor = .red
            startRecord()
        } else {
            recordButton.image = startRecordImage
            timeLabel.textColor = .white
            timer?.invalidate()
            stopRecord()
        }
    }
    
    func startRecord() {
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        recordSound()
    }
    
    func stopRecord() {
        audioRecorder?.stop()
        let nameFile = saveRecord(recordURL: audioURL!)
    }
    
    @objc func startPlayPressed() {
        guard !recordStarted, audioURL != nil else { return }
        playStarted = !playStarted
        if playStarted {
            playButton.image = stopPlayImage
            timeLabel.text = "00:00:00"
            timeLabel.textColor = .white
            startPlaying()
        } else {
            playButton.image = startPlayImage
            timeLabel.textColor = .white
            timer?.invalidate()
        }
    }
    
    func startPlaying() {
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        playSound()
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
    }
    
    @objc func updateTimer() {
        if playStarted {
            if let isPlaying = audioPlayer?.isPlaying {
                if !isPlaying {
                    playButton.image = startPlayImage
                    timeLabel.textColor = .white
                    timer?.invalidate()
                    playStarted = !playStarted
                }
            }
        }
        
        let currentTime = Date().timeIntervalSinceReferenceDate
        let elapsedTime = currentTime - startTime
        timeLabel.text = stringFromTimeInterval(interval: elapsedTime)
    }
    
    private func stringFromTimeInterval(interval: TimeInterval) -> String {
         let interval = Int(interval)
         let hours = interval / 3600
         let minutes = interval / 60
         let seconds = interval % 60

         return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
     }
    
    private func recordSound() {
        audioURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
          
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.record)
            try AVAudioSession.sharedInstance().setActive(true) // пытаемся включить
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Error recording audio: \(error.localizedDescription)")
        }
    }
    
    private func playSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL!)
            if let player = audioPlayer {
                player.numberOfLoops = 0
                player.play()
            }
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func saveRecord(recordURL: URL) -> String? {
        let documentsDirectory = getDocumentsDirectory()
        
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

