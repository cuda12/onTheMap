//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 24.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var studentLocations = [StudentLocation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // add navigation controll buttons
        parent!.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadStudentLocations)),
            UIBarButtonItem(image: UIImage(named: "pin")!, style: .plain, target: self, action: #selector(test))
        ]
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load student locations and add as pins
        loadStudentLocations()
    }
    
    func test() {
        print("test")
    }
   
    func loadStudentLocations() {
        print("refresh map")
        ParseClient.sharedInstance().getStudentLocations { (data, error) in
            // TODO handle no student data
            guard let data = data else {
                print("no students data loaded")
                return
            }
            
            self.studentLocations = data
            performUIUpdatesOnMain {
                self.addPinsToMapforStudents()
            }
        }
    }
    
    func addPinsToMapforStudents() {
        for studentLocation in studentLocations {
            let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude), longitude: CLLocationDegrees(studentLocation.longitude))
            let fullname = "\(studentLocation.firstName) \(studentLocation.lastName)"
            let mediaURL = studentLocation.mediaUrl
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = fullname
            annotation.subtitle = mediaURL
            
            mapView.addAnnotation(annotation)
        }
    }
}


// MARK: MapKit View Delegates Methods 

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reusePinId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusePinId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusePinId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .green
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let studUrl = URL(string: ((view.annotation?.subtitle)!)!), app.canOpenURL(studUrl) {
                app.open(studUrl, options: [:])
            } else {
                let alertController = UIAlertController()
                
                alertController.title = "No Valid Url"
                alertController.message = "The provided URL can't be opened, select a different student"
                
                let dismissAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(dismissAction)
                
                present(alertController, animated: true, completion: nil)
            }
        }
    }
}
