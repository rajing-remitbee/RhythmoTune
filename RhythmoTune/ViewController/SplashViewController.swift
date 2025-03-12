//
//  SplashViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 25/02/25.
//

import UIKit
import Lottie

class SplashViewController: UIViewController {
    
    @IBOutlet weak var splashLottie: LottieAnimationView! //Splash Lottie
    @IBOutlet weak var appHead: UILabel! //App Head
    @IBOutlet weak var appSubHead: UILabel! //App Subhead
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        setupGradientBackground()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isFirstLaunch()
        }
    }
    
    //Setup ImageView
    private func setupView() {
        //Text Styles
        appHead.textColor = .white
        appSubHead.textColor = .white
        
        //Lottie Styles
        splashLottie.contentMode = .scaleAspectFit
        splashLottie.loopMode = .loop
        splashLottie.backgroundColor = .clear
        splashLottie.play()
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
        //Check if user is returning user
        if UserDefaults.standard.string(forKey: "loggedInUserId") != nil {
            //Show success message
            Snackbar.shared.showSuccessMessage(message: "Login Successful!", on: self.view)
            //Navigate to homescreen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.navigateToHomeScreen()
            }
        } else {
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
    
    //Navigate to Home Screen
    private func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
        self.navigationController?.viewControllers.remove(at: 0)
    }
}
