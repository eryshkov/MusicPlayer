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
    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.player.play()
    }
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        self.player.pause()
    }
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        self.player.stop()
    }
    
    var player = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            if let audioPath = Bundle.main.path(forResource: "2-10 Last Exit to Brooklyn", ofType: "mp3"){
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            }
        } catch {
            print("Error. File not found")
        }
        
        
    }



}

