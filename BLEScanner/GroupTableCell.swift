//
//  ScanTableCell.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/3/30.
//

import Foundation
import UIKit

class GroupTableCell: UITableViewCell {
    // --------------------------------------------------------------
    // MARK: LOCAL VARIABLES OF IBOUTLET
    // --------------------------------------------------------------
    @IBOutlet weak var groupName: UILabel!

    // --------------------------------------------------------------
    // MARK: LOCAL FUNCTION DEFINITIONS
    // --------------------------------------------------------------
    
//    private func PrintTrace(_ trace: String) {
//        print("[Scan][ScanTableCell]\(trace)")
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        groupName.text = nil
    }

    // MARK: Cell Configuration

    func configurateTheCell(_ recipe: Recipe) {
        groupName.text = recipe.groupName
    }
    
    
}

