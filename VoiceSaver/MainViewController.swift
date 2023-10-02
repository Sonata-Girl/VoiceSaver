//
//  MainViewController.swift
//  VoiceSaver
//
//  Created by Sonata Girl on 02.10.2023.
//

import UIKit

class MainViewController: UIViewController {
  
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
    
    private var audioRecorder: AudioRecorder?
    private var audioPlayer: AudioPlayer?
    private var timer: Timer?
    private lazy var startTime: TimeInterval = 0.0
    private lazy var recordStarted = false
    private lazy var playStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        audioRecorder = AudioRecorder()
        audioPlayer = AudioPlayer()
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
        audioRecorder?.startRecording()
    }
    
    func stopRecord() {
        let fileName = audioRecorder?.stopRecording()
    }
    
    @objc func startPlayPressed() {
        guard !recordStarted else { return }
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
            stopPlaying()
        }
    }
    
    func startPlaying() {
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        audioPlayer?.startPlaying(url: getDocumentsDirectory().appendingPathComponent("recording.m4a"))
    }
    
    func stopPlaying() {
        audioPlayer?.stopPlaying()
    }
    
    @objc func updateTimer() {
        if playStarted {
            if let isPlaying = audioPlayer?.isPlaying() {
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
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

