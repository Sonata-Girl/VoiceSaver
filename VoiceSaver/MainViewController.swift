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
        let tap = UITapGestureRecognizer(target: self, action: #selector(startRecordButtonPressed))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var playButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = startPlayImage
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(startPlayButtonPressed))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var timerLabel: UILabel = {
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
    private var startTime: TimeInterval = 0.0
    private var recordStarted = false
    private var playStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        audioRecorder = AudioRecorder()
        audioPlayer = AudioPlayer()
    }
    
    private func setupUI() {
        
        let thirdPartOfViewMultiplier = 0.3
        let thirdPartOfView = view.frame.height / 3
        let offsetFromView = view.frame.height / 20
        
        view.addSubview(recordButton)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: offsetFromView),
            recordButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            recordButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: thirdPartOfViewMultiplier),
            recordButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: thirdPartOfViewMultiplier)
        ])
        
        view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: thirdPartOfView),
            timerLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        view.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20),
            playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: thirdPartOfViewMultiplier),
            playButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: thirdPartOfViewMultiplier)
        ])
    }
    
    @objc func startRecordButtonPressed() {
        guard !playStarted else { return }
        if recordStarted {
            stopRecord()
        } else {
            if audioRecorder?.requestPermission() == true {
                startRecord()
            } else {
                guard let permissionIsGot = audioRecorder?.permissionGranted, !permissionIsGot else { return }
                self.showAlert(title: "Attention", text: "No recording authorisation has been obtained, try start record again or switch on microphone access")
            }
        }
    }
    
    func startRecord() {
        guard let audioRecorder = audioRecorder else { return }
        recordStarted = true
        recordButton.image = stopRecordImage
        timerLabel.text = "00:00:00"
        timerLabel.textColor = .red
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        audioRecorder.startRecording()
    }
    
    func stopRecord() {
        guard let audioRecorder = audioRecorder, recordStarted else { return }
        recordButton.image = startRecordImage
        timerLabel.textColor = .white
        timer?.invalidate()
        recordStarted = false
        let audioFileName = audioRecorder.stopRecording()
    }
    
    @objc func startPlayButtonPressed() {
        guard !recordStarted, audioRecorder?.audioURL != nil else { return }
        if playStarted {
           stopPlaying()
        } else {
           startPlaying()
        }
    }
    
    func startPlaying() {
        guard let audioURL = audioRecorder?.audioURL else { return }
        playStarted = true
        playButton.image = stopPlayImage
        timerLabel.text = "00:00:00"
        timerLabel.textColor = .white
        
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    
        audioPlayer?.startPlaying(url: audioURL)
    }
    
    func stopPlaying() {
        playStarted = false
        playButton.image = startPlayImage
        timerLabel.textColor = .white
        timer?.invalidate()
        
        audioPlayer?.stopPlaying()
    }
    
    @objc func updateTimer() {
        stopTimerIfAudioPlayerStoppedPlaying()
        
        let currentTime = Date().timeIntervalSinceReferenceDate
        let elapsedTime = currentTime - startTime
        timerLabel.text = formattedTimeIntervalString(from: elapsedTime)
    }
    
    private func stopTimerIfAudioPlayerStoppedPlaying() {
        guard playStarted, let isPlaying = audioPlayer?.isPlaying(), !isPlaying else {
            return
        }
        playButton.image = startPlayImage
        timerLabel.textColor = .white
        timer?.invalidate()
        playStarted = !playStarted
    }
    
    private func formattedTimeIntervalString(from timeInterval: TimeInterval) -> String {
        let interval = Int(timeInterval)
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

extension MainViewController {
    
    func showAlert(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
}
