//
//  ArtistViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 11/03/25.
//

import UIKit
import SDWebImage
import Lottie

class ArtistViewController: UIViewController {
    
    @IBOutlet weak var imgArtist: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var artistSongView: UIVisualEffectView!
    @IBOutlet weak var songsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var txtPopularSongs: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    
    var artist: Artist!
    var artistSongs: [Song] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide Navigation back button
        navigationItem.hidesBackButton = true
        
        //Style and Hide Activity Indicator
        activityIndicator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        activityIndicator.isHidden = true
        btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        //Load artist image from url
        if let imageUrl = URL(string: artist.imageURL) {
            imgArtist.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
        //Artist Name
        menuLabel.text = artist.name
        
        //Hide table initially
        songsTableView.isHidden = true
        txtPopularSongs.isHidden = true
        btnFollow.isHidden = true
        btnPlay.isHidden = true
        
        //Setup lottie
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.backgroundColor = .clear
        lottieView.play()
        
        //Fetch songs
        Task {
            do {
                showLoadingIndicator()
                let artistSongs = try await Appwrite().fetchSongs(artist: self.artist.artistID)
                self.artistSongs = artistSongs
                //Update in UI
                DispatchQueue.main.async {
                    if self.artistSongs.isEmpty {
                        self.lottieView.isHidden = false
                        self.songsTableView.isHidden = true
                        self.txtPopularSongs.isHidden = true
                        self.btnFollow.isHidden = true
                        self.btnPlay.isHidden = true
                    } else {
                        self.lottieView.isHidden = true
                        self.songsTableView.isHidden = false
                        self.txtPopularSongs.isHidden = false
                        self.btnFollow.isHidden = false
                        self.btnPlay.isHidden = false
                        self.songsTableView.reloadData()
                    }
                    self.hideLoadingIndicator()
                }
            } catch {
                print("Error fetching songs: \(error.localizedDescription)")
            }
        }
        
        songsTableView.delegate = self
        songsTableView.dataSource = self
        
        //Edge swipe gesture
        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.edges = .left //Handle from left edge
        view.addGestureRecognizer(swipeGesture)
    }
    
    //Show Activity Indicator
    private func showLoadingIndicator() {
        activityIndicator?.isHidden = false //Show the activity indicator
        activityIndicator?.startAnimating() //Start animation
    }

    //Hide Activity Indicator
    private func hideLoadingIndicator() {
        activityIndicator?.isHidden = true //Hide the activity indicator
        activityIndicator?.stopAnimating() //Stop the animation
    }
    
    //Navigate to Playback Screen
    private func navigateToPlaybackScreen(_ song: Song) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playbackViewController = storyboard.instantiateViewController(withIdentifier: "PlaybackViewController") as! PlaybackViewController
        playbackViewController.song = song //Set song
        playbackViewController.artistName = artist.name
        self.navigationController?.pushViewController(playbackViewController, animated: true)
        updateMiniPlayer(song: song) //Update miniplayer
    }
    
    //Update miniplayer
    private func updateMiniPlayer(song: Song) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // Find the artist name
            var artistName: String?
            artistName = artist.name
            
            // Configure the mini player
            if let artistName = artistName {
                appDelegate.miniPlayerView.configure(song: song, artistName: artistName, player: AudioManager.shared.player)
                appDelegate.miniPlayerView.isHidden = false // Show the mini player
            } else {
                // Handle the case where the artist name is not found
                appDelegate.miniPlayerView.isHidden = true // Hide the mini player
                print("Error: Artist name not found for song: \(song.title)")
            }
        }
    }
    
    //Back pressed
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true) //Navigate back
    }
    
    //Handle left edge swipe
    @objc func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            navigationController?.popViewController(animated: true) //Navigate back
        }
    }
}

extension ArtistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = artistSongs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSongCell", for: indexPath) as! ArtistSongViewCell
        cell.configure(with: result)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = artistSongs[indexPath.row]
        navigateToPlaybackScreen(song)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
