//
//  ServiceTable.swift
//  BLEScanner
//
//  Created by rafael_sw on 2021/4/20.
//

import Foundation
import UIKit

class ServiceTableCell: UITableViewCell {
    // --------------------------------------------------------------
    // MARK: LOCAL VARIABLES OF IBOUTLET
    // --------------------------------------------------------------
    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var serviceUUID: UILabel!
    @IBOutlet weak var serviceSubtitle: UILabel!
}
