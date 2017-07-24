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
    
    let apiClient = APIClient()
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton.addTarget(self, action: #selector(facebookLoginButtonClicked), for: .touchUpInside)
        
    }
    
    // MARK: - Facebook -
    
    //     Once the button is clicked, show the login dialog
    @objc func facebookLoginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile], viewController: self, completion: {
            loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("AccessToken: \(accessToken.authenticationToken)")
                print("Permissions: Granted: \(grantedPermissions.debugDescription), Declined : \(declinedPermissions.debugDescription)")
                print("Logged in!")
                self.apiClient.getSessionIdWithFacebook(accessToken: accessToken.authenticationToken, completionHandlerForGetSessionId: {
                    (success, userId, sessionId, error) in
                    guard error == nil else {
                        DispatchQueue.main.async {
                            // perform failure UI updates
                        }
                        return
                    }
                    
                    print("SessionId: \(String(describing: sessionId))")
                    print("UserId: \(String(describing: userId))")
                    self.apiClient.sessionId = sessionId
                    self.apiClient.userId = userId

                    
                })
            }
            
        })
        
    }
}
