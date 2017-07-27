//
//  CustomLoginAlertView.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 26/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

class CustomLoginAlertView : UIView {
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("CustomLoginAlertView", owner: self, options: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("CustomLoginAlertView", owner: self, options: nil)
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("CustomLoginAlertView", owner: self, options: nil)
    }
}
