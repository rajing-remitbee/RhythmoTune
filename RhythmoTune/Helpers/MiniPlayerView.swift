//
//  MiniPlayerView.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 10/03/25.
//

import UIKit
import AVKit
import SDWebImage

class MiniPlayerView: UIView {
    
    let coverImageView = UIImageView() //CoverImage
    let titleLabel = UILabel() //Title
    let artistLabel = UILabel() //Artist
    let playPauseButton = UIButton() //Play and Pause Button
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupGesture()
    }
    
    private func setupViews() {
        backgroundColor = UIColor.systemGray6 //Background Color
        
        //Cover Image
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        addSubview(coverImageView)
        
        //Song Title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        addSubview(titleLabel)
        
        //Artist Label
        artistLabel.font = UIFont.systemFont(ofSize: 14)
        artistLabel.textColor = .secondaryLabel
        addSubview(artistLabel)
        
        //Play & Pause Button
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.tintColor = .label
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        addSubview(playPauseButton)
    }
    
    private func setupConstraints() {
        //Constratinsts
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //Cover Image Constraints
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            coverImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            coverImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor),
            
            //Song Title Constraints
            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -8),
            
            //Artist Label Constraints
            artistLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 8),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -8),
            
            //Play & Pause Button Constraints
            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 30),
            playPauseButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(miniPlayerTapped))
        addGestureRecognizer(tapGesture)
    }
    
    //Configure Mini Player
    func configure(song: Song, artistName: String, player: AVPlayer) {
        titleLabel.text = song.title //Song Title
        artistLabel.text = artistName //Artist Name
        
        //Cover Image
        if let coverUrl = URL(string: song.coverArt) {
            coverImageView.sd_setImage(with: coverUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
        //Update Play & Pause Button
        updatePlayPauseButton(player: player)
    }
    
    //Play & Pause Button Update
    func updatePlayPauseButton(player: AVPlayer) {
        if player.isPlaying {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    //Mini Player tapped listener
    @objc func miniPlayerTapped() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let playbackViewController = storyboard.instantiateViewController(withIdentifier: "PlaybackViewController") as! PlaybackViewController
            appDelegate.window?.rootViewController?.present(playbackViewController, animated: true, completion: nil)
        }
    }
    
    //Play & Pause Button Tap Listener
    @objc func playPauseTapped() {
        if AudioManager.shared.player.isPlaying {
            AudioManager.shared.player.pause()
        } else {
            AudioManager.shared.player.play()
        }
        updatePlayPauseButton(player: AudioManager.shared.player)
    }
    
}
