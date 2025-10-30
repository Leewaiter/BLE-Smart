//
//  Recipe.swift
//  TableView
//
//  Created by BILAL ARSLAN on 25.12.2018.
//  Copyright © 2018 Bilal ARSLAN. All rights reserved.
//

import Foundation
import SmartCodable


class DataModelSensor: NSObject,SmartCodable,NSCoding {
   
    required override init() {}
    required init?(coder aDecoder: NSCoder) {
        MyVariables.sensor1 = (aDecoder.decodeObject(forKey: "sensor1") as? String) ?? "None"
        MyVariables.sensor2 = (aDecoder.decodeObject(forKey: "sensor2") as? String) ?? "None"
        MyVariables.sensor3 = (aDecoder.decodeObject(forKey: "sensor3") as? String) ?? "None"
        MyVariables.sensor4 = (aDecoder.decodeObject(forKey: "sensor4") as? String) ?? "None"
    }
    func encode(with coder: NSCoder) {
        coder.encode(MyVariables.sensor1, forKey: "sensor1")
        coder.encode(MyVariables.sensor2, forKey: "sensor2")
        coder.encode(MyVariables.sensor3, forKey: "sensor3")
        coder.encode(MyVariables.sensor4, forKey: "sensor4")
    }
}


struct RecipeSensor {
    let sensorName: String

}
extension RecipeSensor {
    static func createRecipes(sensor1: String, sensor2: String, sensor3: String, sensor4: String) -> [RecipeSensor] {
        return [RecipeSensor(sensorName: sensor1),
                RecipeSensor(sensorName: sensor2),
                RecipeSensor(sensorName: sensor3),
                RecipeSensor(sensorName: sensor4)]
    }
}

struct RecipeSensorScan {
    let sensorNames: String

}
extension RecipeSensorScan {
    static func createRecipes() -> [RecipeSensorScan] {
        var sensorScan = [RecipeSensorScan]()
        if !MyVariables.sensors.isEmpty{
            for i in 0...MyVariables.sensors.count-1{
                sensorScan.append(RecipeSensorScan(sensorNames: MyVariables.sensors[i]))
            }
        }
        return sensorScan
    }
}



struct Recipe_Sensor1 {
    var Sensor1: String

}
extension Recipe_Sensor1 {
    
    static func createRecipes() -> [Recipe_Sensor1] {
        var recipes: [Recipe_Sensor1] = []
        
        for sensorDevice in MyVariables.sensorDeviceArray1 {
            var recipe = Recipe_Sensor1(Sensor1: sensorDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.Sensor1 == MyVariables.customNames[i][0]{
                    recipe.Sensor1 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}



struct Recipe_Sensor2 {
    var Sensor2: String

}
extension Recipe_Sensor2 {
    
    static func createRecipes() -> [Recipe_Sensor2] {
        var recipes: [Recipe_Sensor2] = []
        
        for sensorDevice in MyVariables.sensorDeviceArray2 {
            var recipe = Recipe_Sensor2(Sensor2: sensorDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.Sensor2 == MyVariables.customNames[i][0]{
                    recipe.Sensor2 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}



struct Recipe_Sensor3 {
    var Sensor3: String

}
extension Recipe_Sensor3 {
    
    static func createRecipes() -> [Recipe_Sensor3] {
        var recipes: [Recipe_Sensor3] = []
        
        for sensorDevice in MyVariables.sensorDeviceArray3 {
            var recipe = Recipe_Sensor3(Sensor3: sensorDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.Sensor3 == MyVariables.customNames[i][0]{
                    recipe.Sensor3 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}



struct Recipe_Sensor4 {
    var Sensor4: String

}
extension Recipe_Sensor4 {
    
    static func createRecipes() -> [Recipe_Sensor4] {
        var recipes: [Recipe_Sensor4] = []
        
        for sensorDevice in MyVariables.sensorDeviceArray4 {
            var recipe = Recipe_Sensor4(Sensor4: sensorDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.Sensor4 == MyVariables.customNames[i][0]{
                    recipe.Sensor4 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}

