//
//  AudioManager.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 10/03/25.
//

import AVKit
import AVFoundation
import MediaPlayer

class AudioManager {
    
    var currentSong: Song? //Current Song
    var currentArtist: String? //Current Artist
    
    static let shared = AudioManager() //Singleton AudioManager
    let player = AVPlayer() //AV Player
    
    private init() {
        setupAudioSession()
        setupRemoteCommands()
    }
    
    //Setup Audio Session
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetoothA2DP, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. \(error)")
        }
    }
    
    //Setup Remote Commands
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared() //Command Center
        
        //Play Command
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.player.play()
            return .success
        }
        
        //Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.player.pause()
            return .success
        }
        
        //Change Playback Position Command
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self?.player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: 1))
                return .success
            }
            return .commandFailed
        }
        
    }
    
    //Update Now laying Information
    func updateNowPlayingInfo(song: Song?, artistName: String?, coverImage: UIImage?) {
        guard let song = song, let artistName = artistName, let coverImage = coverImage else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artistName
        let artwork = MPMediaItemArtwork(boundsSize: coverImage.size) { size in return coverImage }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = song.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

