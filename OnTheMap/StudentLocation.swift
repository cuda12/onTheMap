//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 24.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

// MARK: Student Locations class

class StudentLocations {
    
    // shared Instance
    static let sharedInstance = StudentLocations()
    
    // student locations
    var locations = [StudentLocation]()
}


// MARK: Student Location struct

struct StudentLocation {
    
    // MARK: Properties
    
    let objectId: String?
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaUrl: String
    let latitude: Double
    let longitude: Double
    let createdAt: String?
    let updatedAt: String?
    
    
    // MARK: Initializers
    
    // to initialize with dictionary
    // Note: only valid entries (complete) are considered to be initialized as dictionaries
    
    init?(dictionary: [String: AnyObject]) {
        if let ObjectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as? String,
            let UniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String,
            let FirstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String,
            let LastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String,
            let MapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String,
            let MediaUrl = dictionary[ParseClient.JSONResponseKeys.MediaUrl] as? String,
            let Latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double,
            let Longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double,
            let CreatedAt = dictionary[ParseClient.JSONResponseKeys.CreatedAt] as? String,
            let UpdatedAt = dictionary[ParseClient.JSONResponseKeys.UpdateAt] as? String {
            
            objectId = ObjectId
            uniqueKey = UniqueKey
            firstName = FirstName
            lastName = LastName
            mapString = MapString
            mediaUrl = MediaUrl
            latitude = Latitude
            longitude = Longitude
            createdAt = CreatedAt
            updatedAt = UpdatedAt
        } else {
            return nil
        }
    }
    
    // to initialize with user data for new locations to be added
    
    init(UserDetails: UdacityClient.AccountDetails, MapString: String, MediaUrl: String, Latitude: Double, Longitude: Double, ObjectId: String?) {
        objectId = ObjectId
        uniqueKey = UserDetails.UserID
        firstName = UserDetails.FirstName
        lastName = UserDetails.LastName
        mapString = MapString
        mediaUrl = MediaUrl
        latitude = Latitude
        longitude = Longitude
        createdAt = nil
        updatedAt = nil
    }
    
    
    // MARK: getter method to parse result dictionaries
    
    static func studentLocations(fromResults results: [[String: AnyObject]]) -> [StudentLocation] {
        
        var studentLocations = [StudentLocation]()
        
        // loop over results and add as a student location
        for result in results {
            if let studentLoc = StudentLocation(dictionary: result) {
                studentLocations.append(studentLoc)
            }
        }
        
        return studentLocations
    }
}


