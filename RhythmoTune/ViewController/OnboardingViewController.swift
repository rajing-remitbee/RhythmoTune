//
//  OnboardingViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 25/02/25.
//

import UIKit
import Lottie

class OnboardingViewController: UIViewController {

    @IBOutlet weak var onboardingLottie: LottieAnimationView!
    
    @IBAction func onStartPress(_ sender: UIButton) {
        navigateToLoginScreen()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        //Configure Lottie
        onboardingLottie.contentMode = .scaleAspectFit
        onboardingLottie.loopMode = .loop
        onboardingLottie.backgroundColor = .clear
        onboardingLottie.play()
        
    }
    
    //Navigate to Login Screen
    private func navigateToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
        self.navigationController?.viewControllers.remove(at: 0)
    }
}
