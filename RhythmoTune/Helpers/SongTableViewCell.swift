//
//  SongTableViewCell.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 12/03/25.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(with song: Song) {
        songTitle.text = song.title
        coverImage.layer.cornerRadius = 4
        
        //Load cover from URL
        if let imageUrl = URL(string: song.coverArt) {
            coverImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
    }

}
