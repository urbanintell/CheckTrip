
//
//  DetailFlightController.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/16/16.
//  Copyright © 2016 Derivative. All rights reserved.
//

import UIKit
import Firebase
class DetailFlightController: UIViewController {
    
    @IBOutlet weak var depTextView: UILabel!
    @IBOutlet weak var arvTextView: UILabel!
    @IBOutlet weak var departureTerminalLabel: UILabel!
    @IBOutlet weak var arrivalTerminalLabel: UILabel!
    @IBOutlet weak var departureGateLabel: UILabel!
    @IBOutlet weak var arrivalGateLael: UILabel!
    
    
    
    @IBOutlet weak var departureTimeLabel: UILabel!
    
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
    var firebaseRef: FIRDatabaseReference!
    
    var flightNumber: String!
    var flightDate: String!
    var airlineCode: String!
    var willCheckBag: Bool!
    
    var flightStatsUrl: String = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/"
    var flightInfo = FlightInfo()
    var flightData:[String:String]! = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureStorage()
        
        
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        
        view.addSubview(spinner)
        
        spinner.startAnimating()
        
        let URL = self.flightStatus(airlineCode, airlineNumber: flightNumber, date: flightDate)
        self.getLatestInfo(URL)
        
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func flightStatus(_ airlineName:String,airlineNumber:String,date:String) -> String{
        //break up date
        
        let dataArr:[String] = date.components(separatedBy: "/")
        
        let year = dataArr[0]
        let month = dataArr[1]
        let day = dataArr[2]
        let url = flightStatsUrl.appending("\(airlineName)/\(airlineNumber)/dep/\(year)/\(month)/\(day)?appId=ebdf085d&appKey=1668e8d129b1686e7945852643b0ae44&utc=false")
        
        print(url)
        
        return url
        
    }
    
    func getLatestInfo(_ url: String) {
        let request = URLRequest(url: URL(string: url)! as URL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                print(error)
                return
            }
            
            print(data)
            // Parse JSON data
            if let data = data {
                
                
                self.flightData = self.parseJsonData(data)
                
         
                self.setLabels()
            }
            
        })
        
        task.resume()
    }
    func setLabels(){
        
        OperationQueue.main.addOperation {
            
            guard let departureLabel = self.flightData["departureAirportFsCode"] else {
                self.depTextView.text = "N/A"
                return  }
            self.depTextView.text = departureLabel
            
            
            
            self.departureTerminalLabel.text = "Terminal \(self.flightData["departureTerminal"]!)"
            self.departureGateLabel.text = "Gate \(self.flightData["departureGate"]!)"
            
            self.arvTextView.text = self.flightData["arrivalAirportFsCode"]!
            self.arrivalTerminalLabel.text = "Terminal \(self.flightData["arrivalTerminal"]!)"
            
            self.arrivalGateLael.text = "Gate \(self.flightData["arrivalGate"]! )"
            
            self.spinner.stopAnimating()
            
//            self.departureTimeLabel.text = self.flightInfo.schdepartureTimeNumberLabel
//            
//            
//            
//            self.arrivalTimeLabel.text = self.flightInfo.scharrivalFlightTimeLabel
            
        }
    }
    
    func parseJsonData(_ data: Data) -> [String:String] {
        
        var flightDictionary = [String:String]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            let jsonFlights = jsonResult?["flightStatuses"] as! [AnyObject]
            
            print(jsonFlights)
            
            for jsonFlight in jsonFlights {
                flightDictionary["departureAirportFsCode"] =  jsonFlight["departureAirportFsCode"] as? String
                flightDictionary["arrivalAirportFsCode"] =  jsonFlight["arrivalAirportFsCode"] as? String
                
                let gateInfo = jsonFlight["airportResources"] as! [String:AnyObject]
//                flight.arrivalTerminal = gateInfo["arrivalTerminal"] as! String
                flightDictionary["arrivalTerminal"] =  gateInfo["arrivalTerminal"] as? String
//                flight.arrivalGate = gateInfo["arrivalGate"] as! String
                flightDictionary["arrivalGate"] =  gateInfo["arrivalGate"] as? String
//                flight.departureTerminal = gateInfo["departureTerminal"] as! String
                flightDictionary["departureTerminal"] =  gateInfo["departureTerminal"] as? String
//                flight.departureGate = gateInfo["departureGate"] as! String
                flightDictionary["departureGate"] =  gateInfo["departureGate"] as? String
                
                
                
                let schDep = jsonFlight["departureDate"] as! [String:AnyObject]
//                flight.schdepartureTimeNumberLabel = schDep["dateLocal"] as! String
                flightDictionary["dateLocal"] =  schDep["dateLocal"] as? String
                let schArr = jsonFlight["arrivalDate"] as! [String:AnyObject]
//                flight.scharrivalFlightTimeLabel = schArr["dateLocal"] as! String
                flightDictionary["dateLocal"] =  schArr["dateLocal"] as? String
                
                if !willCheckBag {
                    flightDictionary["willCheckBag"] = "false"
                }
                    flightDictionary["willCheckBag"] = "true"
                
//                flightDictionary["departureAirportAddress"]  = airports[0]["street1"] as? String
            
                
            }
            
            let appendix = jsonResult?["appendix"] as! [String:AnyObject]
            
            let airports = appendix["airports"] as! [AnyObject]
            
            let departureAirport = airports[0]
            
            
            flightDictionary["departureAirportAddress"] = departureAirport["street1"] as? String
            
            print()
            
                print()
        
            
            
        } catch {
            print(error)
        }
        return flightDictionary
    }
    
    
    
    
    func configureStorage() {
     firebaseRef = FIRDatabase.database().reference()
    }
    
    @IBAction func saveFlight(_ sender: UIBarButtonItem) {
        
        let user = FIRAuth.auth()?.currentUser
        guard let uid = user?.uid else {
        
            return
        }
        
        let reference = firebaseRef.database.reference().child("users").child(uid).child("flights").childByAutoId()
            
            flightData["flightId"] = reference.key
                
            reference.setValue(flightData){ (error, ref) -> Void in
                if error != nil {
                    print("\(error)")
                }
            }
        
        
        dismiss(animated: true, completion: nil)
        
        
        
    }
}
