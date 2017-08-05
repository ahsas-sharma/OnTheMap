//
//  MapTabViewController.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 27/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit
import MapKit

class MapTabViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var containerViewController: ContainerViewController!
    var annotations = [MKPointAnnotation]()
    
    let apiClient = APIClient.sharedInstance()
    let studentLocations = StudentLocations.sharedInstance()
    
    // Store the region for active user's coordinates. For use after postInformation process.
    var activeUserRegion: CLRegion!
    var userCoordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerViewController.mapTabDelegate = self
        addAnnotationsToMapView(withLocations: studentLocations.array)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If current user's coordinates are available, set the region to center mapview on it
        if let coordinates = userCoordinates {
            // set the region
            let span = MKCoordinateSpanMake(20.000, 20.000)
            let region =  MKCoordinateRegion(center: coordinates, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func addAnnotationsToMapView(withLocations locations:[StudentInformation]) {
        for location in locations {
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = location.fullName()
            annotation.subtitle = location.mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate -
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = Constants.Color.udacityLight
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Open mediaURL when the callout accessory is tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let urlString = view.annotation?.subtitle! {
                guard let url = URL(string:urlString) else {
                    return
                }
                app.open(url, options: [:], completionHandler: { (success) in
                    // nothing really to do out here
                })
            }
        }
    }
}

// MARK: - Extension : ContainerViewDelegate -

extension MapTabViewController : ContainerViewDelegate {
    func refreshStudentLocations() {
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(self.annotations)
            self.addAnnotationsToMapView(withLocations: self.studentLocations.array)
        }
       
    }
    
}
