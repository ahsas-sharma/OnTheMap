//
//  APIClient.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 21/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation
import UIKit

class APIClient : NSObject {
    
    // MARK:- Properties
    
    var session = URLSession.shared
    
    static var userId: String?
    static var sessionId: String?
    static var facebookAuthToken: String?
    
    static var studentLocations = [StudentInformation]()
    static var locationsFetchInProgress: Bool = false
    
    let parseHeaders = [APIConstants.HTTP.HeaderKeys.parseApiKey:APIConstants.Parse.apiKey, APIConstants.HTTP.HeaderKeys.parseAppId: APIConstants.Parse.applicationID, APIConstants.HTTP.HeaderKeys.contentType:APIConstants.HTTP.HeaderValues.json]
    
    typealias completionHandler = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    // MARK:- Shared APIClient Instance
    
    class func sharedInstance() -> APIClient {
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        return Singleton.sharedInstance
    }
    
    
    // MARK: Task
    
    func taskForMethod(request: URLRequest, completionHandlerForTask: @escaping completionHandler) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.sendError("There was an error with your request: \(error!)", code: 1, domain: "taskForMethod", completionHandler: completionHandlerForTask)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.sendError("Your request returned a status code other than 2xx!. Code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))", code: ((response as? HTTPURLResponse)?.statusCode)!, domain: "taskForMethod", completionHandler: completionHandlerForTask)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.sendError("No data was returned by the request!", code: 2, domain: "taskForMethod", completionHandler: completionHandlerForTask)
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
    
    func buildRequestWith(methodType: APIConstants.HTTP.MethodType, host: APIConstants.Host, parameters: [String: String]?, headers:[String:String], requestBody: String?) -> NSMutableURLRequest {
        
        // create a new request and set the httpMethod
        let request = NSMutableURLRequest(url: self.buildURLFor(host: host, parameters: parameters))
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
    
    private func buildURLFor(host: APIConstants.Host, parameters: [String: String]?) -> URL {
        
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
            print("URL: \(components.url!.absoluteString)")
            return components.url!
        } else {
            components.queryItems = nil
            print("URL: \(components.url!.absoluteString)")
            return components.url!
        }
    }
    
    
    // substitute the key for the value that is contained within the method name
    private func urlForUserDataWithUserId(_ userId: String) -> String? {
        return APIConstants.Udacity.urlForUserData.appending("\(userId)")
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
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        completionHandler(nil, NSError(domain: domain, code: code, userInfo: userInfo))
        
    }
    
}

