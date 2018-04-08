//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Evgeniy Ryshkov on 08.04.2018.
//  Copyright © 2018 Evgeniy Ryshkov. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //MARK: - Properties
    var volumeSlider: UISlider = {
        let newSlider = UISlider()
        newSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        newSlider.translatesAutoresizingMaskIntoConstraints = false
        newSlider.minimumValue = 0
        newSlider.maximumValue = 1
        newSlider.value = 0.5
        newSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
        return newSlider
    }()
    
    var volumeSliderView: UIView = {
        let newView = UIView(frame: .zero)
        newView.backgroundColor = UIColor.clear
        newView.translatesAutoresizingMaskIntoConstraints = false
        return newView
    }()
    
    @IBOutlet weak var progressSlider: UISlider!
    
    var player = AVAudioPlayer()
    
    var timerProgress = Timer()
    
    //MARK: - View controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readFile()
        layoutSetup()
        
    }
    
    deinit {
        timerProgress.invalidate()
    }
    
    //MARK: - Layout Setup
    func layoutSetup(){
        volumeSliderView.addSubview(volumeSlider)
        view.addSubview(volumeSliderView)
        
        var constraints = [NSLayoutConstraint]()
        
        // volumeSliderView Setup
        constraints.append(volumeSliderView.bottomAnchor.constraint(equalTo: progressSlider.topAnchor, constant: -20))
        constraints.append(volumeSliderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16))
        constraints.append(volumeSliderView.widthAnchor.constraint(equalTo: volumeSlider.heightAnchor, constant: 0))
        constraints.append(volumeSliderView.heightAnchor.constraint(equalTo: volumeSlider.widthAnchor, constant: 0))
        
        //Volume Slider Setup
        constraints.append(volumeSlider.centerXAnchor.constraint(equalTo: volumeSliderView.centerXAnchor, constant: 0))
        constraints.append(volumeSlider.centerYAnchor.constraint(equalTo: volumeSliderView.centerYAnchor, constant: 0))
        constraints.append(volumeSlider.widthAnchor.constraint(equalTo: progressSlider.widthAnchor, multiplier: 0.4))
        

        
        NSLayoutConstraint.activate(constraints)
    }
    
    func readFile(){
        do {
            if let audioPath = Bundle.main.path(forResource: "2-10 Last Exit to Brooklyn", ofType: "mp3"){
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
                progressSlider.minimumValue = 0.0
                progressSlider.maximumValue = Float(player.duration)
                
                self.player.volume = volumeSlider.value
                
                timerProgress = Timer(timeInterval: 0.05, repeats: true, block: { (timer) in
                    self.progressSlider.setValue(Float(self.player.currentTime), animated: true)
                })
                RunLoop.current.add(self.timerProgress, forMode: .defaultRunLoopMode)
            }
        } catch {
            print("Error. File not found")
        }
    }
    
    //MARK: - Actions
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        self.player.currentTime = TimeInterval(sender.value)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.player.play()
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        self.player.pause()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        self.player.stop()
        self.player.currentTime = 0.0
    }
    
    @objc func volumeChanged(_ sender: UISlider) {
        self.player.volume = sender.value
    }
    
}

