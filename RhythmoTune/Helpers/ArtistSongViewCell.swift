//
//  ArtistCollectionViewCell.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 04/03/25.
//

import UIKit
import SDWebImage

class ArtistSongViewCell: UITableViewCell {
    
    @IBOutlet weak var songCover: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songAlbum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(with song: Song) {
        //Setup Song Card
        songTitle.text = song.title
        songAlbum.text = song.album
        songCover.layer.cornerRadius = 24
        
        //Load cover from URL
        if let imageUrl = URL(string: song.coverArt) {
            songCover.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
    }
}
