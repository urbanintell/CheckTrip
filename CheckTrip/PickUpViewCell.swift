//
//  PickUpViewCell.swift
//  CheckTrip
//
//  Created by Lusenii Kromah on 11/14/16.
//  Copyright © 2016 Lusenii Kromah. All rights reserved.
//

import UIKit

class PickUpViewCell: UITableViewCell {
    
    @IBOutlet var friendsName:UILabel?
    
    @IBOutlet var arrivalFlightLabel:UILabel?
    
    @IBOutlet var arivalFlightDateLabel:UILabel?
    
    @IBOutlet var arivalFlightTimeLabel:UILabel?
    
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
