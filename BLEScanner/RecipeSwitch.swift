//
//  Recipe.swift
//  TableView
//
//  Created by BILAL ARSLAN on 25.12.2018.
//  Copyright © 2018 Bilal ARSLAN. All rights reserved.
//

import Foundation
import SmartCodable


class DataModelSwitch: NSObject,SmartCodable,NSCoding {
   
    required override init() {}
    required init?(coder aDecoder: NSCoder) {
        MyVariables.switch1 = (aDecoder.decodeObject(forKey: "switch1") as? String) ?? "None"
        MyVariables.switch2 = (aDecoder.decodeObject(forKey: "switch2") as? String) ?? "None"
        MyVariables.switch3 = (aDecoder.decodeObject(forKey: "switch3") as? String) ?? "None"
        MyVariables.switch4 = (aDecoder.decodeObject(forKey: "switch4") as? String) ?? "None"
    }
    func encode(with coder: NSCoder) {
        coder.encode(MyVariables.switch1, forKey: "switch1")
        coder.encode(MyVariables.switch2, forKey: "switch2")
        coder.encode(MyVariables.switch3, forKey: "switch3")
        coder.encode(MyVariables.switch4, forKey: "switch4")
    }
}


struct RecipeSwitch {
    let switchName: String

}
extension RecipeSwitch {
    static func createRecipes(switch1: String, switch2: String, switch3: String, switch4: String) -> [RecipeSwitch] {
        return [RecipeSwitch(switchName: switch1),
                RecipeSwitch(switchName: switch2),
                RecipeSwitch(switchName: switch3),
                RecipeSwitch(switchName: switch4)]
    }
}

struct RecipeSwitchScan {
    let switchNames: String

}
extension RecipeSwitchScan {
    static func createRecipes() -> [RecipeSwitchScan] {
        var switchScan = [RecipeSwitchScan]()
        if !MyVariables.switchs.isEmpty{
            for i in 0...MyVariables.switchs.count-1{
                switchScan.append(RecipeSwitchScan(switchNames: MyVariables.switchs[i]))
            }
        }
        return switchScan
    }
}



struct Recipe_Switch1 {
    var Switch1: String

}
extension Recipe_Switch1 {
    
    static func createRecipes() -> [Recipe_Switch1] {
        var recipes: [Recipe_Switch1] = []
        
        for switchDevice in MyVariables.switchDeviceArray1 {
            var recipe = Recipe_Switch1(Switch1: switchDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.Switch1 == MyVariables.customNames[i][0]{
                    recipe.Switch1 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}



struct Recipe_Switch2 {
    var Switch2: String

}
extension Recipe_Switch2 {
    
    static func createRecipes() -> [Recipe_Switch2] {
        var recipes: [Recipe_Switch2] = []
        
        for switchDevice in MyVariables.switchDeviceArray2 {
            var recipe = Recipe_Switch2(Switch2: switchDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.Switch2 == MyVariables.customNames[i][0]{
                    recipe.Switch2 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}



struct Recipe_Switch3 {
    var Switch3: String

}
extension Recipe_Switch3 {
    
    static func createRecipes() -> [Recipe_Switch3] {
        var recipes: [Recipe_Switch3] = []
        
        for switchDevice in MyVariables.switchDeviceArray3 {
            var recipe = Recipe_Switch3(Switch3: switchDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.Switch3 == MyVariables.customNames[i][0]{
                    recipe.Switch3 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}



struct Recipe_Switch4 {
    var Switch4: String

}
extension Recipe_Switch4 {
    
    static func createRecipes() -> [Recipe_Switch4] {
        var recipes: [Recipe_Switch4] = []
        
        for switchDevice in MyVariables.switchDeviceArray4 {
            var recipe = Recipe_Switch4(Switch4: switchDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.Switch4 == MyVariables.customNames[i][0]{
                    recipe.Switch4 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}

