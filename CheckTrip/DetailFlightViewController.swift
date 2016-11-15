//
//  DetailFlightViewController.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 11/13/16.
//  Copyright © 2016 Lusenii Kromah. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class DetailFlightViewController: UITableViewController, CLLocationManagerDelegate {

    
    var flight:Flight!
    var locationManager = CLLocationManager()
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    
    //departure airport
    @IBOutlet weak var departureLocation: UILabel!
    @IBOutlet weak var departureAirportName: UILabel!
    @IBOutlet weak var departureDate: UILabel!
    @IBOutlet weak var departureTime: UILabel!
    
    //arrival airport
    @IBOutlet weak var arrivalLocation: UILabel!
    @IBOutlet weak var arrivalAirportNam: UILabel!
    @IBOutlet weak var arrivalDate: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
  
    
    var flightNumber: String!
    var flightDate: String!
    var airlineCode: String!
    var willCheckBag: Bool!
    
    var flightStatsUrl: String = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/"
    
    var spinner: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        spinner = UIRefreshControl()
        spinner.attributedTitle = NSAttributedString(string: "Updating flight info")
        spinner.addTarget(self, action: #selector(DetailFlightViewController.getFlightData), for: .valueChanged)
        tableView.addSubview(spinner) // not required when using UITableViewController
        
        departureDate.text = flight.departureMonthDayYear
        departureTime.text = flight.departureTime
        
        
        arrivalDate.text = flight.arrivalMonthDayYear
        arrivalTime.text = flight.arrivalTime
        
        getFlightData()
        
    }
    
    func getFlightData(){
    
        let depUrl = updateDepartingFlight(flight.airlineCode!, airlineNumber: flight.airlineNumber!,date: flight.arrivalMonthDayYear!)
        
        getLatestDepartingInfo(depUrl)
        
        let arrivalUrl = updateArrivalFlight(flight.airlineCode!, airlineNumber: flight.airlineNumber!,date: flight.arrivalMonthDayYear!)
        
        getLatestArrivalInfo(arrivalUrl)
        
        spinner.endRefreshing()
    }
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func close(_ segue:UIStoryboardSegue){
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showETA" {
           
                let destinationController = segue.destination as! ETAController
                destinationController.flight = flight
                destinationController.latitude = self.latitude
                destinationController.longitude = self.longitude
            
        }
    }
    
    func updateDepartingFlight(_ airlineName:String,airlineNumber:String, date:String) -> String{
        //break up date
        let dataArr:[String] = date.components(separatedBy: "/")
        
        let month = dataArr[0]
        let day = dataArr[1]
        let year = dataArr[2]
    
        let url = flightStatsUrl.appending("\(airlineName)/\(airlineNumber)/dep/\(year)/\(month)/\(day)?appId=98a92df2&appKey=3644b00bd9356ea1a4c95f65554d23e2&utc=false")
        
     
        return url
        
    }
 
    
    func updateArrivalFlight(_ airlineName:String,airlineNumber:String, date:String) -> String{
        //break up date
        
        let dataArr:[String] = date.components(separatedBy: "/")
        
        let month = dataArr[0]
        let day = dataArr[1]
        let year = dataArr[2]
        
        let url = flightStatsUrl.appending("\(airlineName)/\(airlineNumber)/arr/\(year)/\(month)/\(day)?appId=98a92df2&appKey=3644b00bd9356ea1a4c95f65554d23e2&utc=false")
        
  
        return url
        
    }
    
    func getLatestArrivalInfo(_ url: String) {
        let request = URLRequest(url: URL(string: url)! as URL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                self.errorMessage()
                print(error)
                return
            }
            
            // Parse JSON data
            if let data = data {
                
                self.parseArrivalJsonData(data)
            }
            
        })
        
        task.resume()
    
    }
    
    
    func getLatestDepartingInfo(_ url: String) {
        let request = URLRequest(url: URL(string: url)! as URL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                self.errorMessage()
                print(error)
                return
            }
            
            // Parse JSON data
            if let data = data {
             
              self.parseDepartureJsonData(data)
                
            }
            
        })
        
        task.resume()
    }
    
    func errorMessage(){
  
        
        let alert = UIAlertController(title: "Flight Error", message:"No flight data was found" , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    func setLabels(){
        
       
    }
    
    func parseDepartureJsonData(_ data: Data)  {
        
      
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
           
          
            
            let appendix = jsonResult?["appendix"] as! [String:AnyObject]
            
            let airports = appendix["airports"] as! [AnyObject]
            
            let airport  = airports[0] as! [String:AnyObject]
  
            OperationQueue.main.addOperation {
                
                self.departureLocation.text = airport["city"] as! String
                self.departureAirportName.text = airport["name"] as! String
            
            }
            
            
          
            
        } catch {
            print(error)
        }
       
    }
    func parseArrivalJsonData(_ data: Data)  {
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            let appendix = jsonResult?["appendix"] as! [String:AnyObject]
            
            let airports = appendix["airports"] as! [AnyObject]
            
            let airport  = airports[airports.count-1] as! [String:AnyObject]
            
            OperationQueue.main.addOperation {
                
                self.arrivalLocation.text = airport["city"] as! String
                self.arrivalAirportNam.text = airport["name"] as! String
        
            }
            
        } catch {
            print(error)
        }
        
    }

}
