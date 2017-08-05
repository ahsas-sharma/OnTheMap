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
    case -1009, 2: // connection error
        title = Constants.Strings.Errors.connectionErrorTitle
        message = Constants.Strings.Errors.connectionErroMessage
    case 8: // Geocoding failed
        title = Constants.Strings.Errors.geocodingFailedTitle
        message = Constants.Strings.Errors.geocodingFailedMessage
    case 403: // invalid login credentials
        title = Constants.Strings.Errors.invalidCredentialsTitle
        message = Constants.Strings.Errors.invalidCredentialsMessage
    case 404: // no result data
        title = Constants.Strings.Errors.noResultTitle
        message = Constants.Strings.Errors.noResultMessage
    case 40310:
        title = Constants.Strings.Errors.invalidConfigurationTitle
        message = Constants.Strings.Errors.invalidConfigurationMessage
    default:
        ()
    }
    
    //DEBUG
    debugPrint("**** PresentCustomAlertForError(), Title: \(title), message:\(message) for code: \(errorCode)")
    
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
