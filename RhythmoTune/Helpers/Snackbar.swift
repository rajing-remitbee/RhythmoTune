//
//  Snackbar.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 27/02/25.
//

import UIKit

class Snackbar {
    
    //Common instance
    static let shared = Snackbar()
    //
    private var snackbarView: UIView?
    
    private init() {}
    
    //Show snackbar
    func showErrorMessage(message: String, on view: UIView) {
        // Create the snackbar view
        let snackbarView = UIView()
        snackbarView.backgroundColor = UIColor(hex: "#F44336")
        snackbarView.layer.cornerRadius = 10
        snackbarView.clipsToBounds = true
        snackbarView.alpha = 0
        
        // Create the message label
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the snackbar view
        snackbarView.addSubview(messageLabel)
        
        // Set up constraints for the label
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: snackbarView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: snackbarView.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: snackbarView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: snackbarView.bottomAnchor, constant: -10)
        ])
        
        // Add the snackbar view to the main view
        view.addSubview(snackbarView)
        snackbarView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints for the snackbar view
        NSLayoutConstraint.activate([
            snackbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            snackbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            snackbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Animate the snackbar (slide in)
        UIView.animate(withDuration: 0.5, animations: {
            snackbarView.alpha = 1.0
            view.layoutIfNeeded()
        }, completion: { _ in
            // Automatically hide after a delay (e.g., 2 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hideSnackbar(snackbarView)
            }
        })
        
        // Store the snackbar view for later use (hiding)
        self.snackbarView = snackbarView
    }
    
    // Show success message
    func showSuccessMessage(message: String, on view: UIView) {
        // Create the snackbar view
        let snackbarView = UIView()
        snackbarView.backgroundColor = UIColor(hex: "#4CAF50") // Green background for success
        snackbarView.layer.cornerRadius = 10
        snackbarView.clipsToBounds = true
        snackbarView.alpha = 0

        // Create the message label
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add the label to the snackbar view
        snackbarView.addSubview(messageLabel)

        // Set up constraints for the label
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: snackbarView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: snackbarView.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: snackbarView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: snackbarView.bottomAnchor, constant: -10)
        ])

        // Add the snackbar view to the main view
        view.addSubview(snackbarView)
        snackbarView.translatesAutoresizingMaskIntoConstraints = false

        // Set up constraints for the snackbar view
        NSLayoutConstraint.activate([
            snackbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            snackbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            snackbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Animate the snackbar (slide in)
        UIView.animate(withDuration: 0.5, animations: {
            snackbarView.alpha = 1.0
            view.layoutIfNeeded()
        }, completion: { _ in
            // Automatically hide after a delay (e.g., 2 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hideSnackbar(snackbarView)
            }
        })
        
        // Store the snackbar view for later use (hiding)
        self.snackbarView = snackbarView
    }
    
    // Hide snackbar
    private func hideSnackbar(_ snackbarView: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            snackbarView.alpha = 0.0
            snackbarView.superview?.layoutIfNeeded()
        }, completion: { _ in
            snackbarView.removeFromSuperview()
        })
    }
    
}
