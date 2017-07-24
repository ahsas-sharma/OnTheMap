//
//  APIConstants.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 20/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation

struct APIConstants {
    
    enum Host {
        case Parse, Udacity
    }

    // MARK: - Parse -

    struct Parse {
        
        static let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let scheme = "https"
        static let host = "parse.udacity.com"
        static let path = "/parse/classes/StudentLocation"
        
        // full url if needed
        static let url = "https://parse.udacity.com/parse/classes/StudentLocation"
        
        // headers
        static let HTTPHeaders = [APIConstants.HTTP.HeaderKeys.parseApiKey:APIConstants.Parse.apiKey, APIConstants.HTTP.HeaderKeys.parseAppId: APIConstants.Parse.applicationID, APIConstants.HTTP.HeaderKeys.contentType:APIConstants.HTTP.HeaderValues.json]

        
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
        static let basePath = "/api"
        static let sessionPath = "/session"
        static let userDataPath = "/users"
        
        // full urls if needed
        static let urlForSession = "https://www.udacity.com/api/session"
        static let urlForUserData = "https://www.udacity.com/api/users/"
        
        // MARK: - Facebook
        
        static let facebookAppID = "365362206864879"
        static let facebookSchemeSuffix = "onthemap"
        
        static let HTTPHeaders = [APIConstants.HTTP.HeaderKeys.accept:APIConstants.HTTP.HeaderValues.json, APIConstants.HTTP.HeaderKeys.contentType:APIConstants.HTTP.HeaderValues.json]

        
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
    
    struct HTTP {
        
        // MARK: - Keys
        
        struct HeaderKeys {
            
            static let parseAppId = "X-Parse-Application-Id"
            static let parseApiKey = "X-Parse-REST-API-Key"
            static let accept = "Accept"
            static let contentType = "Content-Type"
            static let xsrf = "X-XSRF-TOKEN"
            
        }
        
        // MARK: - Values 
        
        struct HeaderValues {
            static let json = "application/json"
        }
        
        // MARK: - Methods
        
        enum MethodType : String {
            case get = "GET"
            case post = "POST"
            case put = "PUT"
            case delete = "DELETE"
        }
    }
    
}



