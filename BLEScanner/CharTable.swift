//
//  CharTable.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/20.
//

import Foundation
import UIKit

class CharTableCell: UITableViewCell {
    // --------------------------------------------------------------
    // MARK: LOCAL VARIABLES OF IBOUTLET
    // --------------------------------------------------------------
    
    @IBOutlet weak var charTitle: UILabel!
    @IBOutlet weak var charUUID: UILabel!
    @IBOutlet weak var charSubtitle: UILabel!
}
