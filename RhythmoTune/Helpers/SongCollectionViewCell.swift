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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with song: Song) {
        //Setup Song Card
        songTitle.text = song.title
        imageView.layer.cornerRadius = 24
        
        //Gradient View
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        let maskView = UIView(frame: imageView.bounds)
        maskView.layer.addSublayer(gradientLayer)
        
        //Blur View
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        blurView.mask = maskView
        imageView.addSubview(blurView)
        
        //Load cover from URL
        if let imageUrl = URL(string: song.coverArt) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
    }
}
