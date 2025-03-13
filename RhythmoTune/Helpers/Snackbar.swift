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
    private weak var snackbarView: UIView?
    
    private init() {}
    
    //Show snackbar
    func showErrorMessage(message: String, on view: UIView) {
        showSnackBar(message: message, backgroundColor: UIColor(hex: "#F44336"), on: view)
    }
    
    // Show success message
    func showSuccessMessage(message: String, on view: UIView) {
        showSnackBar(message: message, backgroundColor: UIColor(hex: "#4CAF50"), on: view)
    }
    
    private func showSnackBar(message: String, backgroundColor: UIColor, on view: UIView) {
        // Create the snackbar view
        let snackbarView = UIView()
        snackbarView.backgroundColor = backgroundColor
        snackbarView.layer.cornerRadius = 10
        snackbarView.clipsToBounds = true

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
        
        //Set constraints for the Snackbar view
        NSLayoutConstraint.activate([
            snackbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            snackbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            snackbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Initial transform: off the bottom
        snackbarView.transform = CGAffineTransform(translationX: 0, y: snackbarView.frame.height + 20) // Position it below the screen
        
        // Add pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        snackbarView.addGestureRecognizer(panGesture)
        
        //Animate the snackbar
        UIView.animate(withDuration: 0.3, animations: {
            snackbarView.transform = .identity // Slide up to its original position
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hideSnackbar(snackbarView)
            }
        })
        
        // Store the snackbar view for later use (hiding)
        self.snackbarView = snackbarView
    }
    
    // Hide snackbar
    private func hideSnackbar(_ snackbarView: UIView) {
        //Hide animation
        UIView.animate(withDuration: 0.5, animations: {
            snackbarView.alpha = 0.0
            snackbarView.superview?.layoutIfNeeded()
        }, completion: { _ in
            snackbarView.removeFromSuperview()
        })
    }
    
    //Handle Swipe Dismissal
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let snackbarView = gesture.view else { return } //Snackbar
        
        //Horizontal Swipe
        let translation = gesture.translation(in: snackbarView)
        snackbarView.transform = CGAffineTransform(translationX: translation.x, y: 0)
        
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: snackbarView) //Swipe velocity
            if abs(velocity.x) > 500 {
                hideSnackbar(snackbarView) //Dismiss the snackbar if swiped fast
            } else {
                // Return to original position if not swiped fast enough
                UIView.animate(withDuration: 0.3) {
                    snackbarView.transform = .identity
                }
            }
        }
    }
    
}
