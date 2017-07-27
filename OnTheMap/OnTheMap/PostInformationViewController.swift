//
//  PostInformationViewController.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 25/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

class PostInformationViewController : UIViewController {
    
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Extension - UITextFieldDelegate
extension PostInformationViewController : UITextFieldDelegate {
    
}
