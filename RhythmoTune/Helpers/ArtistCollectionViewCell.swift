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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with artist: Artist) {
        //Setup Artist Card
        artistLabel.text = artist.name
        imageView.layer.cornerRadius = 16
        
        //Gradient Effect
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        let maskView = UIView(frame: imageView.bounds)
        maskView.layer.addSublayer(gradientLayer)
        
        //Blur Effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        blurView.mask = maskView
        imageView.addSubview(blurView)
        
        //Load artist image from url
        if let imageUrl = URL(string: artist.imageURL) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
    }
}
