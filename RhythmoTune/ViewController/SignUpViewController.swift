//
//  SignUpViewController.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 26/02/25.
//

import UIKit
import Lottie

class SignUpViewController: UIViewController {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomLottie: LottieAnimationView!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var footerText: UILabel!
    @IBOutlet weak var passwordToggle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegates
        txtEmailAddress.delegate = self
        txtPassword.delegate = self
        
        //Password toggle setup
        passwordToggle.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        
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
    
    //Setup View
    private func setUpView() {
        
        //Hide Navigation Back Button
        navigationItem.hidesBackButton = true
        
        //Setup Font
        loginButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        
        //Style SheetView
        bottomView.layer.cornerRadius = 20
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomView.clipsToBounds = true
        
        //Style and Hide Activity Indicator
        activityIndicator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        activityIndicator.isHidden = true
        
        //Setup Lottie
        bottomLottie.contentMode = .scaleAspectFit
        bottomLottie.loopMode = .loop
        bottomLottie.play()
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

    //Navigate to Home Screen
    private func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) //Main Storyboard
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController //Viewcontroller Screen
        self.navigationController?.setViewControllers([viewController], animated: true) // Set as the only view controller
    }
    
    @IBAction func togglePasswordPressed(_ sender: UIButton) {
        txtPassword.isSecureTextEntry.toggle()
        if txtPassword.isSecureTextEntry {
            sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        //Pop Signup screen from stack
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRegister(_ sender: UIButton) {
        
        showLoadingIndicator() //Show Activity Indicator
        
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
        
        //Async Task - Register
        Task {
            do {
                let (userId, _) = try await Appwrite().onRegister(email, password) //Register user
                
                //Store user details
                UserDefaults.standard.set(userId, forKey: "loggedInUserId")
                
                // Success
                DispatchQueue.main.async {
                    Snackbar.shared.showSuccessMessage(message: "Registration Successful! Navigating to Home Screen!", on: self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.hideLoadingIndicator()
                        self.navigateToHomeScreen()
                    }
                }
            } catch {
                // Failure
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    Snackbar.shared.showErrorMessage(message: "Registration Failed!!", on: self.view)
                }
            }
        }
    }
}

//Delegate Extension
extension SignUpViewController: UITextFieldDelegate {
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
