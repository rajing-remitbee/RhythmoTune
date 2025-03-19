//
//  ArtistCollectionViewCell.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 04/03/25.
//

import UIKit
import SDWebImage

class SongCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! //Song Cover
    @IBOutlet weak var songTitle: UILabel! //Song Title
    @IBOutlet weak var blurView: UIVisualEffectView! //Song BlurView
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with song: Song) {
        //Setup Song Card
        songTitle.text = song.title
        imageView.layer.cornerRadius = 24
        
        //Setup BlurView
        blurView.layer.cornerRadius = 24
        blurView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        blurView.clipsToBounds = true
        
        // Load cover from URL
        if let imageUrl = URL(string: song.coverArt) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
    }
}
