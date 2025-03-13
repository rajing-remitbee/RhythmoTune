//
//  SearchViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 12/03/25.
//

import UIKit
import Lottie

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lottieAnimationView: LottieAnimationView!
    @IBOutlet weak var btnBack: UIButton!
    
    var allSongs: [Song] = []
    var allArtists: [Artist] = []
    var filteredSongs: [Song] = []
    var filteredArtists: [Artist] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide back button
        navigationItem.hidesBackButton = true
        
        //First Responder
        searchBar.becomeFirstResponder()
        
        //Delegates and Datasources
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        //Hide table initially
        tableView.isHidden = true
        
        //Setup lottie
        lottieAnimationView.contentMode = .scaleAspectFit
        lottieAnimationView.loopMode = .loop
        lottieAnimationView.backgroundColor = .clear
        lottieAnimationView.play()
        
        //SearchView
        if let mySearchBar = searchBar {
            //Font
            if let placeholderFont = UIFont(name: "Montserrat-Regular", size: 16) {
                //Change placeholder font
                changeSearchBarPlaceholderFont(searchBar: mySearchBar, placeholder: "Search Songs and Artists....", font: placeholderFont, color: UIColor.darkGray)
            } else {
                print("Font not found")
            }
        }
        
        //Edge swipe gesture
        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.edges = .left //Handle from left edge
        view.addGestureRecognizer(swipeGesture)
        
    }
    
    func filterResults(searchText: String) {
        if searchText.isEmpty {
            filteredSongs = []
            filteredArtists = []
            tableView.isHidden = true
            lottieAnimationView?.isHidden = false
        } else {
            filteredSongs = allSongs.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            filteredArtists = allArtists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            if filteredSongs.isEmpty && filteredArtists.isEmpty {
                tableView.isHidden = true
                lottieAnimationView?.isHidden = false
            } else {
                tableView.isHidden = false
                lottieAnimationView?.isHidden = true
            }
        }
        tableView.reloadData()
    }
    
    //Navigate to Artist Screen
    private func navigateToArtistScreen(_ artist: Artist) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let artistViewController = storyboard.instantiateViewController(withIdentifier: "ArtistViewController") as! ArtistViewController
        artistViewController.artist = artist //Set artist
        self.navigationController?.pushViewController(artistViewController, animated: true)
    }
    
    //Navigate to Playback Screen
    private func navigateToPlaybackScreen(_ song: Song) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playbackViewController = storyboard.instantiateViewController(withIdentifier: "PlaybackViewController") as! PlaybackViewController
        playbackViewController.song = song //Set song
        //Find artist using artist id
        for artist in allArtists {
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
            for artist in allArtists {
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
    
    //Change Placeholder Text
    func changeSearchBarPlaceholderFont(searchBar: UISearchBar, placeholder: String, font: UIFont, color: UIColor) {
        //Get textfield from search view
        //Attributed Text
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color
            ]
            //Set attributes for placeholder
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true) //Navigate back
    }
    
    
    //Handle left edge swipe
    @objc func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            navigationController?.popViewController(animated: true) //Navigate back
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterResults(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filterResults(searchText: searchBar.text ?? "")
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if !filteredSongs.isEmpty && !filteredArtists.isEmpty {
            return 2 // Both sections have data
        } else if !filteredSongs.isEmpty {
            return 1 // Only songs section has data
        } else if !filteredArtists.isEmpty {
            return 1 // Only artists section has data
        } else {
            return 0 // No sections have data
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredSongs.isEmpty && !filteredArtists.isEmpty {
            if section == 0 {
                return filteredSongs.count
            } else {
                return filteredArtists.count
            }
        } else if !filteredSongs.isEmpty {
            return filteredSongs.count
        } else if !filteredArtists.isEmpty {
            return filteredArtists.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !filteredSongs.isEmpty && !filteredArtists.isEmpty {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableCell", for: indexPath) as! SongTableViewCell
                cell.configure(with: filteredSongs[indexPath.row])
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistTableCell", for: indexPath) as! ArtistTableViewCell
                cell.configure(with: filteredArtists[indexPath.row])
                return cell
            }
        } else if !filteredSongs.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableCell", for: indexPath) as! SongTableViewCell
            cell.configure(with: filteredSongs[indexPath.row])
            return cell
        } else if !filteredArtists.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistTableCell", for: indexPath) as! ArtistTableViewCell
            cell.configure(with: filteredArtists[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !filteredSongs.isEmpty && !filteredArtists.isEmpty {
            if section == 0 {
                return "Songs"
            } else {
                return "Artists"
            }
        } else if !filteredSongs.isEmpty {
            return "Songs"
        } else if !filteredArtists.isEmpty {
            return "Artists"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6
        headerView.layer.cornerRadius = 8
        
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.bounds.size.width - 32, height: 30))
        headerLabel.font = UIFont(name: "Montserrat-Black", size: 18) //Custom Font
        headerLabel.textColor = UIColor.black //Custom Color
        
        if !filteredSongs.isEmpty && !filteredArtists.isEmpty {
            headerLabel.text = (section == 0) ? "Songs" : "Artists"
        } else if !filteredSongs.isEmpty {
            headerLabel.text = "Songs"
        } else if !filteredArtists.isEmpty {
            headerLabel.text = "Artists"
        }
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let song = filteredSongs[indexPath.row]
            navigateToPlaybackScreen(song)
        } else {
            let artist = filteredArtists[indexPath.row]
            navigateToArtistScreen(artist)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
