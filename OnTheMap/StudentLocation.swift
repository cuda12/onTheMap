//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Andreas Rueesch on 24.02.17.
//  Copyright © 2017 Andreas Rueesch. All rights reserved.
//

// MARK: Student Location struct

struct StudentLocation {
    
    // MARK: Properties
    
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaUrl: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let updatedAt: String
    
    
    // MARK: Initializers
    
    // Note only valid entries are considered
    init?(dictionary: [String: AnyObject]) {
        if let tmpObjectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as? String,
            let tmpUniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String,
            let tmpFirstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String,
            let tmpLastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String,
            let tmpMapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String,
            let tmpMediaUrl = dictionary[ParseClient.JSONResponseKeys.MediaUrl] as? String,
            let tmpLatitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double,
            let tmpLongitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double,
            let tmpCreatedAt = dictionary[ParseClient.JSONResponseKeys.CreatedAt] as? String,
            let tmpUpdatedAt = dictionary[ParseClient.JSONResponseKeys.UpdateAt] as? String {
            
            objectId = tmpObjectId
            uniqueKey = tmpUniqueKey
            firstName = tmpFirstName
            lastName = tmpLastName
            mapString = tmpMapString
            mediaUrl = tmpMediaUrl
            latitude = tmpLatitude
            longitude = tmpLongitude
            createdAt = tmpCreatedAt
            updatedAt = tmpUpdatedAt
        } else {
            return nil
        }
    }
    
    
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
