//
//  Recipe.swift
//  TableView
//
//  Created by BILAL ARSLAN on 25.12.2018.
//  Copyright © 2018 Bilal ARSLAN. All rights reserved.
//

import Foundation
import SmartCodable


class DataModelCustomName: NSObject,SmartCodable,NSCoding {
   
    required override init() {}
    required init?(coder aDecoder: NSCoder) {
        MyVariables.customNames = (aDecoder.decodeObject(forKey: "customNames") as? [[String]]) ?? [["None"]]
    }
    func encode(with coder: NSCoder) {
        coder.encode(MyVariables.customNames, forKey: "customNames")
    }
}
