//
//  ScanTableCell.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/3/30.
//

import Foundation
import UIKit

class DetailTableCell: UITableViewCell {
    // --------------------------------------------------------------
    // MARK: LOCAL VARIABLES OF IBOUTLET
    // --------------------------------------------------------------
    @IBOutlet weak var detailName: UILabel!

    // --------------------------------------------------------------
    // MARK: LOCAL FUNCTION DEFINITIONS
    // --------------------------------------------------------------
    

    
    override func prepareForReuse() {
        super.prepareForReuse()
        detailName.text = nil
    }

    // MARK: Cell Configuration
    func configurateTheCellAll(_ recipe: Recipe_All) {
        detailName.text = recipe.groupAll
    }
    
    func configurateTheCell1(_ recipe: Recipe_Group1) {
        detailName.text = recipe.group1
    }
    
    func configurateTheCell2(_ recipe: Recipe_Group2) {
        detailName.text = recipe.group2
    }
    
    func configurateTheCell3(_ recipe: Recipe_Group3) {
        detailName.text = recipe.group3
    }
    
    func configurateTheCell4(_ recipe: Recipe_Group4) {
        detailName.text = recipe.group4
    }
    
    func configurateTheCell5(_ recipe: Recipe_Switch1) {
        detailName.text = recipe.Switch1
    }
    
    func configurateTheCell6(_ recipe: Recipe_Switch2) {
        detailName.text = recipe.Switch2
    }
    
    func configurateTheCell7(_ recipe: Recipe_Switch3) {
        detailName.text = recipe.Switch3
    }
    
    func configurateTheCell8(_ recipe: Recipe_Switch4) {
        detailName.text = recipe.Switch4
    }
    
    
}

