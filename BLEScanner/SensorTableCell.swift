//
//  ScanTableCell.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/3/30.
//

import Foundation
import UIKit

class SensorTableCell: UITableViewCell {
    // --------------------------------------------------------------
    // MARK: LOCAL VARIABLES OF IBOUTLET
    // --------------------------------------------------------------
    @IBOutlet weak var sensorName: UILabel!

    // --------------------------------------------------------------
    // MARK: LOCAL FUNCTION DEFINITIONS
    // --------------------------------------------------------------
    
//    private func PrintTrace(_ trace: String) {
//        print("[Scan][ScanTableCell]\(trace)")
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sensorName.text = nil
    }

    // MARK: Cell Configuration

    func configurateTheCell(_ recipe: RecipeSensor) {
        sensorName.text = recipe.sensorName
    }
    
    func configurateTheCellSensorScan(_ recipe: RecipeSensorScan) {
        sensorName.text = recipe.sensorNames
    }
    
}

