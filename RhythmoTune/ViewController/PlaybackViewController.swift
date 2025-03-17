//
//  PlaybackViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 06/03/25.
//

import UIKit
import AVKit
import SDWebImage
import AVFoundation
import MediaPlayer

class PlaybackViewController: UIViewController {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songAuthor: UILabel!
    @IBOutlet weak var timeRemaining: UILabel!
    @IBOutlet weak var songSlider: UISlider!
    @IBOutlet weak var btnRewind: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnOpenLyric: UIButton!
    
    var song: Song!
    var artistName: String!
    weak var player: AVPlayer!
    
    var isRepeatEnabled = false
    var isMuted = false
    var isUserDraggingSlider = false
    var seekTimer: Timer?
    var savedTime: CMTime?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide navigation back button
        navigationItem.hidesBackButton = true
        
        //Album text
        menuLabel.text = song.album
        
        //Slider Properties
        songSlider.minimumTrackTintColor = .white
        songSlider.maximumTrackTintColor = .black
        if let originalThumbImage = UIImage(named: "Dot") {
            let newSize = CGSize(width: 20, height: 20)
            if let resizedThumbImage = originalThumbImage.resized(to: newSize) {
                songSlider.setThumbImage(resizedThumbImage, for: .normal)
            }
        }
        
        //Bottom View Setup
        bottomView.layer.cornerRadius = 20
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.clipsToBounds = true
        blurView.clipsToBounds = true
        
        //Play & Pause Button Setup
        btnPlayPause?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        btnRepeat.layer.cornerRadius = 8
        btnRepeat?.setImage(UIImage(systemName: "repeat"), for: .normal)
        btnRepeat?.tintColor = .white
        btnVolume?.tintColor = .white
        btnVolume?.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        
        //Audio Player
        player = AudioManager.shared.player
        
        //Setup audio player
        guard let url = URL(string: song.filepath) else { return }
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        AudioManager.shared.currentSong = song
        AudioManager.shared.currentArtist = artistName
        
        //Setup cover image
        if let coverUrl = URL(string: song.coverArt) {
            coverImage?.sd_setImage(with: coverUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
        //Setup Song Details
        songName?.text = song.title
        songAuthor?.text = artistName
        songSlider?.minimumValue = 0
        songSlider?.maximumValue = Float(song.duration)
        songSlider?.value = 0
        
        songSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        songSlider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        songSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        //Player Periodic Listener
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }
            if !self.isUserDraggingSlider {
                let currentTime = CMTimeGetSeconds(time) //Update time
                self.songSlider.value = Float(currentTime) //Update slider
                self.updateTimeRemainingLabel(currentTime: Int(currentTime), totalDuration: self.song.duration) //Update remaining time
                self.updateNowPlayingInfo() //Update Now Playing
            }
        }
        
        player.play() //Start song
        updateNowPlayingInfo() //Update now playing
        updateMiniPlayer() //Update mini player
        
        //Edge swipe gesture
        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.edges = .left //Handle from left edge
        view.addGestureRecognizer(swipeGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    // Slider Touch Down
    @objc func sliderTouchDown() {
        isUserDraggingSlider = true
        player.rate = 0
    }
    
    // Slider Touch Up
    @objc func sliderTouchUp() {
        isUserDraggingSlider = false
        if let savedTime = savedTime {
            player.seek(to: savedTime) { finished in
                if finished {
                    self.player.rate = 1
                }
            }
            self.savedTime = nil
        } else {
            player.rate = 1
        }
    }
    
    // Slider Value Changed (Debounced)
    @objc func sliderValueChanged() {
        savedTime = CMTime(seconds: Double(songSlider.value), preferredTimescale: 1)
        updateTimeRemainingLabel(currentTime: Int(songSlider.value), totalDuration: song.duration)
    }
    
    //Handle Player Reached End
    @objc func playerItemDidReachEnd() {
        if isRepeatEnabled {
            player.seek(to: .zero) // Seek to the beginning
            player.play() // Play again
            updateMiniPlayer()
        }
    }
    
    //Handle left edge swipe
    @objc func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            navigationController?.popViewController(animated: true) //Navigate back
        }
    }
    
    //Slider changed or dragged
    @IBAction func songSliderValueChanged(_ sender: UISlider) {
    }
    
    //Back pressed
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true) //Navigate back
    }
    
    //Volume Button Pressed
    @IBAction func btnVolumeButtonPressed(_ sender: UIButton) {
        isMuted.toggle()
        if isMuted {
            btnVolume.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            player.volume = 0.0
        } else {
            btnVolume.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
            player.volume = 1.0
        }
    }
    
    //Play & Pause button pressed
    @IBAction func btnPlayPauseTapped(_ sender: UIButton) {
        if player.isPlaying {
            player.pause() //Pause if playing
            btnPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal) // Change to play icon
        } else {
            player.play() //Play if paused
            btnPlayPause.setImage(UIImage(systemName: "pause.fill"), for: .normal) // Change to pause icon
        }
        updateMiniPlayer() //Update mini player
    }
    
    //Rewind button pressed
    @IBAction func btnRewindTapped(_ sender: UIButton) {
        let currentTime = player.currentTime()
        let rewindTime = CMTimeSubtract(currentTime, CMTime(seconds: 5, preferredTimescale: 1)) //Rewind to 5 seconds
        player.seek(to: rewindTime)
        updateMiniPlayer() //Update mini player
    }
    
    //Forward button pressed
    @IBAction func btnForwardTapped(_ sender: UIButton) {
        let currentTime = player.currentTime()
        let forwardTime = CMTimeAdd(currentTime, CMTime(seconds: 5, preferredTimescale: 1)) //Move formward to 5 seconds
        player.seek(to: forwardTime)
        updateMiniPlayer() //Update mini player
    }
    
    //Repeat Button Tapped
    @IBAction func btnRepeatTapped(_ sender: UIButton) {
        isRepeatEnabled.toggle()
        updateRepeatButtonAppearance()
    }
    
    func updateRepeatButtonAppearance() {
        if isRepeatEnabled {
            btnRepeat.backgroundColor = .systemGray6
            btnRepeat.tintColor = .black
        } else {
            btnRepeat.backgroundColor = .clear
            btnRepeat.tintColor = .white
        }
    }
    
    
    //Time formatter
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    //Update remaining time
    private func updateTimeRemainingLabel(currentTime: Int, totalDuration: Int) {
        let remainingTime = totalDuration - currentTime
        timeRemaining.text = formatTime(seconds: remainingTime)
    }
    
    //Update now playing information
    private func updateNowPlayingInfo() {
        AudioManager.shared.updateNowPlayingInfo(song: song, artistName: artistName, coverImage: coverImage.image)
    }
    
    //Update mini player
    private func updateMiniPlayer() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.miniPlayerView.configure(song: song, artistName: artistName, player: player) //Current playing song
        }
    }
    
    // Seek Audio Function
    private func seekAudio() {
        let newTime = CMTime(seconds: Double(songSlider.value), preferredTimescale: 1)
        player.seek(to: newTime)
        updateMiniPlayer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
}
