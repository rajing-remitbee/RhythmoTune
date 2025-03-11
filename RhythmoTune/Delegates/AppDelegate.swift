//
//  AppDelegate.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 24/02/25.
//

import UIKit
import AVKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? //Ui Window
    let miniPlayerView = MiniPlayerView(frame: .zero) //Miniplayer
    private var playerRateObservation: NSKeyValueObservation? //Observation Rate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else { return true }
        
        //Add miniplayer to window
        window.addSubview(miniPlayerView)
        
        //Constraint miniplayer
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            miniPlayerView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16), // Padding on leading
            miniPlayerView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16), // Padding on trailing
            miniPlayerView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: 16), // Padding on bottom
            miniPlayerView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        //Observer changes for song
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemChanged), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        playerRateObservation = AudioManager.shared.player.observe(\.rate, options: [.new]) { [weak self] player, change in
            self?.miniPlayerView.updatePlayPauseButton(player: player)
        }
        
        return true
    }
    
    //Player Song Changed
    @objc func playerItemChanged(notification: Notification) {
        //Add current playing song to miniplayer
        if let currentSong = AudioManager.shared.currentSong, let currentArtist = AudioManager.shared.currentArtist {
            miniPlayerView.configure(song: currentSong, artistName: currentArtist, player: AudioManager.shared.player)
            miniPlayerView.isHidden = false
        } else {
            //Else hide the mini player
            miniPlayerView.isHidden = true
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

