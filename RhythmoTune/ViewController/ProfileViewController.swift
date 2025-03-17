//
//  ProfileViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 13/03/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.text = "User Profile"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(logoutButton) // Add the logoutButton as a subview
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
    }
    
    @objc func logoutTapped() {
        Task {
            do {
                try await Appwrite().onLogout()
                clearLocalStorage()
                DispatchQueue.main.async {
                    Snackbar.shared.showSuccessMessage(message: "Logout Successful!", on: self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigateToLoginScreen()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    Snackbar.shared.showErrorMessage(message: "Logout Failed: \(error.localizedDescription)", on: self.view)
                }
            }
        }
    }
    
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
    
    func clearLocalStorage() {
        UserDefaults.standard.removeObject(forKey: "loggedInUserId")
    }
}
