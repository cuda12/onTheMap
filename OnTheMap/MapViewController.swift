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
            UIBarButtonItem(image: UIImage(named: "pin")!, style: .plain, target: self, action: #selector(showInformationPostView))
        ]
        
        parent!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load student locations and add as pins
        loadStudentLocations()
    }
    
    
    func showInformationPostView() {
        
        let informationPostViewController = storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController
        
        present(informationPostViewController, animated: true)
    }
    
    
    func logout() {
        dismiss(animated: true, completion: nil)
    }
    
    func loadStudentLocations() {
        view.alpha = 0.5
        ParseClient.sharedInstance().getStudentLocations { (data, error) in
            guard let data = data else {
                self.showAlert(title: "No data loaded", details: "Couldnt load any students data, check network and refresh")
                return
            }
            
            self.studentLocations = data
            performUIUpdatesOnMain {
                self.addPinsToMapforStudents()
                self.view.alpha = 1.0
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

    // MARK: Alert Controller
    
    func showAlert(title: String, details: String) {
        let alertController = UIAlertController()
        
        alertController.title = title
        alertController.message = details
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        
        present(alertController, animated: true, completion: nil)
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
                
                let dismissAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel)
                alertController.addAction(dismissAction)
                
                present(alertController, animated: true, completion: nil)
            }
        }
    }
}
