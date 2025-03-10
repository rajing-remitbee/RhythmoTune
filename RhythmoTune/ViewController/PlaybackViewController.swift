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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide navigation back button
        navigationItem.hidesBackButton = true
        
        //Album text
        menuLabel.text = song.album
        
        //Top Menu Setup
        bottomView.layer.cornerRadius = 20
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.clipsToBounds = true
        blurView.clipsToBounds = true
        
        //Play & Pause Button Setup
        btnPlayPause?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
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
        
        //Player Periodic Listener
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = CMTimeGetSeconds(time) //Update time
            self.songSlider.value = Float(currentTime) //Update slider
            self.updateTimeRemainingLabel(currentTime: Int(currentTime), totalDuration: self.song.duration) //Update remaining time
            self.updateNowPlayingInfo() //Update Now Playing
        }
        
        player.play() //Start song
        updateNowPlayingInfo() //Update now playing
        updateMiniPlayer() //Update mini player
    }
    
    //Slider changed or dragged
    @IBAction func songSliderValueChanged(_ sender: UISlider) {
        let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 1)
        player.seek(to: newTime) //Seek to new time
        updateMiniPlayer() //Update mini player
    }
    
    //Back pressed
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true) //Navigate back
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
}
