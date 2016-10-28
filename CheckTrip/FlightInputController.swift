//
//  SearchFlightViewController.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/14/16.
//  Copyright © 2016 Derivative. All rights reserved.
//

import UIKit

class FlightInputController: UITableViewController {
    
    
    @IBOutlet weak var flightNumber: UITextField!
    @IBOutlet weak var flightDate: UITextField!
    @IBOutlet weak var airlineCode: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var hasDriver:Bool?
    var hasCheckedInBags:Bool = false
    var flightStatsUrl: String = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/"
    var flightInfo = FlightInfo()
    var date:String?
    @IBOutlet weak var didNotCheckBagButton: UIButton!
    @IBOutlet weak var didCheckBagButton: UIButton!
    
    
    @IBAction func hasCheckedBag(_ sender:UIButton){
        
        switch sender.tag {
        case 0:
            
            didNotCheckBagButton.backgroundColor = UIColor.checkTripBlue()
            didCheckBagButton.backgroundColor = .white
            
            hasCheckedInBags = false
        case 1:
            
            didNotCheckBagButton.backgroundColor = .white
            didCheckBagButton.backgroundColor = UIColor.checkTripBlue()
            
            hasCheckedInBags = true
        default: break
            
        }
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        checkButton.backgroundColor = UIColor.checkTripBlue()
        
        navigationItem.title = "Enter Flight"
        
        
        
        setDefaultDate()
        
        datePicker.addTarget(self, action:#selector(FlightInputController.handler), for: UIControlEvents.valueChanged)
        
    }
    
    @objc func handler(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .full
        timeFormatter.dateFormat = "yyyy/MM/dd"
        
        date = timeFormatter.string(from: datePicker.date)
        
        // do what you want to do with the string.
    }
    
    //set default date to date picker's initial date
    func setDefaultDate(){
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .full
        timeFormatter.dateFormat = "yyyy/MM/dd"
        
        date = timeFormatter.string(from: datePicker.date)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFlightDetail"{
            if let DetailFlightController = segue.destination as? DetailFlightController{
                DetailFlightController.flightNumber = flightNumber.text
                DetailFlightController.flightDate = date!
                DetailFlightController.airlineCode = airlineCode.text
                DetailFlightController.willCheckBag = hasCheckedInBags
                airlineCode.text = ""
                flightNumber.text = ""
             
            }
        }
    }
    
    
    @IBAction func close(_ segue:UIStoryboardSegue){
        
    }
    
    
    
}
