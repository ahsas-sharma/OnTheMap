//
//  ViewController.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 20/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    let apiClient = APIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func printGetStudentLocations() {
        let _ = apiClient.getStudentLocations( {
            (result, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    // perform failure UI updates
                }
                return
            }
            
            guard let results = result?[APIConstants.Parse.JSONResponseKeys.results] as? [[String: AnyObject]] else {
                return
            }
            
            print(results.count)
            DispatchQueue.main.async {
                // perform success UI updates
            }
        })
      
    }
    
    @IBAction func printGetStudentLocation() {
        let _ = apiClient.getStudentLocationWith(whereQuery: "{\"firstName\":\"Romit\"}", completionHandlerForStudentLocations: {
            (result, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    // perform failure UI updates
                }
                return
            }
            
            guard let results = result?[APIConstants.Parse.JSONResponseKeys.results] as? [[String: AnyObject]] else {
                return
            }
            
            print(results.count)
            DispatchQueue.main.async {
                // perform success UI updates
            }
        })

    }
    
    @IBAction func printPostStudentLocation() {
        
        let _ = apiClient.postStudentLocationWith(completionHandlerForPost: {
        (result, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    // perform failure UI updates
                }
                return
            }
            
            DispatchQueue.main.async {
                // perform success UI updates
            }

        })
        
    }
    
    @IBAction func printPutStudentLocation() {
        
        let _ = apiClient.putStudentLocationForObjectId("gIt0a2Vref", completionHandlerForPost: {
            (result, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    // perform failure UI updates
                }
                return
            }
            
            DispatchQueue.main.async {
                // perform success UI updates
            }
            
        })
        
    }

}
