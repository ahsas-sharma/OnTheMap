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

