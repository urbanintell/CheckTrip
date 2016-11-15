//
//  PickUp.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 11/14/16.
//  Copyright © 2016 Lusenii Kromah. All rights reserved.
//

import Foundation
class PickUp:NSObject {
    
    var passengerName:String?
    var arrivalAirport:String?
    var arrivalDate:String?
    var arrivalTerminal:String?
    var arrivalGate:String?
    var arrivalTime:String?
    
    var pickupID:String?
    
    func toDictionary() -> [String:String]{
    var dictionary:[String:String] = [:]
    
            dictionary["passengerName"] = passengerName
            dictionary["arrivalAirport"] = arrivalAirport
            dictionary["arrivalDate"] = arrivalDate
            dictionary["arrivalTerminal"] = arrivalTerminal
            dictionary["arrivalGate"] = arrivalGate
            dictionary["arrivalTime"] = arrivalTime
            dictionary["pickupID"] = pickupID
        
        return dictionary
    }
    
}
