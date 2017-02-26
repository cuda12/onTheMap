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
            UIBarButtonItem(image: UIImage(named: "pin")!, style: .plain, target: self, action: #selector(showInformationPostView))
        ]
        
        parent!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // load and add student location data to table
        loadStudentLocations()
    }
    
    func loadStudentLocations() {
        view.alpha = 0.5
        ParseClient.sharedInstance().getStudentLocations { (data, error) in
            // check with error nil and use alerts
            guard let data = data else {
                self.showAlert(title: "No data loaded", details: "Couldnt load any students data, check network and refresh")
                return
            }
            
            self.studentLocations = data
            performUIUpdatesOnMain {
                self.tableStudentLocations.reloadData()
                self.view.alpha = 1.0
            }
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
        cell?.detailTextLabel?.text = studentLocation.updatedAt
        
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
            
            let dismissAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel) 
            alertController.addAction(dismissAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
