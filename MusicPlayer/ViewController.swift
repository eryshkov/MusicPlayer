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
    
    @IBOutlet weak var progressSlider: UISlider!
    
    var player = AVAudioPlayer()
    
    var timerProgress = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            if let audioPath = Bundle.main.path(forResource: "2-10 Last Exit to Brooklyn", ofType: "mp3"){
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
                progressSlider.minimumValue = 0.0
                progressSlider.maximumValue = Float(player.duration)
                timerProgress = Timer(timeInterval: 0.5, repeats: true, block: { (timer) in
                    self.progressSlider.value = Float(self.player.currentTime)
                })
//                timerProgress.add(to: .current,
//                                  forMode: .defaultRunLoopMode)
            }
        } catch {
            print("Error. File not found")
        }
        
    }
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
    }
    
}

