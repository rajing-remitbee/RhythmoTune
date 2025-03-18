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
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial)) // Blur effect
    let closeButton = UIButton(type: .system)
    
    //Initial touch point
    private var initialTouchPoint: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGesture()
        setupPanGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupGesture()
        setupPanGesture()
    }
    
    private func setupPanGesture() {
        //Pan Gesture Setup
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    private func setupViews() {
        backgroundColor = .clear //Clear Background Color
        
        // Blur effect view
        blurEffectView.layer.cornerRadius = 12 // Rounded corners for blur
        blurEffectView.clipsToBounds = true
        addSubview(blurEffectView)
        
        //Cover Image
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 8
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
        
        // Close button setup
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal) // Set the image
        closeButton.tintColor = .label // Set the color
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside) // Add target
        addSubview(closeButton)
    }
    
    private func setupConstraints() {
        //Constratinsts
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Blur effect view constraints
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            blurEffectView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
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
            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 30),
            playPauseButton.heightAnchor.constraint(equalToConstant: 30),
            
            //Close Button
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupGesture() {
        //Tap Gesture setup
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(miniPlayerTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func closeButtonTapped(_ sender: Any) {
        AudioManager.shared.player.pause()
        AudioManager.shared.player.replaceCurrentItem(with: nil)
        self.isHidden = true
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
    
    //Snap To Edge
    private func snapToEdgeOrCorner() {
        guard let superview = superview else { return } //Superview
        
        let safeArea = superview.safeAreaLayoutGuide.layoutFrame //Safearea
        let viewWidth = frame.width //Width
        let viewHeight = frame.height //Height
        
        let left = safeArea.minX + viewWidth / 2 //Left edge
        let right = safeArea.maxX - viewWidth / 2 //Right edge
        let top = safeArea.minY + viewHeight / 2 //Top edge
        let bottom = safeArea.maxY - viewHeight / 2 //Bottom edge
        
        let centerX = center.x //Center X
        let centerY = center.y //Center Y
        
        var targetPoint = center //Target Point
        
        // Determine closest edge or corner
        if abs(centerX - left) < abs(centerX - right) {
            // Closer to left
            if abs(centerY - top) < abs(centerY - bottom) {
                // Closer to top (top-left corner)
                targetPoint = CGPoint(x: left, y: top)
            } else {
                // Closer to bottom (bottom-left corner)
                targetPoint = CGPoint(x: left, y: bottom)
            }
        } else {
            // Closer to right
            if abs(centerY - top) < abs(centerY - bottom) {
                // Closer to top (top-right corner)
                targetPoint = CGPoint(x: right, y: top)
            } else {
                // Closer to bottom (bottom-right corner)
                targetPoint = CGPoint(x: right, y: bottom)
            }
        }
        
        // Animate the snap
        UIView.animate(withDuration: 0.3) {
            self.center = targetPoint
        }
    }
    
    //Mini Player tapped listener
    @objc func miniPlayerTapped() {
        if
            let appDelegate = UIApplication.shared.delegate as? AppDelegate, // AppDelegate
            let navigationController = appDelegate.window?.rootViewController as? UINavigationController, //Navigation Controller
            let currentSong = AudioManager.shared.currentSong, //Current Song
            let currentArtist = AudioManager.shared.currentArtist //Current Artist
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil) //Storyboard
            let playbackViewController = storyboard.instantiateViewController(withIdentifier: "PlaybackViewController") as! PlaybackViewController //PlaybackViewController
            playbackViewController.song = currentSong //Set current song
            playbackViewController.artistName = currentArtist //Set current artist
            navigationController.pushViewController(playbackViewController, animated: true) // Push viewcontroller to stack
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = center
        case .changed:
            center = CGPoint(x: initialTouchPoint.x + translation.x, y: initialTouchPoint.y + translation.y)
        case .ended, .cancelled:
            snapToEdgeOrCorner()
        default:
            break
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
