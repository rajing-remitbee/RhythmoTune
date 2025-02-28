//
//  LoginViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 25/02/25.
//

import UIKit
import Lottie

class LoginViewController: ViewController {
    
    @IBOutlet weak var loginLottie: LottieAnimationView!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegates
        txtEmailAddress.delegate = self
        txtPassword.delegate = self
        
        //View Setup
        setUpView()
        
        //Keyboard Listener
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    //KeyboardWillShow selector
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height

            // Adjust the view's frame
            self.view.frame.origin.y = 0 - keyboardHeight // Shift upward by keyboard height
        }
    }
    
    //KeyboardWillHide Selector
    @objc func keyboardWillHide(notification: NSNotification) {
        // Restore the view's original frame
        self.view.frame.origin.y = 0
    }
    
    private func setUpView() {
        
        //Hide Navigation Back Button
        navigationItem.hidesBackButton = true
        
        //Setup Font
        signUpButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        
        //Setup lottie
        loginLottie.contentMode = .scaleAspectFit
        loginLottie.loopMode = .loop
        loginLottie.backgroundColor = .clear
        loginLottie.play()
        
        //Style and Hide Activity Indicator
        activityIndicator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        activityIndicator.isHidden = true
    }
    
    //Navigate to SignUp Screen
    private func navigateToSignUpScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) //Main Storyboard
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignUpViewController //SignupViewController
        self.navigationController?.pushViewController(signUpViewController, animated: true) //Navigate to SignupScreen
    }
    
    //Navigate to Home Screen
    private func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) //Main Storyboard
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController //Viewcontroller Screen
        self.navigationController?.setViewControllers([viewController], animated: true) // Set as the only view controller
    }
    
    //Check Valid Email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" //Email Regex
        //Check for valid email
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    //Check Valid Password
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$" //Password Regex
        //Check for valid Password
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    //Show Activity Indicator
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false //Show the activity indicator
        activityIndicator.startAnimating() //Start animation
    }

    //Hide Activity Indicator
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true //Hide the activity indicator
        activityIndicator.stopAnimating() //Stop the animation
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        //Navigate to SignUp Screen
        navigateToSignUpScreen()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        showLoadingIndicator() //Show loading indicator
        
        let email = txtEmailAddress.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = txtPassword.text!
        
        //Email Valid Check
        guard isValidEmail(email) else {
            Snackbar.shared.showErrorMessage(message: "Please check the email address!", on: self.view)
            hideLoadingIndicator()
            return
        }
        
        //Password Valid Check
        guard isValidPassword(password) else {
            Snackbar.shared.showErrorMessage(message: "Please enter valid password!", on: self.view)
            hideLoadingIndicator()
            return
        }
        
        // Async Task
        Task {
            do {
                let _ = try await Appwrite().onLogin(email, password) // Login user
                
                // Success
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    Snackbar.shared.showSuccessMessage(message: "Login Successful!", on: self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.navigateToHomeScreen()
                    }
                }
            } catch {
                // Failure
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    Snackbar.shared.showErrorMessage(message: "Login Failed: \(error.localizedDescription)", on: self.view)
                }
            }
        }
    }
}

//Delegate Extension
extension LoginViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmailAddress {
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            txtPassword.resignFirstResponder()
        }
        return true
    }
}
