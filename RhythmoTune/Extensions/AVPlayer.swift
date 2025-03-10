//
//  AVPlayer.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 06/03/25.
//

import AVKit

extension AVPlayer {
    //Is song playing
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
