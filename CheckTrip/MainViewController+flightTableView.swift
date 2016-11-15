//
//  MainViewController+flightTableView.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/23/16.
//  Copyright © 2016 Derivative. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MapKit


//TableView extension of MainViewController
extension MainViewController: UITableViewDataSource,UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        if flights.count == 0 {
            flightTableView.backgroundView = emptyFlightView
            flightTableView.separatorColor = .white
            return flights.count
        }
        
        flightTableView.backgroundView = nil
        return flights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for:indexPath) as? FlightViewCell
        
        let flight = flights[indexPath.row]
        
        //departure gate
        cell?.departureFlightLabel?.text = flight.departureAirportFsCode!
        
        cell?.departureTimeNumberLabel?.text = flight.departureTime
        
        cell?.departureFlightDateLabel?.text = (flight.departureMonthDayYear!)
        
        cell?.departureGateLabel?.text = "Gate: \(flight.departureGate!)"
        
        cell?.departureTerminalLabel?.text = "Terminal: \(flight.departureTerminal!)"
        
        //arrival gate
        cell?.arrivalFlightLabel?.text = flight.arrivalAirportFsCode!
        

        cell?.arivalFlightTimeLabel?.text = flight.arrivalTime
        
        cell?.arivalFlightDateLabel?.text = flight.arrivalMonthDayYear
        
        cell?.arrivalGateLabel?.text = "Gate: \(flight.arrivalGate!)"
        
        cell?.arrivalTerminalLabel?.text = "Terminal: \(flight.arrivalTerminal!)"
        
        return cell!
    }
    
    func stringToDate(date:String) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        
        
        
        let dateFormatted = formatter.date(from: date)
        
        print(dateFormatted)
        
        
        return formatter.string(from: dateFormatted!)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let flight = flights[indexPath.row]
        guard let airportAddreess = flight.departureAirportAddress else {
            return
        }
        
        CLGeocoder().geocodeAddressString(airportAddreess) { (placemark:[CLPlacemark]?, error:Error?) in
            if error != nil{
                return
            }
            
            
            guard let place = placemark else {
            
                return
            }
            let airportLat = Double((place[0].location?.coordinate.latitude)!)
            let airportLng = Double((place[0].location?.coordinate.longitude)!)
            
        
            
            
           
       
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            flights.remove(at: indexPath.row)
            
        }
        
        flightTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBAction func close(segue:UIStoryboardSegue){
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Social Sharing Button
        let shareAction = UITableViewRowAction(style:
            UITableViewRowActionStyle.default, title: "Share", handler: { (action,
                indexPath) -> Void in
                
                let flight = self.flights[indexPath.row]
                
                let defaultText = "Copy this link in pickups to receive notifcations on \(flight.passenger!)'s flight:\n\(flight.linkToFlight!)"
                
                
                
                self.sendSMS(attachment: defaultText)
//            
        })
        
        shareAction.backgroundColor = UIColor.checkTripBlue()
        
        // Delete button
        let deleteAction = UITableViewRowAction(style:
            UITableViewRowActionStyle.default, title: "Delete",handler: { (action,
                indexPath) -> Void in
                // Delete the row from the data source
                let flight = self.flights[indexPath.row]
                
                self.deleteFromFirebase(flight:flight)
                
                
                self.flights.remove(at: indexPath.row)
                
                self.flightTableView.deleteRows(at: [indexPath], with: .fade)
                
        })
        
        return [deleteAction, shareAction]
    }
    
    func deleteFromFirebase(flight:Flight){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            return
        }
        
        let user = ref.database.reference().child("users").child(uid)
        
        if let flightId = flight.value(forKey: "flightId") as? String {
            
            _ = user.child("flights").child(flightId).removeValue { (error, ref) in
                if error != nil {
                    print("error \(error)")
                }
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailFlight" {
            if let indexPath = flightTableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! DetailedFlightViewController
                destinationController.flight = flights[indexPath.row]
                destinationController.latitude = self.latitude
                destinationController.longitude = self.longitude
                
            }
        }
        
        
    }
}
