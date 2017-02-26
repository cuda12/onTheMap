//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 23.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var buttonLoginUdacity: UIButton!
    @IBOutlet weak var labelOutput: UILabel!
    
    var overlayView: UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        overlayView = storyboard?.instantiateViewController(withIdentifier: "LoginAuthViewController").view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableUI(enable: true)
        
        // TODO debugging
        inputEmail.text = "andi@barracudas.ch"
        inputPassword.text = "catfish12"
    }


    // MARK: - Button actions

    @IBAction func loginButtonPressed(_ sender: Any) {
        
        enableUI(enable: false)
        
        // Note: since sanity checks on textfield inputs disable the login button, text properties can be called directly
        
        let username = inputEmail.text!
        let password = inputPassword.text!
        
        // authenticate udacity user
        UdacityClient.sharedInstance().authenticateUdacityUser(username, password, completionHandlerAuth: { (success, errorMsg) in
            
            if success {
                performUIUpdatesOnMain {
                    self.completeLogin()
                }
            } else {
                performUIUpdatesOnMain {
                    self.showLoginAlert(errorMsg!)
                    
                    self.enableUI(enable: true)
                }
            }
        })
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    // MARK: Login completed
    
    private func completeLogin() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "OTMNavigationController") as! UINavigationController
        
        present(controller, animated: true, completion: nil)
    }
    
}

// MARK: Helper methods

private extension LoginViewController {
    func checkValidLoginInputTypes() {
        guard let email = inputEmail.text, let password = inputPassword.text else {
            setLoginButtonEnabled(false)
            return
        }
        
        // sanity checks
        if !email.contains("@") || email.characters.count == 0 || password.characters.count == 0 {
            setLoginButtonEnabled(false)
        } else {
            setLoginButtonEnabled(true)
        }
    }
    
    func setLoginButtonEnabled(_ enable: Bool) {
        buttonLoginUdacity.isEnabled = enable
    }
    
    func enableUI(enable: Bool) {
        inputEmail.isEnabled = enable
        inputPassword.isEnabled = enable
        
        // button enable only if valid inputs, disabling in any case
        if enable {
            checkValidLoginInputTypes()
        } else {
            buttonLoginUdacity.isEnabled = enable
        }
        
        // if disabled overlay with authentification view controller
        if !enable {
            view.addSubview(overlayView!)
        } else {
            overlayView?.removeFromSuperview()
        }
    }
    
    func showLoginAlert(_ errorMsg: String) {
        let alertController = UIAlertController()
        alertController.title = "Login failed"
        alertController.message = errorMsg
        
        let dismissAction = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: TextFieldDelegate methods

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidLoginInputTypes()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



