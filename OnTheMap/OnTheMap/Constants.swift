//
//  Constants.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 26/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

struct Constants {
    
    struct Strings {
        
        // LoginViewController
        static let invalidCredentialsTitle = "Invalid Credentials"
        static let invalidCredentialsMessage = "Please check your email and password."
        
        static let connectionErrorTitle = "No Internet Connection"
        static let connectionErroMessage = "Please check your network connection and try again."
        
        // PostInformationViewController
        static let addressPlaceholder = "Enter your location"
        
    }
    
    struct Color {
        static let flatGreenDark = UIColor(red: 49/255, green: 163/255, blue: 67/255, alpha: 1.0)
        static let flatRedDark = UIColor(red: 172/255, green: 40/255, blue: 28/255, alpha: 1.0)
        static let flatRedLight = UIColor(red: 217/255, green: 56/255, blue: 41/255, alpha: 1.0)
        static let udacityLight = UIColor(red: 37/255, green: 161/255, blue: 227/255, alpha: 1.0)
    }
}
