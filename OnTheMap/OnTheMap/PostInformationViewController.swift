//
//  PostInformationViewController.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 25/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit
import MapKit

class PostInformationViewController : UIViewController {
    
    @IBOutlet weak var topViewFirst: UIView!
    @IBOutlet weak var bottomViewFirst: UIView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!

    @IBOutlet weak var topViewSecond: UIView!
    @IBOutlet weak var bottomViewSecond: UIView!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var editLocationButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundButtonCorners(findOnMapButton)
        roundButtonCorners(submitButton)
        
        submitButton.layer.borderColor = Constants.Color.udacityLight.cgColor
        submitButton.layer.borderWidth = 0.5
        
        toggleFindButtonState(enabled: false)
        
        locationTextField.text = Constants.Strings.enterYourLocation
        mediaURLTextField.text = Constants.Strings.enterLink
        
    }
    
    // MARK: - Actions -
    
    @IBAction func findOnMapButtonClicked(_ sender: UIButton) {
        geocodeAddress()
    }
    
    @IBAction func editLocationButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Geocode -
    
    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationTextField.text!, completionHandler: { (placemark, error) in
            if let placemark = placemark?[0] {
                
                // set annotation from placemark
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                // get the coordinates from placemark
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                // set the region
                let span = MKCoordinateSpanMake(0.075, 0.075)
                let region =  MKCoordinateRegion(center: coordinates, span: span)
                self.mapView.setRegion(region, animated: true)
                
                self.transitionBottomView()
            } else {
                debugPrint("Geocoding Failed.")
            }
        })
    }
    
    // MARK: - Helper - 
    
    fileprivate func toggleFindButtonState(enabled: Bool) {
        enabled ? (findOnMapButton.alpha = 1.0) : (findOnMapButton.alpha = 0.5)
        findOnMapButton.isEnabled = enabled
    }
    
    func transitionBottomView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.bottomViewFirst.isHidden = true
            self.bottomViewSecond.isHidden = false
        })
        
        UIView.animate(withDuration: 0.2, animations: {
            self.topViewFirst.isHidden = true
            self.topViewSecond.isHidden = false
        })
        self.mapView.isHidden = false
        self.locationTextField.isHidden = true
        
    }
}

// MARK: - Extension - UITextFieldDelegate
extension PostInformationViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case locationTextField:
            locationTextField.text == Constants.Strings.enterYourLocation ? locationTextField.text = "" : ()
        case mediaURLTextField:
            mediaURLTextField.text == Constants.Strings.enterLink ? mediaURLTextField.text = "" : ()
        default: ()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case locationTextField:
            locationTextField.text == "" ? locationTextField.text = Constants.Strings.enterYourLocation : self.toggleFindButtonState(enabled: true)
        case mediaURLTextField:
            mediaURLTextField.text == Constants.Strings.enterLink ? mediaURLTextField.text = "" : ()
        default: ()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

//    REFACTOR
//    private func checkPlaceholderText(textField: UITextField, placeholderText: String) {
//        if textField.text == placeholderText {
//            textField.text = ""
//        } else if textField.text == "" {
//            textField.text = placeholderText
//        }
//    }
    
}
