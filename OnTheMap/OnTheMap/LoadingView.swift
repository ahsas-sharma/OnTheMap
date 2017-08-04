//
//  LoadingView.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 26/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

class LoadingView : UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        prepareAnimations()
    }
    
    // MARK: - Helper -
    
    func setBackground(withColor color: UIColor, alpha: CGFloat) {
        let alphaColor = color.withAlphaComponent(alpha)
        self.backgroundColor = alphaColor

    }
    
    func prepareAnimations() {
        // globe animation
        var globeFrames = [UIImage]()
        for i in 1...6 {
            let image = UIImage(named: "globe_\(i)")!
            globeFrames.append(image)
        }
        
        loadingImageView.animationImages = globeFrames
        loadingImageView.animationDuration = 1
        loadingImageView.startAnimating()
        
        // label animation
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.loadingLabel.alpha = 1.0
        }, completion: nil)
    }
}
