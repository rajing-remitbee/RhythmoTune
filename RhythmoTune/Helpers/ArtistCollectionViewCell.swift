//
//  ArtistCollectionViewCell.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 04/03/25.
//

import UIKit
import SDWebImage

class ArtistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! //Artist Image
    @IBOutlet weak var artistLabel: UILabel! //Artist Name
    @IBOutlet weak var blurView: UIVisualEffectView! //Blur View
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with artist: Artist) {
        //Setup Artist Card
        artistLabel.text = artist.name
        imageView.layer.cornerRadius = 24
        
        //Setup BlurView
        blurView.layer.cornerRadius = 24
        blurView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        blurView.clipsToBounds = true
        
        //Load artist image from url
        if let imageUrl = URL(string: artist.imageURL) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
    }
}
