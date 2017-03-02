//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 25.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

import UIKit

class TableViewController: OTMViewControllerConvenience {

    @IBOutlet weak var tableStudentLocations: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load student locations and add to table
        loadStudentLocations()
    }
    
    override func loadStudentLocations() {
        getStudentLocations {
            performUIUpdatesOnMain {
                self.tableStudentLocations.reloadData()
                self.enableView(enable: true)
            }
        }
    }
}


// MARK: Table View Controllers Delegate

extension TableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocations.sharedInstance.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let studentLocation = StudentLocations.sharedInstance.locations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCellId") as UITableViewCell!
        cell?.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell?.imageView?.image = UIImage(named: "pin")
        cell?.detailTextLabel?.text = studentLocation.updatedAt
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = StudentLocations.sharedInstance.locations[indexPath.row]
    
        let app = UIApplication.shared
        
        if let studUrl = URL(string: studentLocation.mediaUrl), app.canOpenURL(studUrl) {
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
