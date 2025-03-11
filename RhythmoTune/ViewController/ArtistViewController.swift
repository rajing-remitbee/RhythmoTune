//
//  ArtistViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 11/03/25.
//

import UIKit
import SDWebImage

class ArtistViewController: UIViewController {
    
    @IBOutlet weak var imgArtist: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var artistSongView: UIVisualEffectView!
    @IBOutlet weak var songsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var artist: Artist!
    var artistSongs: [Song] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide Navigation back button
        navigationItem.hidesBackButton = true
        
        //Style and Hide Activity Indicator
        activityIndicator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        activityIndicator.isHidden = true
        
        //Load artist image from url
        if let imageUrl = URL(string: artist.imageURL) {
            imgArtist.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
        //Artist Name
        menuLabel.text = artist.name
        
        //Top Menu Setup
        artistSongView.layer.cornerRadius = 20
        artistSongView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        artistSongView.clipsToBounds = true
        
        //Fetch songs
        Task {
            do {
                showLoadingIndicator()
                let artistSongs = try await Appwrite().fetchSongs(artist: self.artist.artistID)
                self.artistSongs = artistSongs
                //Update in UI
                DispatchQueue.main.async {
                    self.songsCollectionView.reloadData()
                    self.hideLoadingIndicator()
                }
            } catch {
                print("Error fetching songs: \(error.localizedDescription)")
            }
        }
        
        songsCollectionView.dataSource = self
        
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

extension ArtistViewController: UICollectionViewDataSource {
    
    //Collection View Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artistSongs.count
    }
    
    //CollectionViewCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistSongCell", for: indexPath) as! ArtistSongViewCell
        let song = artistSongs[indexPath.item]
        cell.configure(with: song)
        return cell
    }
    
    //Collection View cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 270, height: 70)
    }
}
