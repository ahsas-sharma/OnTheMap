//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 21/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation

extension APIClient {
    
    
    
    /// Get a list of student locations
    ///
    /// - Parameter completionHandlerForStudentLocations: Returns the result or error, if any
  
    func getStudentLocations(_ completionHandlerForStudentLocations: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        let request = self.buildRequestWith(methodType: APIConstants.HTTP.MethodType.get, host: .Parse, parameters: [:], headers: parseHeaders, requestBody: nil)
        
        _ = self.taskForMethod(request: request, completionHandlerForTask: {
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
    
    func getStudentLocationWith(whereQuery: String, completionHandlerForStudentLocations: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
  
        let request = self.buildRequestWith(methodType: APIConstants.HTTP.MethodType.get, host: .Parse, parameters: [APIConstants.Parse.ParameterKeys.whereKey: whereQuery], headers: parseHeaders, requestBody: nil)
        
        _ = self.taskForMethod(request: request, completionHandlerForTask: {
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
        
        let request = self.buildRequestWith(methodType: APIConstants.HTTP.MethodType.post, host: .Parse, parameters: nil, headers: parseHeaders, requestBody: body)
        
        
        _ = self.taskForMethod(request: request, completionHandlerForTask: {
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
    
    func putStudentLocationForObjectId(_ objectId: String, completionHandlerForPost:  @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        let body = "{\"uniqueKey\":\"101799\",\"firstName\": \"Kaun Sa Sas?\",\"lastName\": \"SharmaJi\",\"mapString\": \"Mountain View, CA\",\"mediaURL\": \"https://someurl.com\",\"latitude\": 37.386052,\"longitude\": -122.083851}"
        
        var request = self.buildRequestWith(methodType: APIConstants.HTTP.MethodType.put, host: .Parse, parameters: nil, headers: parseHeaders, requestBody: body)
        
        request.url?.appendPathComponent(objectId)
        print("PUT Request URL: \(String(describing: request.url?.absoluteString))")
        
        _ = self.taskForMethod(request: request, completionHandlerForTask: {
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


}
