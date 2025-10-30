//
//  ScanTableCell.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/3/30.
//

import Foundation
import UIKit

class SwitchTableCell: UITableViewCell {
    // --------------------------------------------------------------
    // MARK: LOCAL VARIABLES OF IBOUTLET
    // --------------------------------------------------------------
    @IBOutlet weak var switchName: UILabel!

    // --------------------------------------------------------------
    // MARK: LOCAL FUNCTION DEFINITIONS
    // --------------------------------------------------------------
    
//    private func PrintTrace(_ trace: String) {
//        print("[Scan][ScanTableCell]\(trace)")
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        switchName.text = nil
    }

    // MARK: Cell Configuration

    func configurateTheCell(_ recipe: RecipeSwitch) {
        switchName.text = recipe.switchName
    }
    
    func configurateTheCellSwitchScan(_ recipe: RecipeSwitchScan) {
        switchName.text = recipe.switchNames
    }
    
}

