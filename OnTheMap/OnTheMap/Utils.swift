//
//  Utils.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 26/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

func showNetworkActivityIndicator() {
    performUIUpdatesOnMain{
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}

func hideNetworkActivityIndicator() {
    performUIUpdatesOnMain{
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

func setViewVisibility(view: UIView, hidden: Bool) {
    performUIUpdatesOnMain {
        view.isHidden = hidden
    }
}

func roundButtonCorners(_ button: UIButton) {
    button.layer.cornerRadius = 5.0
    button.clipsToBounds = true
}

func presentCustomAlertForError(errorCode: Int, presentor: UIViewController) {
    var title: String = "", message : String = ""
    
    switch errorCode {
    case -1009: // connection error
        title = Constants.Strings.connectionErrorTitle
        message = Constants.Strings.connectionErroMessage
    case 8: // Geocoding failed
        title = "Geocoding failed"
        message = "Unable to find coordinates for the location."
    case 403: // invalid login credentials
        title = Constants.Strings.invalidCredentialsTitle
        message = Constants.Strings.invalidCredentialsMessage
    case 404: // no result data
        title = "No data received"
        message = "The server did not return any data."
    case 400: // error generating the request
        title = "Bad request"
        message = "Unable to generate the request."
    default:
        ()
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
        (action) in
        alert.dismiss(animated: true, completion: nil)
    })
    alert.addAction(okAction)
    
    // customize appearance
    alert.view.backgroundColor = .white
    alert.view.layer.cornerRadius = 15
    
    performUIUpdatesOnMain {
        presentor.present(alert, animated: true, completion: nil)
    }
}
