//
//  ProfileViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 13/03/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var txtUsername: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup view
        avatarImg.layer.cornerRadius = 60
        btnLogout.layer.cornerRadius = 16
        
        //Generate username
        if let userEmail = UserDefaults.standard.string(forKey: "loggedInUserEmail") {
            if let username = generateUsername(from: userEmail) {
                txtUsername.text = "@\(username)!"
            } else {
                print("Invalid email format.")
            }
        }
        
    }
    
    //Logout button pressed
    @IBAction func btnLogoutTapped(_ sender: UIButton) {
        Task {
            do {
                try await Appwrite().onLogout() //Initiate logout
                clearLocalStorage() //Clear local storage data
                DispatchQueue.main.async {
                    Snackbar.shared.showSuccessMessage(message: "Logout Successful!", on: self.view) //Show snackbar
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigateToLoginScreen() //Navigate to login screen
                    }
                }
            } catch {
                clearLocalStorage() //Clear local storage data
                DispatchQueue.main.async {
                    Snackbar.shared.showErrorMessage(message: "Logout Failed: \(error.localizedDescription)", on: self.view) //Show error Snackbar
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigateToLoginScreen() //Navigate to login screen
                    }
                }
            }
        }
    }
    
    //Generate username
    func generateUsername(from email: String) -> String? {
        //Strip username from email
        guard let atIndex = email.firstIndex(of: "@") else {
            return nil
        }
        let username = String(email[..<atIndex])
        
        // Remove non-alphanumeric characters
        let sanitizedUsername = username.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        if sanitizedUsername.isEmpty {
            return nil;
        }
        return sanitizedUsername
    }
    
    //Navigate to login screen
    func navigateToLoginScreen() {
        DispatchQueue.main.async {
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                let navController = UINavigationController(rootViewController: loginViewController)
                sceneDelegate.window?.rootViewController = navController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    //Clear local storage
    func clearLocalStorage() {
        UserDefaults.standard.removeObject(forKey: "loggedInUserId") //Remove userId
        UserDefaults.standard.removeObject(forKey: "loggedInUserEmail") //Remove userEmail
    }
}
