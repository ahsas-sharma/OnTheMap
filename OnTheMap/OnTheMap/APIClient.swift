//
//  APIClient.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 21/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation

class APIClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // authentication
    var sessionId: String? = nil
    var userId: String? = nil
    
    
    private func buildURLFromParameters(_ parameters: [String: String]) {
        
    }
}
