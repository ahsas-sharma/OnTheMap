//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 24/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation

// MARK: - Udacity Convenience -

extension APIClient {
    
    func getSessionId(loginDetails: String, completionHandlerForGetSessionId: @escaping (_ success: Bool,_ userId: String? ,_ sessionId: String?, _ error: NSError?) -> Void) {
                
        let request = self.buildRequestWith(methodType: .post, host: .Udacity, parameters: nil, headers: APIConstants.Udacity.HTTPHeaders, requestBody: loginDetails)
        
        // Set session path
        request.url = request.url?.appendingPathComponent(APIConstants.Udacity.sessionPath)
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                completionHandlerForGetSessionId(false, nil, nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject],
                let sessionDict = result[APIConstants.Udacity.JSONResponseKeys.session] as? [String: AnyObject],
                let sessionId = sessionDict[APIConstants.Udacity.JSONResponseKeys.id] as? String,
                let accountDict = result[APIConstants.Udacity.JSONResponseKeys.account] as? [String: AnyObject],
                let userId = accountDict[APIConstants.Udacity.JSONResponseKeys.key] as? String
                else {
                    completionHandlerForGetSessionId(false, nil, nil, nil)
                    return
            }
            
            completionHandlerForGetSessionId(true, userId, sessionId, nil)
            
        })
        
    }
    
    func getSessionIdWithFacebook(accessToken: String, completionHandlerForGetSessionId: @escaping (_ success: Bool,_ userId: String? ,_ sessionId: String?, _ error: NSError?) -> Void) {
        
        let body = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}"
        
        let request = self.buildRequestWith(methodType: .post, host: .Udacity, parameters: nil, headers: APIConstants.Udacity.HTTPHeaders, requestBody: body)
        
        // Set session path
        request.url = request.url?.appendingPathComponent(APIConstants.Udacity.sessionPath)
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                completionHandlerForGetSessionId(false, nil, nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject],
                let sessionDict = result[APIConstants.Udacity.JSONResponseKeys.session] as? [String: AnyObject],
                let sessionId = sessionDict[APIConstants.Udacity.JSONResponseKeys.id] as? String,
                let accountDict = result[APIConstants.Udacity.JSONResponseKeys.account] as? [String: AnyObject],
                let userId = accountDict[APIConstants.Udacity.JSONResponseKeys.key] as? String
                else {
                    completionHandlerForGetSessionId(false, nil, nil, nil)
                    return
            }
            
            completionHandlerForGetSessionId(true, userId, sessionId, nil)
            
        })
        
    }
    
    func deleteSession(_ completionHandlerForDeleteId: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        let body = "{\"udacity\": {\"username\": \"sharma.ahsas@gmail.com\", \"password\": \"nanakk01\"}}"
        
        let request = self.buildRequestWith(methodType: .delete, host: .Udacity, parameters: nil, headers: APIConstants.Udacity.HTTPHeaders, requestBody: body)
        
        // Set session path
        request.url = request.url?.appendingPathComponent(APIConstants.Udacity.sessionPath)
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                completionHandlerForDeleteId(false, error)
                return
            }
            
//            guard let result = result as? [String: AnyObject] else {
//                completionHandlerForDeleteId(false, nil)
//                return
//            }
            
            APIClient.sessionId = nil
            APIClient.userId = nil
            completionHandlerForDeleteId(true, nil)
            
        })
        
    }
    
    func getPublicDataForUser(id: String, completionHandlerForGetPublicData: @escaping (_ success: Bool, _ result: [String: AnyObject]?, _ error: NSError?) -> Void ) {
        
        let request = self.buildRequestWith(methodType: .get, host: .Udacity, parameters: nil, headers: APIConstants.Udacity.HTTPHeaders, requestBody: nil)
        
        // Set path to get public data for user
        request.url = request.url?.appendingPathComponent(APIConstants.Udacity.userDataPath).appendingPathComponent(id)
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                completionHandlerForGetPublicData(false, nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject] else {
                completionHandlerForGetPublicData(false, nil, error)
                return
            }
            
            completionHandlerForGetPublicData(true, result, nil)
            
        })
        
    }
    
    
}
