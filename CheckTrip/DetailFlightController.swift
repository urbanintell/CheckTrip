
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
   
    var tsaURL: String = "http://apps.tsa.dhs.gov/MyTSAWebService/GetTSOWaitTimes.ashx?ap="
    var flightInfo = FlightInfo()
    var tsaInfo = [TSAInfo]()
    var flightData:[String:String]! = [:]
    var latestTSA: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureStorage()
        
        
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        
        view.addSubview(spinner)
        
        spinner.startAnimating()
        
        
        
        let URL = self.flightStatus(airlineCode, airlineNumber: flightNumber, date: flightDate)
        self.getLatestInfo(URL)
        
        //let URLForTSA: String = "http://apps.tsa.dhs.gov/MyTSAWebService/GetTSOWaitTimes.ashx?ap=ATL&output=json"
//        let URLForTSA = self.TSAURL("SEA")
//        self.getTSAInfo(URLForTSA)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func TSAURL(_ depShortCode: String) -> String{
        //break up date
        let url = tsaURL.appending("\(depShortCode)&output=json")
        return url
        
    }
    
    func getTSAInfo(_ url: String) {
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
                
                self.tsaInfo = self.parseTSAJsonData(data: data as NSData)
                self.flightData["tsa"] = self.latestTSA
                
            }
            
        })
        
        task.resume()
    }
    
    func parseTSAJsonData(data: NSData) -> [TSAInfo] {
        
        var tsaInfo = [TSAInfo]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            print(jsonResult)
            let jsonTSAs = jsonResult?["WaitTimes"] as! [AnyObject]
            for jsonTSA in jsonTSAs {
                let info = TSAInfo()
                info.CheckpointIndex = jsonTSA["CheckpointIndex"] as! String
                info.Created_Datetime = jsonTSA["Created_Datetime"] as! String
                if(jsonTSA["WaitTime"] as! String == "1"){
                    info.WaitTimeIndex = "0 min"
                    latestTSA = "0 min"
                }else if(jsonTSA["WaitTime"] as! String == "2"){
                    info.WaitTimeIndex = "1 - 10 min"
                    latestTSA = "1 - 10 min"
                }else if(jsonTSA["WaitTime"] as! String == "3"){
                    info.WaitTimeIndex = "11 - 20 min"
                    latestTSA = "11 - 20 "
                }else if(jsonTSA["WaitTime"] as! String == "4"){
                    info.WaitTimeIndex = "21 - 30 min"
                    latestTSA = "21 - 30 min"
                }else if(jsonTSA["WaitTime"] as! String == "5"){
                    info.WaitTimeIndex = "31 - 45 min"
                    latestTSA = "31 - 45 mi"
                }else if(jsonTSA["WaitTime"] as! String == "6"){
                    info.WaitTimeIndex = "46 - 60 min"
                    latestTSA = "46 - 60 min"
                }else if(jsonTSA["WaitTime"] as! String == "7"){
                    info.WaitTimeIndex = "61 - 90 min"
                    latestTSA = "61 - 90 min"
                }else if(jsonTSA["WaitTime"] as! String == "8"){
                    info.WaitTimeIndex = "91 - 120 min"
                    latestTSA = "91 - 120 min"
                }else{info.WaitTimeIndex = "120+ min"
                latestTSA = "120+ min"}
                
                tsaInfo.append(info)
                break;
            }
            
        } catch {
            print(error)
        }
        
        return tsaInfo
    }
    
    
    func flightStatus(_ airlineName:String,airlineNumber:String,date:String) -> String{
        //break up date
        
        let dataArr:[String] = date.components(separatedBy: "/")
        
        let year = dataArr[0]
        let month = dataArr[1]
        let day = dataArr[2]
        let url = flightStatsUrl.appending("\(airlineName)/\(airlineNumber)/dep/\(year)/\(month)/\(day)?appId=98a92df2&appKey=3644b00bd9356ea1a4c95f65554d23e2&utc=false")
        
        
        return url
        
    }
    
    func getLatestInfo(_ url: String) {
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
                
                //check to see if there is data on the flight
                guard let data = self.parseJsonData(data)  else {
                    
                    self.errorMessage()
                    
                    return
                }
                
                self.flightData = data
                
         
                self.setLabels()
                
                let URLForTSA = self.TSAURL(self.flightData["departureAirportFsCode"]!)
                self.getTSAInfo(URLForTSA)
                
            }
            
        })
        
        task.resume()
    }
    
    func errorMessage(){
        self.spinner.stopAnimating()
        
        let alert = UIAlertController(title: "Flight Error", message:"No flight data was found" , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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
            

            
        }
    }
    
    func parseJsonData(_ data: Data) -> [String:String]? {
        
        var flightDictionary = [String:String]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            let jsonFlights = jsonResult?["flightStatuses"] as! [AnyObject]
            
            for jsonFlight in jsonFlights {
                
                flightDictionary["tsa"] = "N/A"
                //get depature gate code
                if let departureAirportCode =  jsonFlight["departureAirportFsCode"] as? String  {
                    
                     flightDictionary["departureAirportFsCode"] = departureAirportCode
                }else {
                         flightDictionary["departureAirportFsCode"] = "N/A"
                }
               
                //get arrival airport FsCode
                if let arrivalAirportFsCode = jsonFlight["arrivalAirportFsCode"] as? String{
    
                       flightDictionary["arrivalAirportFsCode"] = arrivalAirportFsCode
                }else {
                    flightDictionary["arrivalAirportFsCode"] = "N/A"
                }
            
                //Get gate info
                if let gateInfo = jsonFlight["airportResources"] as? [String:AnyObject] {
                    if let arrivalTerminal =  gateInfo["arrivalTerminal"] as? String{
                        flightDictionary["arrivalTerminal"] = arrivalTerminal
                    } else{
                        flightDictionary["arrivalTerminal"] = "N/A"
                    }

                    //Get arrival gate code
                    if let arrivalGate = gateInfo["arrivalGate"] as? String{
                        flightDictionary["arrivalGate"]  = arrivalGate
                    }else {
                        flightDictionary["arrivalGate"] = "N/A"
                    }
                    
                    //Get departure gate terminal
                    if let departureTerminal = gateInfo["departureTerminal"] as? String{
                    
                        flightDictionary["departureTerminal"] = departureTerminal
                      }else {
                       flightDictionary["departureTerminal"] = "N/A"
                    }

                      //Get departure gate code
                    if let departureGate =  gateInfo["departureGate"] as? String{
                        flightDictionary["departureGate"] = departureGate
                    } else {
                        flightDictionary["departureGate"] = "N/A"
                    }
                }
                
                //get arrival and departure dates
                if let schDep =  jsonFlight["departureDate"] as? [String:AnyObject]{

                    if let departureDateLocal =  schDep["dateLocal"] as? String{
                    
                        flightDictionary["departureDateLocal"] = departureDateLocal
                    } else {
                        flightDictionary["departureDateLocal"] = "N/A"
                    }
                    
                }
               
                if let schArr = jsonFlight["arrivalDate"] as? [String:AnyObject]{
                    if let arrivalDateLocal = schArr["dateLocal"] as? String{
                    
                        flightDictionary["arrivalDateLocal"] = arrivalDateLocal
                        
                    }
                }
                
                if !willCheckBag {
                    flightDictionary["willCheckBag"] = "false"
                }
                    flightDictionary["willCheckBag"] = "true"
                
            }
            
            
            
            //Get airport address
            if let appendix = jsonResult?["appendix"] as? [String:AnyObject]{
                if let airports = appendix["airports"] as! [Any]?{
                    if let departureAirport = airports[0] as? AnyObject  {
                //store airport address
                flightDictionary["departureAirportAddress"] = departureAirport["street1"] as? String
                    }
            }
            }
            
            
        } catch {
            print(error)
        }
        return flightDictionary
    }
    
    func stringToDate(date:String){
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        if let formattedDate = formatter.date(from:date){
            print(formattedDate)
        
        }
        
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
