//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 23.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

import Foundation


// MARK: UdacityClient class

class UdacityClient {
    
    // MARK: Authentication method
    
    func authenticateUdacityUser(_ username: String, _ password: String, completionHandlerAuth: @escaping (_ success: Bool, _ errorMsg: String?) -> Void) {
        
        // To authenticate Udacity API requests - get a session ID
        getSessionID(username, password) { (success, errorMsg) in
            if success {
                // successfuly logged in, thus delete session ID
                self.deleteSessionID({ (success, errorMsg) in
                    if success {
                        // successfully deleted Session ID
                        completionHandlerAuth(true, nil)
                    } else {
                        // successfully logged in but session ID not properly delete, since session ID will expire within 24 hours, user is granted with access
                        completionHandlerAuth(true, errorMsg!)
                    }
                })
            } else {
                // login failed
                completionHandlerAuth(false, errorMsg!)
            }
        }
    }
    
    // MARK: API Methods
    
    private func getSessionID(_ username: String, _ password: String, completionHandlerGetSessionID: @escaping (_ success: Bool, _ errorMsg: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.ApiSessionUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        performTaskOnUdacityAPI(request: request) { (data, error) in
            
            // guard for data, i.e. no error
            guard let data = data else {
                completionHandlerGetSessionID(false, "Host unreachable - check your network connection")
                return
            }
            
            // parse data - check if credentials are valid
            if let accountDetails = data["account"] as? [String: AnyObject], (accountDetails["registered"] as? Bool)! {
                print(accountDetails)   // TODO TBC dont save users ID, key?
                completionHandlerGetSessionID(true, nil)
            } else {
                completionHandlerGetSessionID(false, "Account not found or invalid credentials")
            }
        }
    }
    
    
    private func deleteSessionID(_ completionHandlerDeleteSessionID: @escaping (_ success: Bool, _ errorMsg: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.ApiSessionUrl)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        performTaskOnUdacityAPI(request: request) { (data, error) in
            
            // check if no error occured deleting session ID
            if let error = error {
                print(error)             // for debugging purpose
                completionHandlerDeleteSessionID(false, "Error deleting the Udacity SessionID")
                return
            }
            
            // since no error occured, assume deleting of the session ID was successful
            completionHandlerDeleteSessionID(true, nil)
        }
    }
    
    
    private func performTaskOnUdacityAPI(request: NSMutableURLRequest, completionHandler: @escaping (_ data: [String: AnyObject]?, _ error: NSError?) -> Void) {
        
        // TODO TBC lower timeout ???
        
        // create a shared URL session
        let session = URLSession.shared
        
        // build and execute the task
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, error as? NSError)
                return
            }
            
            // Udacity specific skipping of the first 5 characters of the response (charecters used for security purposes).
            let range = Range(uncheckedBounds: (5, data.count))
            
            // parse stripped data as json
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data.subdata(in: range), options: .allowFragments) as! [String: AnyObject]
                completionHandler(jsonData, nil)
                
            } catch {
                let userErrMsg = NSError(domain: "performTaskOnUdacityAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "cant parse respons to json"])
                completionHandler(nil, userErrMsg)
            }
        }
        task.resume()
    }
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}



// MARK: UdacityClient (Constants)

extension UdacityClient {

    // MARK: Constants
    
    struct Constants {
        static let ApiSessionUrl = "https://www.udacity.com/api/session"
    }
    
    
}