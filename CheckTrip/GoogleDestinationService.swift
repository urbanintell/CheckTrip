//
//  GoogleDestinationService.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/16/16.
//  Copyright © 2016 Derivative. All rights reserved.
//

import Foundation
import SwiftyJSON
import GooglePlaces
class GoogleDestinationService: NSObject {
    
    
    var steps:[String] = []
    
    static var temp:Double!
    
    class func parseJsonData(_ data: Data) -> String {
        var googleMapsETA:String!
        do{
           let directionsResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        

           
            
            let routes = directionsResult?["routes"] as! [AnyObject]
            let directions = routes[0] as! [String:AnyObject]
            let leg = directions["legs"] as! [AnyObject]
            let legResults = leg[0] as! [String:AnyObject]
            let duration = legResults["duration"] as! [String:AnyObject]
            
            
            googleMapsETA = duration["text"] as! String
            

        }catch {
            print(error)
        }
        
        return googleMapsETA
    }
    
    
    class func computeDuration(_ originLatitude:Double,originLongitude:Double,destinationLatitude: Double,destinationLongitude:Double)  {
        
        
        var googleMapsETA:String!
        
        let request = URLRequest(url: URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(originLatitude),\(originLongitude)&destination=\(destinationLatitude),\(destinationLongitude)&key=AIzaSyBqB5Y5Ex9n5V33EQ283eC3CXv2UTRckwA")! )
    
        print(request)
        
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request , completionHandler: {
            (data, response, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            // Parse JSON data
            if let data = data {
                //                parseJsonData(data)
                // Reload table view
                
                print(data)
               googleMapsETA =  parseJsonData(data)
               
                
            }
        })
        
      
        task.resume()
        
        
 
    }
    
}
