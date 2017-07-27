//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 25/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController : UIViewController {
    
    // MARK: - Outlets and Properties -
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var udacityLoginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    
    let apiClient = APIClient()
    
    // Enable login button if both email and password validation returns true
    var enableLoginButton = (false, false)
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        toggleLoginButtonState(enabled: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Actions -
    
    @IBAction func udacityLoginButtonClicked(_ sender: Any) {
        setUIEnabled(enabled: false)
        showNetworkActivityIndicator()
        apiClient.getSessionId(loginDetails: createLoginString(), completionHandlerForGetSessionId: {
            (success, userId , sessionId , error) in
            hideNetworkActivityIndicator()
            if success {
                self.storeLoginResponseDetails(userId: userId!, sessionId: sessionId!, facebookAuthToken: nil)
                self.presentContainerNavigationController()
            } else {
                self.setUIEnabled(enabled: true)
                self.presentCustomAlertForError(errorCode: (error?.code)!)
                
            }
        })
        
    }
    
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        
        UIApplication.shared.open(URL(string:"https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: { (success) in
            // nothing to do here
        })
        
    }
    
    @IBAction func facebookLoginButtonClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile], viewController: self, completion: {
            loginResult in
            switch loginResult {
            case .failed(let error):
                print((error as NSError).code)
                self.setUIEnabled(enabled: true)
                self.presentCustomAlertForError(errorCode: ((error as NSError).code))
            case .cancelled:
                print("User cancelled login.")
            case .success(_, _, let accessToken):
                self.apiClient.getSessionIdWithFacebook(accessToken: accessToken.authenticationToken, completionHandlerForGetSessionId: {
                    (success, userId, sessionId, error) in
                    hideNetworkActivityIndicator()
                    if success {
                        self.storeLoginResponseDetails(userId: userId!, sessionId: sessionId!, facebookAuthToken: accessToken.authenticationToken)
                        self.presentContainerNavigationController()
                    } else {
                        self.setUIEnabled(enabled: true)
                        self.presentCustomAlertForError(errorCode: (error?.code)!)
                    }
                    
                    
                    
                })
            }
            
        })
    }
    
    // MARK: - Helper -
    private func setUIEnabled(enabled: Bool) {
        performUIUpdatesOnMain {
            self.emailTextField.isEnabled = enabled
            self.passwordTextField.isEnabled = enabled
            self.udacityLoginButton.isEnabled = enabled
            self.signupButton.isEnabled = enabled
            self.facebookLoginButton.isEnabled = enabled
        }
    }
    
    private func presentCustomAlertForError(errorCode: Int) {
        var title: String = "", message : String = ""
        
        // move string literals to constants file
        if errorCode == 403 {
            title = "Invalid Credentials"
            message = "Please check your login details and try again"
        } else if errorCode == 1 {
            title = "Unable to connect"
            message = "Please check your network connection and try again"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            (action) in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        
        // customize appearance
        alert.view.backgroundColor = .white
        alert.view.layer.cornerRadius = 15
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createLoginString() -> String {
        return "{\"udacity\": {\"username\": \"\(emailTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}"
    }
    
    private func presentContainerNavigationController() {
        let containerNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "ContainerNavigationController") as! UINavigationController
        self.present(containerNavigationController, animated: true, completion:nil)
    }
    
    private func storeLoginResponseDetails(userId: String, sessionId: String, facebookAuthToken: String?) {
        APIClient.userId = userId
        APIClient.sessionId = sessionId
        if let token = facebookAuthToken {
            APIClient.facebookAuthToken = token
        }
    }
    
    fileprivate func toggleLoginButtonState(enabled: Bool) {
        enabled ? (udacityLoginButton.alpha = 1.0) : (udacityLoginButton.alpha = 0.5)
        udacityLoginButton.isEnabled = enabled
    }
    
    fileprivate func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
}

// MARK: - Extension: UITextFieldDelegate
extension LoginViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (textField == emailTextField) && (textField.text != "") {
            enableLoginButton.0 = self.isValidEmail(textField.text!)
            setFeedbackColorForTextField(textField, success: enableLoginButton.0)
        }
        
        if (textField == passwordTextField) {
            enableLoginButton.1 = textField.text != ""
            setFeedbackColorForTextField(textField, success: enableLoginButton.1)
        }
        
        enableLoginButton == (true, true) ? toggleLoginButtonState(enabled: true) : toggleLoginButtonState(enabled: false)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func setFeedbackColorForTextField(_ textField: UITextField, success: Bool ) {
        success ? (textField.layer.borderColor = Constants.Color.flatGreenDark.cgColor) : (textField.layer.borderColor = Constants.Color.flatRedLight.cgColor)
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
    }
    
}
