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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonLoginUdacity.isEnabled = false
    }


    // MARK: - Button actions

    @IBAction func loginButtonPressed(_ sender: Any) {
        print("login with \(inputEmail.text) and \(inputPassword.text)")
        
        // TODO auth
        
        completeLogin()
        
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
            setUILoginEnabled(false)
            return
        }
        
        // sanity checks
        if !email.contains("@") || email.characters.count == 0 || password.characters.count == 0 {
            setUILoginEnabled(false)
            print("incomplete login data")
        } else {
            setUILoginEnabled(true)
        }
    }
    
    func setUILoginEnabled(_ enable: Bool) {
        buttonLoginUdacity.isEnabled = enable
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



