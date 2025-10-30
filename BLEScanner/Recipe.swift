//
//  Recipe.swift
//  TableView
//
//  Created by BILAL ARSLAN on 25.12.2018.
//  Copyright © 2018 Bilal ARSLAN. All rights reserved.
//

import Foundation




struct Recipe {
    let groupName: String

}
extension Recipe {
    static func createRecipes() -> [Recipe] {
        return [Recipe(groupName: "Group1"),
                Recipe(groupName: "Group2"),
                Recipe(groupName: "Group3"),
                Recipe(groupName: "Group4")]
    }
}


struct Recipe_All {
    var groupAll: String

}
extension Recipe_All {
    
    static func createRecipes() -> [Recipe_All] {
        var recipes: [Recipe_All] = []
        
        for groupDevice in MyVariables.groupDeviceArrayAll {
            var recipe = Recipe_All(groupAll: groupDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.groupAll == MyVariables.customNames[i][0]{
                    recipe.groupAll = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}


struct Recipe_Group1 {
    var group1: String

}
extension Recipe_Group1 {
    
    static func createRecipes() -> [Recipe_Group1] {
        var recipes: [Recipe_Group1] = []
        
        for groupDevice in MyVariables.groupDeviceArray1 {
            var recipe = Recipe_Group1(group1: groupDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.group1 == MyVariables.customNames[i][0]{
                    recipe.group1 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}


struct Recipe_Group2 {
    var group2: String

}
extension Recipe_Group2 {
    
    static func createRecipes() -> [Recipe_Group2] {
        var recipes: [Recipe_Group2] = []
        
        for groupDevice in MyVariables.groupDeviceArray2 {
            var recipe = Recipe_Group2(group2: groupDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.group2 == MyVariables.customNames[i][0]{
                    recipe.group2 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}



struct Recipe_Group3 {
    var group3: String

}
extension Recipe_Group3 {
    
    static func createRecipes() -> [Recipe_Group3] {
        var recipes: [Recipe_Group3] = []
        
        for groupDevice in MyVariables.groupDeviceArray3 {
            var recipe = Recipe_Group3(group3: groupDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.group3 == MyVariables.customNames[i][0]{
                    recipe.group3 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}



struct Recipe_Group4 {
    var group4: String

}
extension Recipe_Group4 {
    
    static func createRecipes() -> [Recipe_Group4] {
        var recipes: [Recipe_Group4] = []
        
        for groupDevice in MyVariables.groupDeviceArray4 {
            var recipe = Recipe_Group4(group4: groupDevice)
            for i in 0..<MyVariables.customNames.count {
                if recipe.group4 == MyVariables.customNames[i][0]{
                    recipe.group4 = MyVariables.customNames[i][1]
                }
            }
            
            recipes.append(recipe)
        }
        
        return recipes
    }
}

