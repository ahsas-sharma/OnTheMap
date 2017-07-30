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
                print("Error :\(String(describing: error))")
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
    
    func getStudentLocationWith(whereQuery: String, completionHandlerForStudentLocations: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {

 
        guard let request = self.buildRequestWith(methodType: .get, host: .Parse, parameters: [APIConstants.Parse.ParameterKeys.whereKey: whereQuery], headers: APIConstants.Parse.HTTPHeaders, requestBody: nil) else {
            completionHandlerForStudentLocations(nil, APIConstants.HTTP.badRequestError)
            return
        }
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                print("Error :\(String(describing: error))")
                completionHandlerForStudentLocations(nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject]else {
                print("Did not get any result")
                completionHandlerForStudentLocations(nil, nil)
                return
            }
            
            completionHandlerForStudentLocations(result, nil)
            
            print("Result = :\(result)")
            
        })
    }
    
    func postStudentLocationWith(completionHandlerForPost:  @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        let body = "{\"uniqueKey\":\"99999\",\"firstName\": \"Romit\",\"lastName\": \"Humagai\",\"mapString\": \"Mountain View, CA\",\"mediaURL\": \"https://someurl.com\",\"latitude\": 37.386052,\"longitude\": -122.083851}"
        
        guard let request = self.buildRequestWith(methodType: .post, host: .Parse, parameters: nil, headers:  APIConstants.Parse.HTTPHeaders, requestBody: body) else {
            completionHandlerForPost(nil, APIConstants.HTTP.badRequestError)
            return
        }
        
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                print("Error :\(String(describing: error))")
                completionHandlerForPost(nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject]else {
                print("Did not get any result")
                completionHandlerForPost(nil, nil)
                return
            }
            
            completionHandlerForPost(result, nil)
            
            print("Result = :\(result)")
            
        })

    }
    
    func putStudentLocationForObjectId(_ objectId: String, completionHandlerForPut:  @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        let body = "{\"uniqueKey\":\"101799\",\"firstName\": \"Kaun Sa Sas?\",\"lastName\": \"SharmaJi\",\"mapString\": \"Mountain View, CA\",\"mediaURL\": \"https://someurl.com\",\"latitude\": 37.386052,\"longitude\": -122.083851}"
        
        guard let request = self.buildRequestWith(methodType: .put, host: .Parse, parameters: nil, headers:  APIConstants.Parse.HTTPHeaders, requestBody: body) else {
            completionHandlerForPut(nil, APIConstants.HTTP.badRequestError)
            return
        }
        
        request.url?.appendPathComponent(objectId)
        print("PUT Request URL: \(String(describing: request.url?.absoluteString))")
        
        _ = self.taskForMethod(request: request as URLRequest, completionHandlerForTask: {
            (result, error) in
            
            guard error == nil else {
                print("Error :\(String(describing: error))")
                completionHandlerForPut(nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject]else {
                print("Did not get any result")
                completionHandlerForPut(nil, nil)
                return
            }
            
            completionHandlerForPut(result, nil)
        })
        
    }


}
