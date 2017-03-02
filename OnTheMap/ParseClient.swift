//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 24.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

import Foundation

class ParseClient {
    
    // MARK: Shared Instance
    
    static let sharedInstance = ParseClient()
   
    
    // MARK: public getter and setter methods
    
    func getStudentLocations(_ completionHandlerGetLoc: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        // query to get latest, hundert entries
        let query = "limit=100&order=-updatedAt"
        
        // request data from Parse API
        requestStudentLocationFromParseAPI(query: query, completionHandler: { (data, error) in
            if let error = error {
                completionHandlerGetLoc(false, error)
            } else {
                StudentLocations.sharedInstance.locations = data!
                completionHandlerGetLoc(true, nil)
            }
        })
    }
    
    
    func getStudentLocation(forUser userId: String, completionHandlerGetLoc: @escaping (_ data: [StudentLocation]?, _ error: NSError?) -> Void) {
        
        // query to get location of given user
        let query = "where={\"uniqueKey\":\"\(userId)\"}"
        
        // request data from Parse API
        requestStudentLocationFromParseAPI(query: query, completionHandler: completionHandlerGetLoc)
    }
    
    
    func setStudentLocation(forStudentLocation location: StudentLocation, completionHandlerSetLoc: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        // distinguish between 'add new values' and 'update existing users id' depending if student location has an objectId
        var urlMethod = Constants.API_URL
        var httpMethod = "POST"
        
        if let objectId = location.objectId {
            urlMethod.append("/\(objectId)")
            httpMethod = "PUT"
        }
        
        // build request
        let request = NSMutableURLRequest(url: URL(string: urlMethod)!)
        request.httpMethod = httpMethod
        request.addValue(Constants.API_ID, forHTTPHeaderField: Constants.API_ID_Field)
        request.addValue(Constants.API_Key, forHTTPHeaderField: Constants.API_KEY_Field)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(location.uniqueKey)\", \"firstName\": \"\(location.firstName)\", \"lastName\": \"\(location.lastName)\",\"mapString\": \"\(location.mapString)\", \"mediaURL\": \"\(location.mediaUrl)\",\"latitude\": \(location.latitude), \"longitude\": \(location.longitude)}".data(using: String.Encoding.utf8)
        
        
        performTaskOnParseAPI(request: request) { (data, error) in
            guard error == nil else {
                completionHandlerSetLoc(false, error)
                return
            }
            completionHandlerSetLoc(true, nil)
        }
    }
    
    
    // MARK: Parse API methods
    
    private func requestStudentLocationFromParseAPI(query: String, completionHandler: @escaping (_ data: [StudentLocation]?, _ error: NSError?) -> Void) {
        
        // parse query sting in a valid url query on the parse API
        let urlQuery = ("\(Constants.API_URL)?\(query)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let request = NSMutableURLRequest(url: URL(string: urlQuery)!)
        request.addValue(Constants.API_ID, forHTTPHeaderField: Constants.API_ID_Field)
        request.addValue(Constants.API_Key, forHTTPHeaderField: Constants.API_KEY_Field)
        
        performTaskOnParseAPI(request: request) { (data, error) in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            if let dataStudentLoc = data["results"] as? [[String: AnyObject]] {
                completionHandler(StudentLocation.studentLocations(fromResults: dataStudentLoc), nil)
            } else {
                completionHandler(nil, NSError(domain: "getStudentLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "no students locations found for query"]))
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
}


// MARK: ParseClient (Constants)

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
