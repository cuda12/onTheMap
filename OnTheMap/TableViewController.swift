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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ParseClient.sharedInstance().getStudentLocations { (studLocData, error) in
            guard let studLocData = studLocData else {
                print("no students locations found")
                return
            }
            
            self.studentLocations = studLocData
            performUIUpdatesOnMain {
                self.tableStudentLocations.reloadData()
            }
        }
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
        
        if let studUrl = URL(string: studentLocation.mediaUrl) {
            print(studUrl)
            app.open(studUrl, options: [:])
        }
    }
}
