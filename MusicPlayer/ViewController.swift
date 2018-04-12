//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Evgeniy Ryshkov on 08.04.2018.
//  Copyright © 2018 Evgeniy Ryshkov. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

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
    
    @IBOutlet weak var playListPickerView: UIPickerView!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    
    var player = AVAudioPlayer()
    
    var currentTrack: Int?
    
    var allTracks = [URL]()
    
    var timerProgress = Timer()
    
    var progressSliderUnused: Bool = true {
        willSet{
            //print("progress bar is \(newValue ? "unused" : "using now")")
        }
    } //Trottle Timer if in use
    
    //MARK: - View controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPlayList()
        
        playListPickerView.delegate = self
        playListPickerView.selectRow(0, inComponent: 0, animated: true)
        
        currentTrack = 0
        readFile()
        setTimer()
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
    
    func getPlayList() {
        let playList = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: "")
        
        for item in playList {
            allTracks.append(URL(fileURLWithPath: item))
        }
        
        
    }
    
    fileprivate func setTimer() {
        //Set Timer for progress bar
        timerProgress = Timer(timeInterval: 0.05, repeats: true, block: { (timer) in
            if self.progressSliderUnused {
                self.progressSlider.setValue(Float(self.player.currentTime), animated: true)
            }
        })
        //Set runloop for timer
        RunLoop.current.add(self.timerProgress, forMode: .defaultRunLoopMode)
    }
    
    func readFile(){
        do {
            if let audioPath = currentTrack{
                let trackURL = allTracks[audioPath]
                print(trackURL.lastPathComponent)
                
                //Setup player
                try player = AVAudioPlayer(contentsOf: trackURL)
                player.delegate = self //For observe on finish playing
                self.player.volume = volumeSlider.value
                
                //Setup progress slider
                progressSlider.minimumValue = 0.0
                progressSlider.maximumValue = Float(player.duration)
                
                //Extract metadata from track
                let playerItem = AVPlayerItem(url: trackURL)
                let metadataList = playerItem.asset.metadata
                
                var title = "Track: -"
                //var album = "Album: -"
                var artist = "Artist: -"
                var artwork = UIImage(named: "emptyImage")
                
                for item in metadataList {
                    
                    guard let key = item.commonKey, let value = item.value else{
                        print("No metadata found")
                        continue
                    }
                    switch key.rawValue {
                    case "title" : title = "Track: \((value as? String) ?? "-")"
                    //case "album": album = "Album: \((value as? String) ?? "-")"
                    case "artist": artist = "Artist: \((value as? String) ?? "-")"
                    case "artwork" where value is NSData :
                        print("Image found")
                        artwork = UIImage(data: (value as! NSData) as Data)
                    default:
                        print(key.rawValue)
                        continue
                    }
                }
                trackLabel.text = title
                artistLabel.text = artist
                artistImage.image = artwork
                
                self.setNowPlayingInfo(title: title, album: artist, image: artwork!)
                
            }else{ print("No files found in bundle")}
        } catch {
            print("Error. File not found")
        }
    }
    
    //For NowPlayingInfo while palaying background
    func setNowPlayingInfo(title: String, album: String, image: UIImage)
    {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        let title = title
        let album = album
        let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
            return image
        })
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    //MARK: - Actions
    
    
    @IBAction func progressSliderInUse(_ sender: UISlider) {
        self.progressSliderUnused = false
        
    }
    
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        self.player.currentTime = TimeInterval(sender.value)
        self.progressSliderUnused = true
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.player.play()
        self.progressSliderUnused = true
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        self.player.pause()
        self.progressSliderUnused = true
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        self.progressSliderUnused = true
        self.player.stop()
        self.player.currentTime = 0.0
    }
    
    @objc func volumeChanged(_ sender: UISlider) {
        self.player.volume = sender.value
    }
    
    
}

extension ViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return allTracks[row].lastPathComponent
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTrack = row
        if player.isPlaying {
            readFile()
            self.player.play()
        }else{
            readFile()
        }
    }
}

extension ViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allTracks.count
    }
    
    
}

extension ViewController: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if var curTrack = currentTrack{
            curTrack += 1
            currentTrack = curTrack >= allTracks.count ? 0 : curTrack
            playListPickerView.selectRow(currentTrack!, inComponent: 0, animated: true)
        }
        
        readFile()
        self.player.play()
    }
}










