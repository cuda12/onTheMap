//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 25.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    var studentLocations = [StudentLocation]()
    
    @IBOutlet weak var tableStudentLocations: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add navigation bar items
        parent!.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadStudentLocations)),
            UIBarButtonItem(image: UIImage(named: "pin")!, style: .plain, target: self, action: #selector(test))
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // load and add student location data to table
        loadStudentLocations()
    }
    
    func loadStudentLocations() {
        print("load student data")
        ParseClient.sharedInstance().getStudentLocations { (studLocData, error) in
            guard let studLocData = studLocData else {
                print("no students locations found")
                return
            }
            
            self.studentLocations = studLocData
            performUIUpdatesOnMain {
                self.tableStudentLocations.reloadData()
                print("table refreshed")
            }
        }
    }
    
    func test() {
        print("test")
    }
}


// MARK: Table View Controllers Delegate

extension TableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let studentLocation = studentLocations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCellId") as UITableViewCell!
        cell?.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell?.imageView?.image = UIImage(named: "pin")
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentLocations[indexPath.row]
    
        let app = UIApplication.shared
        
        if let studUrl = URL(string: studentLocation.mediaUrl), app.canOpenURL(studUrl) {
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
