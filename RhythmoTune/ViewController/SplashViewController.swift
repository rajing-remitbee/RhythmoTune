//
//  SplashViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 25/02/25.
//

import UIKit
import Appwrite

class SplashViewController: ViewController {
    
    @IBOutlet weak var splashOne: UIImageView!
    @IBOutlet weak var splashTwo: UIImageView!
    @IBOutlet weak var splashThree: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = Client().setProject("67bd5300003544ce4f47")
        
        setupImageView()
        
        setupGradientBackground()
        
        animateImageView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isFirstLaunch()
        }
    }
    
    //Setup ImageView
    private func setupImageView() {
        splashOne.layer.cornerRadius = 16
        splashTwo.layer.cornerRadius = 16
        splashThree.layer.cornerRadius = 16
    }
    
    //Animate ImageView
    private func animateImageView() {
        // Pan animation for SplashOne Image
        let splashOnePan = CABasicAnimation(keyPath: "position.x")
        splashOnePan.fromValue = splashOne.layer.position.x - 20
        splashOnePan.toValue = splashOne.layer.position.x
        splashOnePan.duration = 0.8
        splashOnePan.autoreverses = true
        splashOnePan.timingFunction = CAMediaTimingFunction(name: .easeIn)
        splashOne.layer.add(splashOnePan, forKey: "topPanAnimation")

        // Pan animation for SplashTwo Image
        let splashTwoPan = CABasicAnimation(keyPath: "position.x")
        splashTwoPan.fromValue = splashTwo.layer.position.x + 20
        splashTwoPan.toValue = splashTwo.layer.position.x
        splashTwoPan.duration = 0.8
        splashTwoPan.autoreverses = true
        splashTwoPan.timingFunction = CAMediaTimingFunction(name: .easeIn)
        splashTwo.layer.add(splashTwoPan, forKey: "middlePanAnimation")

        // Pan animation for SplashThree Image
        let splashThreePan = CABasicAnimation(keyPath: "position.x")
        splashThreePan.fromValue = splashThree.layer.position.x - 20
        splashThreePan.toValue = splashThree.layer.position.x
        splashThreePan.duration = 0.8
        splashThreePan.autoreverses = true
        splashThreePan.timingFunction = CAMediaTimingFunction(name: .easeIn)
        splashThree.layer.add(splashThreePan, forKey: "bottomPanAnimation")
    }
    
    //Setup Gradient Background Method
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer() //Gradient Layer
        gradientLayer.frame = self.view.bounds //Layer Frame Size
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.darkGray.cgColor, UIColor.lightGray.cgColor] //Gradient colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) //Gradient Start Point [Top Left corner]
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0) //Gradient End Point [Bottom Right Corner]
        self.view.layer.insertSublayer(gradientLayer, at: 0) //Add as Sublayer
    }
    
    //Check isFirstLaunch
    func isFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchStatus") //Launched Before
        
        if launchedBefore {
            // User has launched before, go to login screen
            self.navigateToLoginScreen()
        } else {
            // First time launch, go to onboarding screen
            UserDefaults.standard.set(true, forKey: "launchStatus")
            self.navigateToOnboardingScreen()
        }
    }
    
    //Navigate to Login Screen
    private func navigateToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
        self.navigationController?.viewControllers.remove(at: 0)
    }
    
    //Navigate to Onboarding Screen
    private func navigateToOnboardingScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let onboardViewController = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        self.navigationController?.pushViewController(onboardViewController, animated: true)
        self.navigationController?.viewControllers.remove(at: 0)
    }
}
