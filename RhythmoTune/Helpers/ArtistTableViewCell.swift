//
//  ArtistTableViewCell.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 12/03/25.
//

import UIKit

class ArtistTableViewCell: UITableViewCell {

    @IBOutlet weak var artistProfile: UIImageView!
    @IBOutlet weak var artistTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(with artist: Artist) {
        artistTitle.text = artist.name
        artistProfile.layer.cornerRadius = 4
        
        //Load cover from URL
        if let imageUrl = URL(string: artist.imageURL) {
            artistProfile.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
    }
}
