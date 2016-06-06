//
//  CloudTrackerAPI.swift
//  FoodTracker
//
//  Created by Zach Smoroden on 2016-06-06.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

public class CloudTrackerAPI: NSObject {
    
    public func post(data:[String:AnyObject], toEndpoint:String, completion: (NSData?, NSError?)->(Void)) {
        
        guard let postJSON = try? NSJSONSerialization.dataWithJSONObject(data, options: []) else {
            print("could not serialize json")
            return
        }
        
        let req = NSMutableURLRequest(URL: NSURL(string:"http://159.203.243.24:8000/\(toEndpoint)")!)
        
        req.HTTPBody = postJSON
        req.HTTPMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(req) { (data, resp, err) in
            
            guard let data = data else {
                print("no data returned from server \(err)")
                return
            }
            
            guard let resp = resp as? NSHTTPURLResponse else {
                print("no response returned from server \(err)")
                return
            }
            
            guard let rawJson = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else {
                print("data returned is not json, or not valid")
                return
            }
            
            guard resp.statusCode == 200 else {
                // handle error
                print("an error occurred \(rawJson["error"])")
                return
            }
            
            // do something with the data returned (decode json, save to user defaults, etc.)
            

            completion(data, err)
        }
        
        task.resume()

    }

}
