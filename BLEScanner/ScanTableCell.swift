//
//  ScanTableCell.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/3/30.
//

import Foundation
import UIKit

class ScanTableCell: UITableViewCell {
    // --------------------------------------------------------------
    // MARK: LOCAL VARIABLES OF IBOUTLET
    // --------------------------------------------------------------
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceUUID: UILabel!
    @IBOutlet weak var devicePower: UILabel!

    // --------------------------------------------------------------
    // MARK: LOCAL FUNCTION DEFINITIONS
    // --------------------------------------------------------------
    
    private func PrintTrace(_ trace: String) {
        print("[Scan][ScanTableCell]\(trace)")
    }
}

