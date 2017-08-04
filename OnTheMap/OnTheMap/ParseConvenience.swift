//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 21/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation

// MARK: - Parse Convenience - 

extension APIClient {
    
    /// Get a list of student locations
    ///
    /// - Parameter completionHandlerForStudentLocations: Returns an array of results or error, if any
  
    func getStudentLocations(_ completionHandlerForStudentLocations: @escaping (_ result: [[String:AnyObject]]?, _ error: NSError?) -> Void) {
        
        guard let request = self.buildRequestWith(methodType: .get, host: .Parse, parameters: [APIConstants.Parse.ParameterKeys.limit:"100" , APIConstants.Parse.ParameterKeys.order: "-updatedAt"], headers: APIConstants.Parse.HTTPHeaders, requestBody: nil) else {
            completionHandlerForStudentLocations(nil, APIConstants.HTTP.badRequestError)
            return
        }
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                debugPrint("Error :\(String(describing: error))")
                completionHandlerForStudentLocations(nil, error)
                return
            }

            guard let result = result as? [String: AnyObject], let results = result[APIConstants.Parse.JSONResponseKeys.results] as? [[String: AnyObject]], results.count > 0 else {
                debugPrint("Could not fetch results")
                let error = NSError(domain: "getStudentLocations", code: 404, userInfo: nil)
                completionHandlerForStudentLocations(nil, error)
                return
            }
            
            completionHandlerForStudentLocations(results, nil)
        })
    }
    
    
    /// Get the location of a specific student using the whereQuery.
    ///
    /// - Parameters:
    ///   - whereQuery: String to pass as where query to the method
    ///   - completionHandlerForStudentLocations: Returns the student location dictionary or error, if any

    func getStudentLocationWith(whereQuery: String, completionHandlerForStudentLocations: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {

 
        guard let request = self.buildRequestWith(methodType: .get, host: .Parse, parameters: [APIConstants.Parse.ParameterKeys.whereKey: whereQuery], headers: APIConstants.Parse.HTTPHeaders, requestBody: nil) else {
            completionHandlerForStudentLocations(nil, APIConstants.HTTP.badRequestError)
            return
        }
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                debugPrint("Error :\(String(describing: error))")
                completionHandlerForStudentLocations(nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject]else {
                debugPrint("Did not get any result")
                completionHandlerForStudentLocations(nil, nil)
                return
            }
            
            completionHandlerForStudentLocations(result, nil)
            
            debugPrint("Result = :\(result)")
            
        })
    }
    
    
    /// Handles posting a studentlocation using the information passed in body argument
    ///
    /// - Parameters:
    ///   - body: A formatted string with the location data to be passed as HttpBody
    ///   - completionHandlerForPost: Returns the result or error
    func postStudentLocationWith(body: String, completionHandlerForPost:  @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        guard let request = self.buildRequestWith(methodType: .post, host: .Parse, parameters: nil, headers:  APIConstants.Parse.HTTPHeaders, requestBody: body) else {
            completionHandlerForPost(nil, APIConstants.HTTP.badRequestError)
            return
        }
        
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                debugPrint("Error :\(String(describing: error))")
                completionHandlerForPost(nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject]else {
                debugPrint("Did not get any result")
                completionHandlerForPost(nil, nil)
                return
            }
            
            completionHandlerForPost(result, nil)
        })

    }
    
    
    /// Handles the PUT operation for an existing StudentInformation object
    ///
    /// - Parameters:
    ///   - objectId: The objectId as returned by the server after POST request
    ///   - body: A formatted string with the Student Information data, passed as HttpBody
    ///   - completionHandlerForPut: Returns the result dictionary or an error
    func putStudentLocationForObjectId(_ objectId: String, body: String, completionHandlerForPut:  @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        guard let request = self.buildRequestWith(methodType: .put, host: .Parse, parameters: nil, headers:  APIConstants.Parse.HTTPHeaders, requestBody: body) else {
            completionHandlerForPut(nil, APIConstants.HTTP.badRequestError)
            return
        }
        
        request.url?.appendPathComponent(objectId)
        debugPrint("PUT Request URL: \(String(describing: request.url?.absoluteString))")
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                debugPrint("Error :\(String(describing: error))")
                completionHandlerForPut(nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject]else {
                debugPrint("Did not get any result")
                completionHandlerForPut(nil, nil)
                return
            }
            
            completionHandlerForPut(result, nil)
        })
        
    }
}
