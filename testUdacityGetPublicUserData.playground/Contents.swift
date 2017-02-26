//: Playground - noun: a place where people can play

import Foundation

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// parse downloaded json file

var pathForJSON = Bundle.main.path(forResource: "udacity_json", ofType: "json")
var rawJSON = try? Data(contentsOf: URL(fileURLWithPath: pathForJSON!))

do {
    let jsonData = try JSONSerialization.jsonObject(with: rawJSON!, options: .allowFragments) as! [String: AnyObject]
    print(jsonData)
    
    
    if let usersData = jsonData["user"] as? [String: AnyObject]  {
        print(usersData)
    }
    
    
} catch {
    print("cant parse json")
}


/*
// make a request

let urlString = "https://www.udacity.com/api/users/9387594692"
let url = URL(string: urlString)
let request = NSMutableURLRequest(url: url!)
let session = URLSession.shared


let task = session.dataTask(with: request as URLRequest) { data, response, error in
    guard let data = data else {
        print("error loading data")
        return
    }
    
    // Udacity specific skipping of the first 5 characters of the response (charecters used for security purposes).
    let range = Range(uncheckedBounds: (5, data.count))
    
    // parse stripped data as json
    do {
        let jsonData = try JSONSerialization.jsonObject(with: data.subdata(in: range), options: .allowFragments) as! [String: AnyObject]
        print(jsonData)
    } catch {
        print("cant parse json")
    }
    
}
task.resume()

*/

/* RESULTS of UrlRequest
 
 ["user": {
 "_image" = "<null>";
 "_image_url" = "//robohash.org/udacity-9387594692.png";
 "_registered" = 1;
 bio = "<null>";
 guard =     {
 "allowed_behaviors" =         (
 register,
 "view-public",
 "view-short"
 );
 };
 key = 9387594692;
 "linkedin_url" = "<null>";
 location = "<null>";
 nickname = Andi;
 occupation = "<null>";
 timezone = "<null>";
 "website_url" = "<null>";
 }]
 
 */








