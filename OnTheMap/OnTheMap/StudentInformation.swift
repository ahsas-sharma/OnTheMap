//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 21/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import Foundation

// MARK: - Student Information -
struct StudentInformation {
    
    // MARK: - Properties
    
    let objectId : String
    let uniqueKey : String
    let firstName : String
    let lastName : String
    
    var mapString : String
    var mediaURL : String
    var latitude : Float
    var longitude : Float
    
    let createdAt : String
    var updatedAt : String
    
    
    // MARK: - Initialzier
    
    init?(dict: [String: AnyObject]) {

        guard let objectId = dict["objectId"], let uniqueKey = dict["uniqueKey"], let firstName = dict["firstName"], let lastName = dict["lastName"], let mapString = dict["mapString"], let mediaURL = dict["mediaURL"], let latitude = dict["latitude"], let longitude = dict["longitude"], let createdAt = dict["createdAt"], let updatedAt = dict["updatedAt"] else {
            debugPrint("Unable to fetch the key/value pairs required by the initializer")
            return nil
        }
        
        self.objectId = objectId as! String
        self.uniqueKey = uniqueKey as! String
        self.firstName = firstName as! String
        self.lastName = lastName as! String
        self.mapString = mapString as! String
        self.mediaURL = mediaURL as! String
        
        self.latitude = latitude as! Float
        self.longitude = longitude as! Float
        self.createdAt = createdAt as! String
        self.updatedAt = updatedAt as! String

    }
    
   func stringForHTTPBody() -> String {
    return "{\"uniqueKey\": \"\(self.uniqueKey)\", \"firstName\": \"\(self.firstName)\", \"lastName\": \"\(self.lastName)\",\"mapString\": \"\(self.mapString)\", \"mediaURL\": \"\(self.mediaURL)\",\"latitude\": \(self.latitude), \"longitude\": \(self.longitude)}"
    }
}
