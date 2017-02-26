//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 25.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {

    var prevObjectId: String?
    var postedLocationCoordiantes: CLLocationCoordinate2D?
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewMid: UIView!
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var buttonPosting: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var textFieldUrl: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIncidactorGeo: UIActivityIndicatorView!
    @IBOutlet weak var labelActivityGeo: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add rounded corners to posting button
        initPostingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // init header label text and its attributes
        initHeaderLabel()
        
        // set up Information Posting View UI and disable UI till user info are checked
        showInformationPostingView(forDefaultPage: true)
        enableInformationPostingView(enable: false)
    
        // check if user already has set a location
        loadUserLocation()
    }
    
    
    // MARK: Buttons actions
    
    @IBAction func togglePostingButton(_ sender: Any) {
        // depending on the page of the view, button either shows the entered location on the map or adds it to parse databse.
        
        enableInformationPostingView(enable: false)
        
        if let searchString = textFieldLocation.text, postedLocationCoordiantes == nil {
            
            // show location on map
            
            forwardGeocoding(address: searchString, completionHandlerFrwdGeocoding: { (coordinates, error) in
                guard let coordinates = coordinates else {
                    performUIUpdatesOnMain {
                        self.showAlert(title: "Location not found", details: "Check your input and make sure your cell is connected to the web")
                        self.enableInformationPostingView(enable: true)
                    }
                    return
                }
                
                self.postedLocationCoordiantes = coordinates
                performUIUpdatesOnMain {
                    self.enableInformationPostingView(enable: true)
                    self.showInformationPostingView(forDefaultPage: false)
                    self.addLocationPinAndCenter(atCoordinates: coordinates)
                }
            })
        } else {
        
            // submit location
            let app = UIApplication.shared
            
            if let urlPostedByUser = URL(string: textFieldUrl.text!), app.canOpenURL(urlPostedByUser) {
                
                // build student location info
                let userStudentLocation = StudentLocation(UserDetails: UdacityClient.sharedInstance().userAccountDetails!, MapString: textFieldLocation.text! , MediaUrl: textFieldUrl.text!, Latitude: Double((postedLocationCoordiantes?.latitude)!), Longitude: Double((postedLocationCoordiantes?.longitude)!), ObjectId: prevObjectId)
                
                // post it
                ParseClient.sharedInstance().setStudentLocation(forStudentLocation: userStudentLocation, completionHandlerSetLoc: { (success, error) in
                    if success {
                        performUIUpdatesOnMain {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        self.showAlert(title: "Failed to add Location", details: "Check your network connection and try again")
                    }
                })
                
            } else {
                showAlert(title: "Invalid URL", details: "Please provide a valid URL")
            }
            
            enableInformationPostingView(enable: true)
        }
    }
    
    @IBAction func toggleCancelButton(_ sender: Any) {
        
        // TBC cancelGeocode() ?? check docu
        dismiss(animated: true, completion: nil)
    }
    
    
    func loadUserLocation() {
        // check if user already set a location, if so set instance member to latest
        
        if let userId = UdacityClient.sharedInstance().userAccountDetails?.UserID {
            ParseClient.sharedInstance().getStudentLocation(forUser: userId, completionHandlerGetLoc: { (data, error) in
                if error == nil {
                    // store latest entry
                    if let usersLocation = data?[0] {
                        self.prevObjectId = usersLocation.objectId!
                    }
                    
                    // user confirm if existing data shall be overwritten
                    let confirmAlert = UIAlertController(title: "Update Location", message: "Are you sure to update your previously added location?", preferredStyle: UIAlertControllerStyle.alert)
                    confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        performUIUpdatesOnMain {
                            self.enableInformationPostingView(enable: true)
                        }
                    }))
                    confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(confirmAlert, animated: true, completion: nil)
                }
            })
        }
    }

    
    
    // MARK: Alert Controller
    
    func showAlert(title: String, details: String, buttonTitle: String = "Cancel") {
        let alertController = UIAlertController()
        
        alertController.title = title
        alertController.message = details
        alertController.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.cancel))
 
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: Textfields delegates

