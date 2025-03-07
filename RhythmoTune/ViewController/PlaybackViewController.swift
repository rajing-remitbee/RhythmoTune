//
//  PlaybackViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 06/03/25.
//

import UIKit
import AVKit
import SDWebImage

class PlaybackViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songAuthor: UILabel!
    @IBOutlet weak var songSlider: UISlider!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btReverse: UIButton!
    @IBOutlet weak var backCover: UIImageView!
    
    var song: Song!
    var artistName: String!
    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        coverImage.layer.cornerRadius = 24
        
        btnPlayPause?.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        guard let url = URL(string: song.filepath) else { return }
        player = AVPlayer(url: url)
        
        if let coverUrl = URL(string: song.coverArt) {
            backCover?.sd_setImage(with: coverUrl, placeholderImage: UIImage(named: "placeholderImage"))
            coverImage?.sd_setImage(with: coverUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
        songName?.text = song.title
        songAuthor?.text = artistName
        songSlider?.minimumValue = 0
        songSlider?.maximumValue = Float(song.duration)
        songSlider?.value = 0
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            // Update seekbar value
            let currentTime = CMTimeGetSeconds(time)
            self.songSlider.value = Float(currentTime)
        }
        
        player.play()
        
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPlayPauseTapped(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
            btnPlayPause.setImage(UIImage(systemName: "play.fill"), for: .normal) // Change to play icon
        } else {
            player.play()
            btnPlayPause.setImage(UIImage(systemName: "pause.fill"), for: .normal) // Change to pause icon
        }
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
}
