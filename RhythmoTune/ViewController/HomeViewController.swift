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
    
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    
    @IBOutlet weak var menuOne: UIView!
    @IBOutlet weak var menuOneIndication: UIView!
    
    @IBOutlet weak var menuTwo: UIView!
    @IBOutlet weak var menuTwoIndication: UIView!
    
    @IBOutlet weak var menuThree: UIView!
    @IBOutlet weak var menuThreeIndication: UIView!
    
    @IBOutlet weak var menuFour: UIView!
    @IBOutlet weak var menuFourIndication: UIView!

    @IBOutlet weak var songCollectionView: UICollectionView!
    @IBOutlet weak var artistCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var songs: [Song] = []
    var artists: [Artist] = []
    var currentChildViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHeadAndSubhead()
        setupTapNavigations()
        
        //Artist collection
        artistCollectionView.tag = 1
        artistCollectionView.delegate = self
        artistCollectionView.dataSource = self
        
        //Song collection
        songCollectionView.tag = 2
        songCollectionView.delegate = self
        songCollectionView.dataSource = self
        
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
                self.hideLoadingIndicator()
                print("Error fetching songs: \(error.localizedDescription)")
                Snackbar.shared.showErrorMessage(message: "Fetch songs failed: \(error.localizedDescription)", on: self.view)
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
                self.hideLoadingIndicator()
                print("Error fetching artists: \(error.localizedDescription)")
                Snackbar.shared.showErrorMessage(message: "Fetch artist failed: \(error.localizedDescription)", on: self.view)
            }
        }
    }
    
    //Setup tab navigation
    private func setupTapNavigations() {
        
        let homeTap = UITapGestureRecognizer(target: self, action: #selector(homeTabTapped))
        menuOne.addGestureRecognizer(homeTap)
        
        let exploreTap = UITapGestureRecognizer(target: self, action: #selector(exploreTabTapped))
        menuTwo.addGestureRecognizer(exploreTap)
        
        let playlistTap = UITapGestureRecognizer(target: self, action: #selector(playlistTabTapped))
        menuThree.addGestureRecognizer(playlistTap)
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileTabTapped))
        menuFour.addGestureRecognizer(profileTap)
        
        updateIndicators(activeTabView: menuOne)
    }
    
    
    private func updateIndicators(activeTabView: UIView) {
        menuOneIndication.isHidden = menuOne != activeTabView
        menuTwoIndication.isHidden = menuTwo != activeTabView
        menuThreeIndication.isHidden = menuThree != activeTabView
        menuFourIndication.isHidden = menuFour != activeTabView
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
    
    //Navigate to Artist Screen
    private func navigateToArtistScreen(_ artist: Artist) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let artistViewController = storyboard.instantiateViewController(withIdentifier: "ArtistViewController") as! ArtistViewController
        artistViewController.artist = artist //Set artist
        self.navigationController?.pushViewController(artistViewController, animated: true)
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
    
    func showChildViewController(_ viewController: UIViewController) {
        if let currentChild = currentChildViewController {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }
        
        addChild(viewController)
        bodyView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: bodyView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor)
        ])
        
        viewController.didMove(toParent: self)
        currentChildViewController = viewController
    }
    
    @objc func homeTabTapped() {
        if let currentChild = currentChildViewController {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
            currentChildViewController = nil
        }
        updateIndicators(activeTabView: menuOne)
    }
    
    @objc func exploreTabTapped() {
        showChildViewController(ExploreViewController())
        updateIndicators(activeTabView: menuTwo)
    }
    
    @objc func playlistTabTapped() {
        showChildViewController(PlaylistViewController())
        updateIndicators(activeTabView: menuThree)
    }
    
    @objc func profileTabTapped() {
        showChildViewController(ProfileViewController())
        updateIndicators(activeTabView: menuFour)
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
            let artist = artists[indexPath.item]
            navigateToArtistScreen(artist)
        } else {
            let song = songs[indexPath.item]
            navigateToPlaybackScreen(song)
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    //When clicked on search bar
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) //Main Storyboard
        let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController //Search Viewcontroller
        searchViewController.allSongs = songs //Assign songs
        searchViewController.allArtists = artists //Assign artists
        navigationController?.pushViewController(searchViewController, animated: true) //Push to stack
        return false
    }
}
