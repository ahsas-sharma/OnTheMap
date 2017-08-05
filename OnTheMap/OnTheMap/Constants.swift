//
//  Constants.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 26/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

struct Constants {
    
    // MARK: - String Literals -
    
    struct Strings {
        
        // LoginVC - Signup URL
        static let udacitySignUpURL = "https://www.udacity.com/account/auth#!/signup"
        
        // PostInformationVC - Placeholder text
        static let enterYourLocation = "Enter your location"
        static let enterLink = "Enter a link"
        
        // LoadingView - Status
        static let loggingIn = "Logging in..."
        static let fetchingLocations = "Fetching student locations..."
        
        // MARK: - Error Titles and Messages -
        
        struct Errors {

            // Invalid credentials
            static let invalidCredentialsTitle = "Invalid Credentials"
            static let invalidCredentialsMessage = "Please check your email and password."
            
            // Invalid Configuration
            static let invalidConfigurationTitle = "Invalid Configuration"
            static let invalidConfigurationMessage = "The server has rejected the request. Please contact customer support."
            
            // No Internet Connection
            static let connectionErrorTitle = "Unable to connect"
            static let connectionErroMessage = "Internet connection appears to be offline."
            
            // Geocoding Failed
            static let geocodingFailedTitle = "Geocoding failed"
            static let geocodingFailedMessage = "Unable to find coordinates for the location."
            
            // No result data
            static let noResultTitle = "No data received"
            static let noResultMessage = "The server did not return any data."
        }
        
    }
    
    // MARK: - Colors -
    
    struct Color {
        static let flatGreenDark = UIColor(red: 49/255, green: 163/255, blue: 67/255, alpha: 1.0)
        static let flatRedDark = UIColor(red: 172/255, green: 40/255, blue: 28/255, alpha: 1.0)
        static let flatRedLight = UIColor(red: 217/255, green: 56/255, blue: 41/255, alpha: 1.0)
        static let udacityLight = UIColor(red: 37/255, green: 161/255, blue: 227/255, alpha: 1.0)
    }
}
