//
//  APIClient.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 21/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation

class APIClient : NSObject {
    
    // MARK:- Properties
    
    var session = URLSession.shared
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
                self.sendError("There was an error with your request: \(error!)", domain: "taskForMethod", completionHandler: completionHandlerForTask)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.sendError("Your request returned a status code other than 2xx!. Code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))", domain: "taskForMethod", completionHandler: completionHandlerForTask)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.sendError("No data was returned by the request!", domain: "taskForMethod", completionHandler: completionHandlerForTask)
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForTask)
            
        })
        
        task.resume()
        return task
    }
    
    func buildRequestWith(methodType: String, host: APIConstants.Host, parameters: [String: String]?, headers:[String:String], requestBody: String?) -> URLRequest {
        
        // create a new request and set the httpMethod
        let request = NSMutableURLRequest(url: self.buildURLFor(host: host, parameters: parameters))
        
        request.httpMethod = methodType
        print("Request Method: \(request.httpMethod)")
        
        // check if there is any json data is provided
        if let requestBody = requestBody {
            request.httpBody = requestBody.data(using: .utf8)
            print("Request HTTPBody : \(String(describing: request.httpBody))")
        }
        // add header fields and their values
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        print("Request Headers : \(String(describing: request.allHTTPHeaderFields))")
        
        return request as URLRequest
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
            components.scheme = APIConstants.Parse.scheme
            components.host =  APIConstants.Parse.host
            components.path =  APIConstants.Parse.path
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
    private func sendError(_ error: String, domain: String, completionHandler: completionHandler) {
        print("Sending Error :\(error)")
        let userInfo = [NSLocalizedDescriptionKey : error]
        completionHandler(nil, NSError(domain: domain, code: 1, userInfo: userInfo))
        
    }
}

