//
//  OpenWeatherService.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/13/16.
//  Copyright © 2016 Derivative. All rights reserved.
//

import Foundation
import SwiftyJSON
class OpenWeatherService{

    
    var weatherData:[String] = []
    
    static var temp:Double!
    
    class func parseJsonData(_ data: Data) -> Double {
       
            let json = JSON(data:data)

        
            // Parse JSON data
            let weatherData = json["list"][0]["main"]
        
            let weather =  weatherData.dictionaryObject!
  
            print(weather)
            return weather["temp"] as! Double
     
       
    }
    
    
    class func getWeather(_ latitude:Double,longitude:Double)  -> Double{
        
        let request = URLRequest(url: URL(string: "http://api.openweathermap.org/data/2.5/forecast/weather?lat=\(latitude)&lon=\(longitude)&APPID=e5e1ee9cf326da2d6a5ae8d044113ed9&units=imperial")! as URL)
        
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
                temp = self.parseJsonData(data)
                print(data)
               
            }
        })
        
        
        task.resume()
        
        
        return temp
       
        
    }
    


}
