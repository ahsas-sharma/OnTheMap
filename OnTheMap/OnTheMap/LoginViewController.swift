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
    @IBOutlet weak var loadingView: LoadingView!
    
    let apiClient = APIClient()
    var viewFrameOriginY: CGFloat!

    // Enable login button if both email and password validation returns true
    var enableLoginButton = (false, false)
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup loading view
        loadingView.loadingLabel.text = "Logging in ..."
        loadingView.setBackground(withColor: loadingView.backgroundColor!, alpha: 0.85)
        setViewVisibility(view: loadingView, hidden: true)

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // 
        roundButtonCorners(udacityLoginButton)
        roundButtonCorners(facebookLoginButton)
        toggleLoginButtonState(enabled: false)
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Subscribe to be notified when keyboard appears and move the view as necessary
        self.subscribeToKeyboardNotifications()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe from keyboard notifications
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Actions -
    
    @IBAction func udacityLoginButtonClicked(_ sender: Any) {
        setUIEnabled(enabled: false)
        showNetworkActivityIndicator()
        setViewVisibility(view: loadingView, hidden: false)
        
        apiClient.getSessionId(loginDetails: createLoginString(), completionHandlerForGetSessionId: {
            (success, userId , sessionId , error) in
            hideNetworkActivityIndicator()
            
            if success {
                self.storeLoginResponseDetails(userId: userId!, sessionId: sessionId!, facebookAuthToken: nil)
                self.presentContainerNavigationController()
            } else {
                presentCustomAlertForError(errorCode: (error?.code)!, presentor: self)
            }
            
            self.setUIEnabled(enabled: true)
            setViewVisibility(view: self.loadingView, hidden: true)
        })
        
    }
    
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        UIApplication.shared.open(URL(string: Constants.Strings.udacitySignUpURL)!, options: [:], completionHandler: { (success) in
            // nothing really to do out here
        })
        
    }
    
    // TODO: - Refactor UI state code
    @IBAction func facebookLoginButtonClicked(_ sender: Any) {
        debugPrint("Clicked facebook login")
        showNetworkActivityIndicator()
        self.setUIEnabled(enabled: false)
        setViewVisibility(view: self.loadingView, hidden: false)
        let loginManager = self.apiClient.loginManager
        loginManager.logIn([.publicProfile], viewController: self, completion: {
            loginResult in
            switch loginResult {
            case .failed(let error):
                setViewVisibility(view: self.loadingView, hidden: true)
                presentCustomAlertForError(errorCode: ((error as NSError).code), presentor: self)
            case .cancelled:
                setViewVisibility(view: self.loadingView, hidden: true)
                debugPrint("User cancelled login.")
            case .success(_, _, let accessToken):
                self.apiClient.getSessionIdWithFacebook(accessToken: accessToken.authenticationToken, completionHandlerForGetSessionId: {
                    (success, userId, sessionId, error) in
                    if success {
                        self.storeLoginResponseDetails(userId: userId!, sessionId: sessionId!, facebookAuthToken: accessToken.authenticationToken)
                        self.presentContainerNavigationController()
                    } else {
                        presentCustomAlertForError(errorCode: (error?.code)!, presentor: self)
                    }
                    setViewVisibility(view: self.loadingView, hidden: true)
                })
            }
            self.setUIEnabled(enabled: true)
            hideNetworkActivityIndicator()
        })
    }
    
    // MARK:- Keyboard -
    
    /// Move up the main view by the height of the keyboard
    func keyboardWillShow(_ notification: NSNotification) {
        viewFrameOriginY = view.frame.origin.y
        if passwordTextField.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1) + 64
        }
    }
    
    /// Return frame to its original position
    func keyboardWillHide(_ notification: NSNotification) {
        if let viewFrameOriginY = viewFrameOriginY {
            view.frame.origin.y = viewFrameOriginY
        }
    }
    
    /// Return the height of keyboard's frame using the notification
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    /// Subscribe to get notified when the keyboard is about to show or hide
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Unsubscribe from keyboard notification
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
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

    
    private func createLoginString() -> String {
        return "{\"udacity\": {\"username\": \"\(emailTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}"
    }
    
    private func presentContainerNavigationController() {
        performUIUpdatesOnMain {
            let containerNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "ContainerNavigationController") as! UINavigationController
            self.present(containerNavigationController, animated: true, completion: nil)
        }
      
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
