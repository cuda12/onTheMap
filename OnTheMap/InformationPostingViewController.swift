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

    var postedLocationString: String?
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewMid: UIView!
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var buttonPosting: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var textFieldUrl: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add rounded corners to posting button
        initPostingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // init header label text and its attributes
        initHeaderLabel()
        
        // set up Information Posting View UI
        setInformationPostingUIView()
    }
    
    
    // MARK: Buttons actions
    
    @IBAction func togglePostingButton(_ sender: Any) {
        guard let postedLocationString = postedLocationString else {
            
            // if no location is set yet, switch to second subview
            
            if let inputedLocation = textFieldLocation.text {
                self.postedLocationString = inputedLocation
            }
            
            // refresh view
            setInformationPostingUIView()
            return
        }
        
        // todo add to db - delete the following only for debugging
        print(postedLocationString)
        self.postedLocationString = nil
        setInformationPostingUIView()
    }
    
    @IBAction func toggleCancelButton(_ sender: Any) {
        print("TODO dismiss view")
    }
    
    
    
    // MARK: Helpers
    
    func setInformationPostingUIView() {
        
        if let postedLocationString = postedLocationString {
            print(postedLocationString)
            // TODO find on map alert otherwise and go back
            
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
            
        } else {
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
        }
    }
    
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
    
    
    
    
}


// MARK Textfields delegates

extension InformationPostingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension InformationPostingViewController: MKMapViewDelegate {
    
}



// MARK View Colors extension

extension InformationPostingViewController {
    
    struct colors {
        static let grayishBlue = UIColor(red: 0.318, green: 0.537, blue: 0.705, alpha: 1.0)
        static let lightGray = UIColor(red: 0.905, green: 0.905, blue: 0.905, alpha: 1.0)
        
        static let lightGrayTranslucent = UIColor(red: 0.905, green: 0.905, blue: 0.905, alpha: 0.5)
    }
    
    
}




