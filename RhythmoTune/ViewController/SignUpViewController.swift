//
//  SignUpViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 26/02/25.
//

import UIKit

class SignUpViewController: ViewController {

    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    //Setup View
    private func setUpView() {
        bottomView.layer.cornerRadius = 20
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.clipsToBounds = true
    }
}
