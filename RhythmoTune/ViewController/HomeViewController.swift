//
//  ViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 24/02/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var txtHead: UILabel!
    @IBOutlet weak var txtSubHead: UILabel!
    
    @IBOutlet weak var menuOneIndication: UIView!
    @IBOutlet weak var menuTwoIndication: UIView!
    @IBOutlet weak var menuThreeIndication: UIView!
    @IBOutlet weak var menuFourIndication: UIView!
    
    @IBOutlet weak var songCollectionView: UICollectionView!
    @IBOutlet weak var artistCollectionView: UICollectionView!
    
    var songs: [Song] = []
    var artists: [Artist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHeadAndSubhead()
        
        //Artist collection
        artistCollectionView.tag = 1
        artistCollectionView.delegate = self
        artistCollectionView.dataSource = self
        
        //Song collection
        songCollectionView.tag = 2
        songCollectionView.delegate = self
        songCollectionView.dataSource = self
        
        //Mini player
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            view.addSubview(appDelegate.miniPlayerView)
            appDelegate.miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                appDelegate.miniPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                appDelegate.miniPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                appDelegate.miniPlayerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                appDelegate.miniPlayerView.heightAnchor.constraint(equalToConstant: 80)
            ])
            
            // Hide miniplayer if not playing
            appDelegate.miniPlayerView.isHidden = AudioManager.shared.player.currentItem == nil
        }
        
        //Fetch songs
        Task {
            do {
                showLoadingIndicator()
                let songs = try await Appwrite().fetchSongs()
                self.songs = songs
                //Update in UI
                DispatchQueue.main.async {
                    self.songCollectionView.reloadData()
                    self.hideLoadingIndicator()
                }
            } catch {
                print("Error fetching songs: \(error.localizedDescription)")
            }
        }
        
        //Fetch artists
        Task {
            do {
                showLoadingIndicator()
                let artists = try await Appwrite().fetchArtists()
                self.artists = artists
                //Update in UI
                DispatchQueue.main.async {
                    self.artistCollectionView.reloadData()
                    self.hideLoadingIndicator()
                }
            } catch {
                print("Error fetching artists: \(error.localizedDescription)")
            }
        }
    }
    
    //Setup views and components
    private func setupView() {

        //Hide Navigation Back Button
        navigationItem.hidesBackButton = true
        
        //Style and Hide Activity Indicator
        progressIndicator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        progressIndicator.isHidden = true
        
        //SongCollection View
        songCollectionView.layer.cornerRadius = 24
        
        //Bottom Menu Setup
        menuOneIndication.layer.cornerRadius = 4
        menuTwoIndication.layer.cornerRadius = 4
        menuTwoIndication.isHidden = true
        menuThreeIndication.layer.cornerRadius = 4
        menuThreeIndication.isHidden = true
        menuFourIndication.layer.cornerRadius = 4
        menuFourIndication.isHidden = true
    }
    
    //Setup Head and Subhead
    private func setupHeadAndSubhead() {
        let hour = Calendar.current.component(.hour, from: Date()) //Hour of the day
        
        switch hour {
        //Morning Time
        case 5..<12:
            txtHead.text = "Good morning!"
            txtSubHead.text = "Start your day with some uplifting music!"
            
        //Afternoon Time
        case 12..<17:
            txtHead.text = "Good afternoon!"
            txtSubHead.text = "Enjoy some relaxing tunes for your afternoon break."
            
        //Evening Time
        case 17..<21:
            txtHead.text = "Good evening!"
            txtSubHead.text = "Unwind with some soothing melodies."
            
        //Night Time
        default:
            txtHead.text = "Good night!"
            txtSubHead.text = "Time for some calming music before sleep."
        }
    }
    
    //Show Activity Indicator
    private func showLoadingIndicator() {
        progressIndicator?.isHidden = false //Show the activity indicator
        progressIndicator?.startAnimating() //Start animation
    }

    //Hide Activity Indicator
    private func hideLoadingIndicator() {
        progressIndicator?.isHidden = true //Hide the activity indicator
        progressIndicator?.stopAnimating() //Stop the animation
    }
    
    //Navigate to Playback Screen
    private func navigateToPlaybackScreen(_ song: Song) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playbackViewController = storyboard.instantiateViewController(withIdentifier: "PlaybackViewController") as! PlaybackViewController
        playbackViewController.song = song //Set song
        //Find artist using artist id
        for artist in artists {
            if artist.artistID == song.artist {
                playbackViewController.artistName = artist.name
                break
            }
        }
        self.navigationController?.pushViewController(playbackViewController, animated: true)
        updateMiniPlayer(song: song) //Update miniplayer
    }
    
    //Update miniplayer
    private func updateMiniPlayer(song: Song) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // Find the artist name
            var artistName: String?
            for artist in artists {
                if artist.artistID == song.artist {
                    artistName = artist.name
                    break
                }
            }
            
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
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    //Collection View Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return artists.count
        } else {
            return songs.count
        }
    }
    
    //Collection View Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Artist Cell
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath) as! ArtistCollectionViewCell
            let artist = artists[indexPath.item]
            cell.configure(with: artist)
            return cell
        } else {
            //Song Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongCell", for: indexPath) as! SongCollectionViewCell
            let song = songs[indexPath.item]
            cell.configure(with: song)
            return cell
        }
    }
    
    //Collection View cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    //Collection View onpressed
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            
        } else {
            let song = songs[indexPath.item]
            navigateToPlaybackScreen(song)
        }
    }
}
