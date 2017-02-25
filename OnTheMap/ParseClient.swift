//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 24.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

import Foundation

class ParseClient {
    
    func getStudentLocations(_ completionHandlerGetLoc: @escaping (_ data: [StudentLocation]?, _ error: NSError?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.API_URL)!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        performTaskOnParseAPI(request: request) { (data, error) in
            // TODO
            guard let data = data else {
                print("error loading data")
                completionHandlerGetLoc(nil, error)
                return
            }
            
            if let dataStudentLoc = data["results"] as? [[String: AnyObject]] {
                completionHandlerGetLoc(StudentLocation.studentLocations(fromResults: dataStudentLoc), nil)
            } else {
                completionHandlerGetLoc(nil, NSError(domain: "getStudentLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "no students locations found for query"]))
            }
        }
    }
    
    private func performTaskOnParseAPI(request: NSMutableURLRequest, completionHandler: @escaping (_ data: [String: AnyObject]?, _ error: NSError?) -> Void) {
        
        // create a shared URL session
        let session = URLSession.shared
        
        // build and execute the task
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, error as? NSError)
                return
            }
            
            // parse stripped data as json
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                completionHandler(jsonData, nil)
                
            } catch {
                let userErrMsg = NSError(domain: "performTaskOnUdacityAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "cant parse respons to json"])
                completionHandler(nil, userErrMsg)
            }
        }
        task.resume()
    }
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}


extension ParseClient {
    
    struct Constants {
        static let API_ID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let API_Key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let API_URL = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let API_ID_Field = "X-Parse-Application-Id"
        static let API_KEY_Field = "X-Parse-REST-API-Key"
    }
    
    struct JSONResponseKeys {
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdateAt = "updatedAt"
    }
}