extension InformationPostingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // make sure URL starts with http or https - add if not provide e.g. for www.server.com
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textFieldUrl {
            if let inputedUrl = textField.text {
                if !inputedUrl.contains("http://") && !inputedUrl.contains("https://") {
                    textField.text = "http://\(inputedUrl)"
                }
            }
        }
    }
}


// MARK: Map Kit delegats and helpers

extension InformationPostingViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reusePinId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusePinId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusePinId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // MARK: Map helpers

    func forwardGeocoding(address: String, completionHandlerFrwdGeocoding: @escaping (_ coordinates: CLLocationCoordinate2D?, _ error: NSError?) -> Void) {
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks else {
                // return error
                completionHandlerFrwdGeocoding(nil, error as? NSError)
                return
            }
            
            if placemarks.count > 0, let coordinate = placemarks[0].location?.coordinate {
                completionHandlerFrwdGeocoding(coordinate, nil)
            } else {
                completionHandlerFrwdGeocoding(nil, NSError(domain: "forwardGeocoding", code: 0, userInfo: [NSLocalizedDescriptionKey: "no geolocation found for search string"]))
            }
        }
    }
    
    func addLocationPinAndCenter(atCoordinates coordinates: CLLocationCoordinate2D) {
        
        // add a pin annotation
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Your location"
        
        mapView.addAnnotation(annotation)
        
        // set region
        
        let regionRadius: CLLocationDistance = 1000         // in meters
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
}



// MARK: InformationPosting View methods


extension InformationPostingViewController {
    
    struct colors {
        static let grayishBlue = UIColor(red: 0.318, green: 0.537, blue: 0.705, alpha: 1.0)
        static let lightGray = UIColor(red: 0.905, green: 0.905, blue: 0.905, alpha: 1.0)
        
        static let lightGrayTranslucent = UIColor(red: 0.905, green: 0.905, blue: 0.905, alpha: 0.5)
    }
    
    
    // MARK: Init methods

    func initPostingButton() {
        buttonPosting.layer.cornerRadius = buttonPosting.frame.size.height/2
        buttonPosting.clipsToBounds = true
    }
    
    func initHeaderLabel() {
        let headerLabel = NSMutableAttributedString(string: "Where are you studying today?", attributes: [NSFontAttributeName: UIFont(name: "Roboto-Thin", size: 42)!])
        
        headerLabel.addAttribute(NSFontAttributeName, value: UIFont(name: "Roboto-Medium", size: 42)!, range: NSRange(location: 14, length: 8))
        
        labelHeading.attributedText = headerLabel
        labelHeading.adjustsFontSizeToFitWidth = true
        
    }
    
    
    // MARK: change page and enable/disable view
    
    func showInformationPostingView(forDefaultPage defaultPage: Bool) {
        if defaultPage {
            // hide and show corresponding labels, map and text fields
            textFieldUrl.isHidden = true
            mapView.isHidden = true
            
            textFieldLocation.isHidden = false
            labelHeading.isHidden = false
            
            // adjust button title
            buttonPosting.setTitle("Find on the Map", for: .normal)
            
            // set colors and background colors
            viewTop.backgroundColor = colors.lightGray
            viewBottom.backgroundColor = colors.lightGray
            buttonCancel.setTitleColor(colors.grayishBlue, for: .normal)
            
        } else {
            // show second view
            
            // hide and show corresponding labels, map and text fields
            textFieldUrl.isHidden = false
            mapView.isHidden = false
            
            textFieldLocation.isHidden = true
            labelHeading.isHidden = true
            
            // adjust button title
            buttonPosting.setTitle("Submit", for: .normal)
            
            // set colors and background colors
            viewTop.backgroundColor = colors.grayishBlue
            viewBottom.backgroundColor = colors.lightGrayTranslucent
            buttonCancel.setTitleColor(.white, for: .normal)
        }
    }

    func enableInformationPostingView(enable: Bool) {
        
        // enable or disable all UI elements except cancel button
        
        labelHeading.isEnabled = enable
        textFieldLocation.isEnabled = enable
        textFieldUrl.isEnabled = enable
        buttonPosting.isEnabled = enable
        
        view.alpha = enable ? 1.0 : 0.5
        activityIncidactorGeo.isHidden = enable
        labelActivityGeo.isHidden = enable
    }
}




