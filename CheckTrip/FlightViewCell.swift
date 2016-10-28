//
//  FlightViewCell.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 10/13/16.
//  Copyright © 2016 Derivative. All rights reserved.
//

import UIKit

class FlightViewCell: UITableViewCell {

    @IBOutlet var departureFlightLabel:UILabel?
    
    @IBOutlet var departureFlightDateLabel:UILabel?
    
    @IBOutlet var departureTimeNumberLabel:UILabel?
    
    @IBOutlet var arrivalFlightLabel:UILabel?
    
    @IBOutlet var arivalFlightDateLabel:UILabel?
    
    @IBOutlet var arivalFlightTimeLabel:UILabel?
    
    @IBOutlet weak var departureGateLabel: UILabel!
    
    @IBOutlet weak var departureTerminalLabel: UILabel!
    
    @IBOutlet weak var arrivalGateLabel: UILabel!
    
    @IBOutlet weak var arrivalTerminalLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
