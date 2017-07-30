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
    let apiClient = APIClient()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerViewController.mapTabDelegate = self
        addAnnotationsToMapView(withLocations: APIClient.studentLocations)
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
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: { (success) in
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
            self.addAnnotationsToMapView(withLocations: APIClient.studentLocations)
        }
       
    }
    
}
