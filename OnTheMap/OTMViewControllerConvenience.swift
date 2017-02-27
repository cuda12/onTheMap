//
//  OTMViewControllerConvenience.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 26.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//


// NOTE: Since majority of the functionality of the MapViewController and TableViewController are shared this OTMVicewControllerConvenience 
// class is used for simple code maintenance. The specific delegates are stored within the corresponding view controllers.


import UIKit

class OTMViewControllerConvenience: UIViewController {
    
    var studentLocations = [StudentLocation]()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add navigation controll buttons
        parent!.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadStudentLocations)),
            UIBarButtonItem(image: UIImage(named: "pin")!, style: .plain, target: self, action: #selector(showInformationPostView))
        ]
        
        parent!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
    }
    
    
    func loadStudentLocations() {
        // To be overwritten in child class
        // call getStudentLocations with corresponding handler
    }

    
    func getStudentLocations(_ completionHandler: @escaping () -> Void) {
        enableView(enable: false)
        ParseClient.sharedInstance().getStudentLocations { (data, error) in
            guard let data = data else {
                self.showAlert(title: "No data loaded", details: "Couldnt load any students data, check network and refresh")
                return
            }
            
            self.studentLocations = data
            completionHandler()
        }
    }

    
    func showInformationPostView() {
        let informationPostViewController = storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController
        present(informationPostViewController, animated: true)
    }
    
    
    func logout() {
        dismiss(animated: true, completion: nil)
    }
    

    // MARK: Alert Controller
    
    func showAlert(title: String, details: String) {
        let alertController = UIAlertController()
        
        alertController.title = title
        alertController.message = details
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func enableView(enable: Bool) {
        view.alpha = enable ? 1.0 : 0.5
        activityIndicator.isHidden = enable
    }
}