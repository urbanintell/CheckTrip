//
//  ViewController.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/9/16.
//  Copyright © 2016 Derivative. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import MessageUI
class MainViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    var locationManager = CLLocationManager()
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var temp:Double!
    var waitTimesRSS:[(checkpointIndex:String,waitTime:String )] = []
    fileprivate var _refHandle: FIRDatabaseHandle!
     var ref: FIRDatabaseReference!
    @IBOutlet weak var flightTableView: UITableView!
    @IBOutlet var airportSymbol:UILabel!
    @IBOutlet var cityStateLabel:UILabel!
    @IBOutlet var airportFullname:UILabel!
    @IBOutlet var weatherImage:UIImageView!
    @IBOutlet var temperatureLabel:UILabel!
    @IBOutlet var tsaApprovedImage:UIImageView!
    var currentLocation:String?
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var flights:[Flight] = []
    
    var currentUser:[String:Any] = [:]
    
    var isTsaApproved:Bool = true
    
    @IBOutlet var emptyFlightView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpUserLocationAuth()
        flightTableView.delegate = self
        flightTableView.dataSource = self
//        flightTableView.backgroundView = emptyFlightView
        configureDatabase()
        setCurrentUserForSession()
        
    }
    
    func setCurrentUserForSession(){
        
        self.ref = FIRDatabase.database().reference()
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            return
        }
        
        let user:FIRDatabaseReference = ref.child("users").child(uid)
        
        user.observeSingleEvent(of: .value, with: { (snapshot:FIRDataSnapshot) in
            
            
            guard let user = snapshot.value as? [String: Any] else {
            
                return
            }
            self.currentUser = user
            
//            print(self.currentUser)
        })
        
    
    }
    
    func configureDatabase() {
        
        self.ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
        
            return
        }
        
        
        let child:FIRDatabaseReference = ref.child("users").child(uid).child("flights")
        

        
        child.observe(.childAdded
        ) { (snapshot:FIRDataSnapshot) in
            
            if let flightDictionary = snapshot.value as? [String : Any]  {
            
                let flight = Flight()
                flight.setValuesForKeys(flightDictionary)
                
                
                self.flights.append(flight)
                
                OperationQueue.main.addOperation {
                    self.flightTableView.reloadData()
                }
                

            }
//             print("Flight: \(self.flights[0].arrivalGate)")
        }
        
    }
    
    
    func handleTempLabel(){
        OperationQueue.main.addOperation {
        
            self.temperatureLabel.text = "\(self.temp)℉"
        }
    }

    func setUpUserLocationAuth(){
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
          
        }else {
            let alert = UIAlertController(
                title: "Location Error",
                message: "You must enable your location settings",
                preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
    }
    
     func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]){
        guard let location = didUpdateLocations.last else {
        
            let alert = UIAlertController(title: "Error", message: "There was an error getting your location", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            return
        }
        
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
   
        
        locationManager.stopUpdatingLocation()
      reverseGeoCode(latitude, longitude: longitude)
    
    }
    
    func reverseGeoCode(_ latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        
        
        let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
     
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
//                print("GEOCODED: \()")
                
                guard let userLocation = pm.locality else {
                    
                    return
                }
                
                OperationQueue.main.addOperation {
                    self.currentLocation = userLocation
                    self.cityStateLabel?.text = userLocation
                }
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    
    }
    
    
    
    @IBAction func close(_ segue:UIStoryboardSegue){
        
    }

    
    
}
extension MainViewController:MFMessageComposeViewControllerDelegate{
    
    func sendSMS(attachment:String) {
        // Check if the device is capable of sending text message
        guard MFMessageComposeViewController.canSendText() else {
            let alertMessage = UIAlertController(title: "SMS Unavailable", message:
                "Your device is not capable of sending SMS.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default,
                                                 handler: nil))
            present(alertMessage, animated: true, completion: nil)
            return
        }
        // Prefill the SMS
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.body = "\(attachment)"
        // Present message view controller on screen
        present(messageController, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        switch(result.rawValue) {
            
        case MessageComposeResult.cancelled.rawValue:
            print("SMS cancelled")
        case MessageComposeResult.failed.rawValue:
            let alertMessage = UIAlertController(title: "Failure", message: "Failed to send the message.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default,
                                                 handler: nil))
            present(alertMessage, animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("SMS sent")
        default: break
        }
        dismiss(animated: true, completion: nil)
    }
}

