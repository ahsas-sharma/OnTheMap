//
//  APIConstants.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 20/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation

struct APIConstants {
    
    // MARK: - Parse - 
    
    struct Parse {
        
        static let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let scheme = "https"
        static let host = "parse.udacity.com"
        static let path = "/parse/classes/StudentLocation"
        
        // MARK: - Parameter Keys
        
        struct ParameterKeys {
            
            static let limit = "limit"
            static let skip = "skip"
            static let order = "order"
            
            static let whereKey = "where"
        }
        
        // MARK: - JSON Response Keys
        
        struct JSONResponseKeys {
            
            // Results
            static let results = "results"
            
            // StudentLocation
            static let objectId = "objectId"
            static let uniqueKey = "uniqueKey"
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let mapString = "mapString"
            static let mediaURL = "mediaURL"
            static let latitude = "latitude"
            static let longitude = "longitude"
            static let createdAt = "createdAt"
            static let updatedAt = "updatedAt"
        }
        
    }

    // MARK: - Udacity -
    
    struct Udacity {
        
        // MARK: - URLs
        
        static let scheme = "https"
        static let host = "www.udacity.com"
        static let pathForSession = "/api/session"
        static let pathForUserData = "api/users/" // Append userId at the end
        
        // MARK: - Facebook
        
        static let facebookAppID = "365362206864879"
        static let facebookSchemeSuffix = "onthemap"
        
        // MARK: - Parameter Keys
        
        struct ParameterKeys {
            
            static let udacity = "udacity"
            static let username = "username"
            static let password = "password"
        }
        
        // MARK: - JSON Response Keys

        struct JSONResponseKeys {
            
            static let account = "account"
            static let registered = "registered"
            static let key = "key"
            
            static let session = "session"
            static let id = "id"
            static let expiration = "expiration"
            
        }
    }
    
    // MARK: - HTTP Headers -
    
    struct HTTPHeaders {
        
        // MARK: - Keys
        
        struct Keys {
            
            static let parseAppId = "X-Parse-Application-Id"
            static let parseApiKey = "X-Parse-REST-API-Key"
            static let accept = "Accept"
            static let contentType = "Content-Type"
            static let xsrf = "X-XSRF-TOKEN"
            
        }
        
        // MARK: - Values 
        
        struct Values {
            static let json = "application/json"
        }
    }
}



