//
//  StudentInformationTableViewCell.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 27/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

class StudentInformationTableViewCell: UITableViewCell {

    // MARK: - Outlets and Properties
    
    @IBOutlet weak var markerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mediaURLLabel: UILabel!
    
    var studentInformation: StudentInformation! {
        didSet{
            nameLabel.text = studentInformation.firstName + " " + studentInformation.lastName
            mediaURLLabel.text = studentInformation.mediaURL
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        markerImageView.tintColor = .white
    }

}
