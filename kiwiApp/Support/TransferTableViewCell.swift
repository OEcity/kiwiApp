//
//  TransferTableViewCell.swift
//  kiwiApp
//
//  Created by Tom Odler on 19.06.18.
//  Copyright © 2018 Tom Odler. All rights reserved.
//

import UIKit

class TransferTableViewCell: UITableViewCell {
    @IBOutlet weak var cityFromLbl: UILabel!
    @IBOutlet weak var aTimeLbl: UILabel!
    
    @IBOutlet weak var dTimeLbl: UILabel!
    @IBOutlet weak var cityToLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
