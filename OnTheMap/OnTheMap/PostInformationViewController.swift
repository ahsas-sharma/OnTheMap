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
    
    
    // MARK: - Outlets and Properties
    
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
    
    let apiClient = APIClient.sharedInstance()
    let studentLocations = StudentLocations.sharedInstance()
    var currentCoordinates: CLLocationCoordinate2D!
    var currentRegion: CLRegion!
    var activeStudentDict = [String: AnyObject]()
    var containerVC: ContainerViewController!
    var viewFrameOriginY: CGFloat!

    
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundButtonCorners(findOnMapButton)
        roundButtonCorners(submitButton)
        
        submitButton.layer.borderWidth = 0.5
        toggleSubmitButtonState(enabled: false)
        
        toggleFindButtonState(enabled: false)
        
        setViewVisibility(view: loadingView, hidden: true)
        loadingView.setBackground(withColor: loadingView.backgroundColor!, alpha: 0.85)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If the active user has already posted, populate text fields with their info
        if let studentInfo = APIClient.activeStudentInformation {
            locationTextField.text = studentInfo.mapString
            mediaURLTextField.text = studentInfo.mediaURL
        } else {
            locationTextField.text = Constants.Strings.enterYourLocation
            mediaURLTextField.text = Constants.Strings.enterLink
        }
        
        self.subscribeToKeyboardNotifications()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.unsubscribeToKeyboardNotifications()

    }
    
    // MARK: - Actions -
    
    @IBAction func findOnMapButtonClicked(_ sender: UIButton) {
        geocodeAddress()
    }
    
    
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        self.loadingView.loadingLabel.text = "Submitting your location and link..."
        setViewVisibility(view: loadingView, hidden: false)
        
        generateRequestBody(completionHandler: {
            (body, error) in
            
            guard error == nil else {
                setViewVisibility(view: self.loadingView, hidden: true)
                presentCustomAlertForError(errorCode: error!.code, presentor: self)
                return
            }
            
            // If studentInfo exists, make a PUT request
            if let studentInfo = APIClient.activeStudentInformation {
                
                self.apiClient.putStudentLocationForObjectId(studentInfo.objectId, body: body!, completionHandlerForPut: {
                    (result, error) in
                    
                    guard error == nil else {
                        setViewVisibility(view: self.loadingView, hidden: true)
                        presentCustomAlertForError(errorCode: (error?.code)!, presentor: self)
                        return
                    }
                    
                    guard let result = result,
                        let updatedAt = result[APIConstants.Parse.JSONResponseKeys.updatedAt] as? String else {
                            presentCustomAlertForError(errorCode: 404, presentor: self)
                            return
                    }
                    
                    // update the values
                    APIClient.activeStudentInformation?.mapString = self.locationTextField.text!
                    APIClient.activeStudentInformation?.mediaURL = self.mediaURLTextField.text!
                    APIClient.activeStudentInformation?.latitude = Float(self.currentCoordinates.latitude)
                    APIClient.activeStudentInformation?.longitude = Float(self.currentCoordinates.longitude)
                    APIClient.activeStudentInformation?.updatedAt = updatedAt
                    
                    //if the index exists, remove the object in studentLocations array
                    if APIClient.activeStudentInformationIndex! < self.studentLocations.array.count {
                        self.studentLocations.array.remove(at: APIClient.activeStudentInformationIndex!)
                    }
                    
                    // add the new item
                    APIClient.studentLocations.append(APIClient.activeStudentInformation!)
                    APIClient.activeStudentInformationIndex = self.studentLocations.array.endIndex - 1
                    self.containerVC.mapTabVC.activeUserRegion = self.currentRegion
                    performUIUpdatesOnMain {
                        self.dismiss(animated: true, completion: {
                        })
                    }
                    
                })
            } else {
                self.apiClient.postStudentLocationWith(body: body!, completionHandlerForPost: {
                    (result, error) in
                    
                    guard error == nil else {
                        setViewVisibility(view: self.loadingView, hidden: true)
                        presentCustomAlertForError(errorCode: (error?.code)!, presentor: self)
                        return
                    }
                    
                    guard let result = result,
                        let objectId = result[APIConstants.Parse.JSONResponseKeys.objectId] as? String,
                        let createdAt = result[APIConstants.Parse.JSONResponseKeys.createdAt] as? String else {
                            presentCustomAlertForError(errorCode: 404, presentor: self)
                            return
                    }
                    
                    self.activeStudentDict[APIConstants.Parse.JSONResponseKeys.objectId] = objectId as AnyObject
                    self.activeStudentDict[APIConstants.Parse.JSONResponseKeys.createdAt] = createdAt as AnyObject
                    
                    guard let studentInformation = StudentInformation(dict: self.activeStudentDict) else {
                        debugPrint("Error with the initializer")
                        return
                    }
                    APIClient.activeStudentInformation = studentInformation
                    
                    self.studentLocations.array.append(studentInformation)
                    APIClient.activeStudentInformationIndex = self.studentLocations.array.endIndex - 1
                    self.containerVC.mapTabVC.activeUserRegion = self.currentRegion
                    performUIUpdatesOnMain {
                        self.dismiss(animated: true, completion: {
                        })
                    }
                })
                
            }
            
            
        })
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Geocode -
    
    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        setViewVisibility(view: loadingView, hidden: false)
        geocoder.geocodeAddressString(locationTextField.text!, completionHandler: { (placemark, error) in
            guard error == nil else {
                presentCustomAlertForError(errorCode: (error! as NSError).code, presentor: self)
                setViewVisibility(view: self.loadingView, hidden: true)
                return
            }
            
            guard let placemark = placemark?[0] else {
                presentCustomAlertForError(errorCode: 8, presentor: self)
                setViewVisibility(view: self.loadingView, hidden: true)
                return
            }
            // set annotation from placemark
            self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
            
            // get the coordinates from placemark
            let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
            
            // set the region
            let span = MKCoordinateSpanMake(0.075, 0.075)
            let region =  MKCoordinateRegion(center: coordinates, span: span)
            self.mapView.setRegion(region, animated: true)
            
            self.currentCoordinates = coordinates
            self.containerVC.mapTabVC.userCoordinates = coordinates
            
            setViewVisibility(view: self.loadingView, hidden: true)
            self.transitionToSubmitState()
        })
    }
    
    // MARK:- Keyboard -
    
    /// Move up the main view by the height of the keyboard
    func keyboardWillShow(_ notification: NSNotification) {
        viewFrameOriginY = view.frame.origin.y
        if locationTextField.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1) + 64
        }
    }
    
    /// Return frame to its original position
    func keyboardWillHide(_ notification: NSNotification) {
        if let viewFrameOriginY = viewFrameOriginY {
            view.frame.origin.y = viewFrameOriginY
        }
    }
    
    /// Return the height of keyboard's frame using the notification
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    /// Subscribe to get notified when the keyboard is about to show or hide
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Unsubscribe from keyboard notification
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Helper -
    
    func generateRequestBody(completionHandler: @escaping (_ body: String?, _ error: NSError?) -> Void) {
        
        // If studentInfo already exists, update the mapString and mediaURL values
        if let studentInfo = APIClient.activeStudentInformation {
            
            self.activeStudentDict = self.createStudentInformationDictionary(objectId: studentInfo.objectId, uniqueKey: studentInfo.objectId, first: studentInfo.firstName, last: studentInfo.lastName, mapString: locationTextField.text!, mediaURL: mediaURLTextField.text!, lat: Float(currentCoordinates.latitude), long: Float(currentCoordinates.longitude), createdAt: studentInfo.createdAt, updatedAt: "")
            
            let body  = self.formattedPOSTRequestBodyFrom(dictionary: self.activeStudentDict)
            completionHandler(body, nil)
            
        } else {
            
            apiClient.getPublicDataForUser(id: APIClient.userId!, completionHandlerForGetPublicData: { (success, result, error) in
                
                guard error == nil else {
                    completionHandler(nil, error)
                    return
                }
                
                if let result = result,
                    let user = result[APIConstants.Udacity.JSONResponseKeys.user] as? [String: AnyObject],
                    let firstName = user[APIConstants.Udacity.JSONResponseKeys.firstName] as? String,
                    let lastName = user[APIConstants.Udacity.JSONResponseKeys.lastName] as? String {
                    
                    // create a dictionary with the available student information
                    self.activeStudentDict = self.createStudentInformationDictionary(objectId: "", uniqueKey: self.generateUniqueKey(), first: firstName, last: lastName, mapString: self.locationTextField.text!, mediaURL: self.mediaURLTextField.text!, lat: Float(self.currentCoordinates.latitude), long: Float(self.currentCoordinates.longitude), createdAt: "", updatedAt: "") as [String : AnyObject]
                    
                    // create the body using the dictionary
                    let body = self.formattedPOSTRequestBodyFrom(dictionary: self.activeStudentDict)
                    debugPrint("Request Body:\(body) ")
                    completionHandler(body, nil)
                } else {
                    // Fix error code number
                    let error = NSError(domain: "generatePostRequestBody", code: 10, userInfo: nil)
                    completionHandler(nil, error)
                }
            })
        }
        
    }
    
    func toggleSubmitButtonState(enabled: Bool) {
        submitButton.isEnabled = enabled
        enabled ? (submitButton.layer.borderColor = Constants.Color.udacityLight.cgColor) : (submitButton.layer.borderColor = UIColor.lightGray.cgColor)
        
    }
    
    fileprivate func toggleFindButtonState(enabled: Bool) {
        enabled ? (findOnMapButton.alpha = 1.0) : (findOnMapButton.alpha = 0.5)
        findOnMapButton.isEnabled = enabled
    }
    
    func transitionToSubmitState() {
        UIView.animate(withDuration: 1, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.topViewFirst.isHidden = true
            self.topViewSecond.isHidden = false
            self.bottomViewFirst.isHidden = true
            self.bottomViewSecond.isHidden = false
            self.locationTextField.isHidden = true
            self.mapView.isHidden = false
        }, completion: nil)
    }
    
    private func generateUniqueKey() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        let dateComponent = formatter.string(from: date)
        APIClient.postPrefixCount += 1
        return "\(dateComponent)\(APIClient.postPrefixCount)"
    }
    
    private func createStudentInformationDictionary(objectId: String, uniqueKey: String, first: String, last: String, mapString: String, mediaURL: String, lat: Float, long: Float, createdAt: String, updatedAt: String?) -> [String: AnyObject]{
        var dict = [String:AnyObject]()
        dict[APIConstants.Parse.JSONResponseKeys.objectId] = objectId as AnyObject
        dict[APIConstants.Parse.JSONResponseKeys.uniqueKey] = uniqueKey as AnyObject
        dict[APIConstants.Parse.JSONResponseKeys.firstName] = first as AnyObject
        dict [APIConstants.Parse.JSONResponseKeys.lastName] = last as AnyObject
        dict[APIConstants.Parse.JSONResponseKeys.mapString] = mapString as AnyObject
        dict[APIConstants.Parse.JSONResponseKeys.mediaURL] = mediaURL as AnyObject
        dict[APIConstants.Parse.JSONResponseKeys.latitude] = lat as AnyObject
        dict[APIConstants.Parse.JSONResponseKeys.longitude] = long as AnyObject
        dict[APIConstants.Parse.JSONResponseKeys.createdAt] = createdAt as AnyObject
        dict[APIConstants.Parse.JSONResponseKeys.updatedAt] = updatedAt as AnyObject
        
        return dict
    }
    
    private func formattedPOSTRequestBodyFrom(dictionary dict: [String:AnyObject]) -> String {
        return "{\"\(APIConstants.Parse.JSONResponseKeys.uniqueKey)\":\"\(dict[APIConstants.Parse.JSONResponseKeys.uniqueKey]!)\",\"\(APIConstants.Parse.JSONResponseKeys.firstName)\": \"\(dict[APIConstants.Parse.JSONResponseKeys.firstName]!)\",\"\(APIConstants.Parse.JSONResponseKeys.lastName)\": \"\(dict[APIConstants.Parse.JSONResponseKeys.lastName]!)\",\"\(APIConstants.Parse.JSONResponseKeys.mapString)\": \"\(dict[APIConstants.Parse.JSONResponseKeys.mapString]!)\",\"\(APIConstants.Parse.JSONResponseKeys.mediaURL)\": \"\(dict[APIConstants.Parse.JSONResponseKeys.mediaURL]!)\",\"\(APIConstants.Parse.JSONResponseKeys.latitude)\": \(dict[APIConstants.Parse.JSONResponseKeys.latitude]!),\"\(APIConstants.Parse.JSONResponseKeys.longitude)\": \(dict[APIConstants.Parse.JSONResponseKeys.longitude]!)}"
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
            validateUrl(urlString: mediaURLTextField.text) ? toggleSubmitButtonState(enabled: true) : toggleSubmitButtonState(enabled: false)
            
        default: ()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validateUrl (urlString: String?) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    
}
