//
//  PlaylistViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 13/03/25.
//

import UIKit

class PlaylistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .clear
        let label = UILabel()
        label.text = "User Favourites"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
