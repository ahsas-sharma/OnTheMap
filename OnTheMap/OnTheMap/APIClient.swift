//
//  APIClient.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 21/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation
import UIKit
import FacebookCore
import FacebookLogin

class APIClient : NSObject {
    
    // MARK:- Properties
    
    // store shared URLSession
    var session = URLSession.shared
    
    // facebook login manager
    let loginManager = LoginManager()

    // authentication
    static var userId: String?
    static var sessionId: String?
    static var facebookAuthToken: String?
    
    // studentInformation
    static var studentLocations = [StudentInformation]()
    static var activeStudentDict: [String: AnyObject]?
    static var activeStudentInformation: StudentInformation?
    
    // index of activeStudentInformation object in the studentLocations array
    static var activeStudentInformationIndex: Int?
    
    // prefix to be added for generating unique keys
    static var postPrefixCount = 0

    typealias completionHandler = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    // MARK:- Shared APIClient Instance
    
    class func sharedInstance() -> APIClient {
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        return Singleton.sharedInstance
    }
    
    
    // MARK: Task -
    
    
    /// This is a common function that can be used to generate a data task for performing all networking activites
    ///
    /// - Parameters:
    ///   - request: URLRequest to create the task
    ///   - completionHandlerForTask: Completion Handler that returns result and error
    /// - Returns: URLSessionDataTask
    func taskForMethod(request: URLRequest, completionHandlerForTask: @escaping completionHandler) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                let error = error! as NSError
                self.sendError("There was an error with the data task. Error: \(error) ", code: error.code, domain: error.domain, completionHandler: completionHandlerForTask)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                var errorCode = ((response as? HTTPURLResponse)?.statusCode)!
                
                if request.url?.host == APIConstants.Parse.host &&  (response as? HTTPURLResponse)?.statusCode == 403 {
                       errorCode = 40310
                }
                
                self.sendError("Your request returned a status code other than 2xx!. Code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))", code: errorCode, domain: "taskForMethod", completionHandler: completionHandlerForTask)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.sendError("No data was returned by the request!", code: 404, domain: "taskForMethod", completionHandler: completionHandlerForTask)
                return
            }
            
            // If the host is Udacity, get the subset of data and then call the convertData function
            if request.url?.host == APIConstants.Udacity.host {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range) /* subset response data! */
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForTask)
            } else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForTask)
            }
            
        })
        
        task.resume()
        return task
    }
    
    
    /// This is a common function that builds a NSMutableURLRequest based on the options passed through paramters
    ///
    /// - Parameters:
    ///   - methodType: HTTP Method Type (GET, POST, PUT, DELETE)
    ///   - host: Hostname to connect to
    ///   - parameters: Method parameters
    ///   - headers: HTTP headers to pass with the request
    ///   - requestBody: HTTPBody for the request
    /// - Returns: An NSMutableURLRequest object that can be passed to a data task.
    func buildRequestWith(methodType: APIConstants.HTTP.MethodType, host: APIConstants.Host, parameters: [String: String]?, headers:[String:String], requestBody: String?) -> NSMutableURLRequest? {
        
        // create a new request and set the httpMethod
        guard let url = self.buildURLFor(host: host, parameters: parameters) else {
            return nil
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = methodType.rawValue
        
        // check if there is any json data is provided
        if let requestBody = requestBody {
            request.httpBody = requestBody.data(using: .utf8)
        }
        // add header fields and their values
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // set request timeout to 10 seconds
        request.timeoutInterval = 10.0
        return request
    }
    
    
    
    // MARK:- Helper functions
    
    
    /// Builds the URL using the host and parameters passed from arguments
    ///
    /// - Parameters:
    ///   - host: .Parse or .Udacity
    ///   - parameters: Dictionary containing the parameters for the query
    /// - Returns: An optional URL object that can be used to generate a request
    private func buildURLFor(host: APIConstants.Host, parameters: [String: String]?) -> URL? {
        
        var components = URLComponents()
        
        switch host {
        case .Parse:
            components.scheme = APIConstants.Parse.scheme
            components.host =  APIConstants.Parse.host
            components.path =  APIConstants.Parse.path
        case .Udacity:
            components.scheme = APIConstants.Udacity.scheme
            components.host =  APIConstants.Udacity.host
            components.path =  APIConstants.Udacity.basePath
        }
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            return components.url
        } else {
            components.queryItems = nil
            return components.url
        }
    }
    
    // convert raw JSON into a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: completionHandler) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Unable to parse the following data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // send error for domain
    private func sendError(_ error: String, code: Int, domain: String, completionHandler: completionHandler) {
        debugPrint("###### Sending Error String: \(error), Code : \(code)")
        let userInfo = [NSLocalizedDescriptionKey : error]
        completionHandler(nil, NSError(domain: domain, code: code, userInfo: userInfo))
    }
    
}

