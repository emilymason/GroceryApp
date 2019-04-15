//
//  RecipeTestTableViewController.swift
//  Recipe Crunch
//
//  Created by Emily Mason on 4/11/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class recipeViewCell: UITableViewCell{
    
    @IBOutlet weak var circleView: CircularProgressView!

    @IBOutlet weak var recipeLabel: UILabel!
}

class RecipeTestTableViewController: UITableViewController {
    var recipeList: [String] = []
    var recipeTitle: String?
    var nearExpired: [String]?
    var foodList: [String] = []
    var idList: [Int32] = []
    var label: String?
    var recipePercentage: [Double] = []
    var db: OpaquePointer?
    var queryRecipeStatementString: String?
    let laymanFood: [String] = ["Water", "Salt", "Ice Cubes", "Pepper"]
//    let queryRecipePercentageStatementString = "SELECT * FROM Recipes ORDER BY percentage ASC;"
    @IBOutlet weak var addButtonLabel: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBAction func backButton(_ sender: Any) {
    }
    @IBAction func editButton(_ sender: Any) {
        if label == "Recipes"{
            
            performSegue(withIdentifier: "addRecipeSegue", sender: self)
        }
        else if label == "Recipe Crunch"{
            addButtonLabel.title = ""
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        populateFoodList()
        print("FOOD")
        print(foodList)
        navBar.barTintColor = .white
        if (label == "Recipes"){
            navTitle.title = "My Recipes"
        }
        
        if (label == "Recipe Match"){
            navTitle.title = "Recipe Crunch"
            addButtonLabel.isEnabled = false
            addButtonLabel.tintColor = .clear
        }
        
        navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 20)!]
        query()
        recipePercentage = []
        print("EXPIRED")
        print(nearExpired?.count == 0)
        
        
        for recipe in idList{
            var match: Double = 0
            let ingredients: [String] = populateIngredientList(recipeId: recipe)
            for ingredient in ingredients{
                if foodList.contains(ingredient) || laymanFood.contains(ingredient){
                    match += 1
                }
            }
            
            let percentage = match/Double(ingredients.count)
            recipePercentage.append(percentage)
            
            let updateStatementString = "UPDATE Recipes SET percentage = \(percentage) WHERE recipeId = \(recipe);"
            var updateStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) != SQLITE_OK{
                print("Error preparing update statement")
            }
            if sqlite3_step(updateStatement) == SQLITE_DONE{
                print("Recipe percentage edited successfully")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backgroundImage = UIImage(named: "recipe.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        imageView.contentMode = .center
        imageView.alpha = 0.2
    }



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recipeList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! recipeViewCell
        let used = UsesIngredient(recipeId: idList[indexPath.row])
        cell.backgroundColor = .clear
        cell.recipeLabel?.text = recipeList[indexPath.row]
        if used == true{
            cell.recipeLabel.textColor = .green
        }
        cell.circleView.trackColor = UIColor(displayP3Red: 237/255, green: 1, blue: 237/255, alpha: 1.0)
        cell.circleView.progressColor = UIColor(displayP3Red: 168/255, green: 255, blue: 168/255, alpha: 1)
        cell.circleView.setProgressWithAnimation(duration: 1.0, value: Float(recipePercentage[indexPath.row]))
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(red: 175/255, green: 206/255, blue: 255/255, alpha: 0.4)
        cell.selectedBackgroundView = cellBGView
        return cell
    }
    
    
    //Gets all the recipes in the Recipe table and puts them in recipeList
    func query() {
        var queryStatement: OpaquePointer? = nil
        if label == "Recipes"{
            queryRecipeStatementString = "SELECT * FROM Recipes ORDER BY name ASC;"
        }
        else if label == "Recipe Match"{
            queryRecipeStatementString = "SELECT * FROM Recipes ORDER BY percentage DESC;"
        }
            if sqlite3_prepare_v2(db, queryRecipeStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    let id = sqlite3_column_int(queryStatement, 0)
                    let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                    let name = String(cString: queryResultCol1!)
                    let percentage = sqlite3_column_double(queryStatement, 2)
                    recipeList.append(name)
                    recipePercentage.append(percentage)
                    idList.append(id)
                    print("Query Result:")
                    print("\(id) | \(name)")
                }
                
            } else {
                print("SELECT statement for recipes could not be prepared")
            }
            sqlite3_finalize(queryStatement)
    
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if recipeList[indexPath.row] == "Honey Mustard Grilled Chicken" || recipeList[indexPath.row] == "Banana Bread" || recipeList[indexPath.row] == "Peanut Butter Banana Smoothie"{
            return false
        }
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipeTitle = recipeList[indexPath.row]
        performSegue(withIdentifier: "displayRecipeSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
                var id: Int32 = 0
                id = GetId(recipeName: recipeList[indexPath.row])
                print(id)
                let deleteStatmentString = "DELETE FROM Recipes WHERE recipeId = '\(id)';"
                let deleteIngredientStatementString = "DELETE FROM Ingredients WHERE recipeId = '\(id)';"
                let deleteStepsStatementString = "DELETE FROM Steps WHERE recipeId = '\(id)';"
                
                //Delete Steps
                var deleteStepStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(db, deleteStepsStatementString, -1, &deleteStepStatement, nil) == SQLITE_OK {
                    if sqlite3_step(deleteStepStatement) == SQLITE_DONE {
                        print("Successfully deleted step row.")
                    } else {
                        print("Could not delete step row.")
                    }
                } else {
                    print("DELETE statement could not be prepared")
                }
                sqlite3_finalize(deleteStepStatement)
                
                //Delete Ingredients
                var deleteIngredientStatement: OpaquePointer? = nil
                
                if sqlite3_prepare_v2(db, deleteIngredientStatementString, -1, &deleteIngredientStatement, nil) == SQLITE_OK {
                    if sqlite3_step(deleteIngredientStatement) == SQLITE_DONE {
                        print("Successfully deleted Ingredient row.")
                    } else {
                        print("Could not delete ingredient row.")
                    }
                } else {
                    print("DELETE statement could not be prepared")
                }
                sqlite3_finalize(deleteIngredientStatement)
                
                //Delete Recipe
                var deleteStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(db, deleteStatmentString, -1, &deleteStatement, nil) == SQLITE_OK {
                    if sqlite3_step(deleteStatement) == SQLITE_DONE {
                        print("Successfully deleted row.")
                    } else {
                        print("Could not delete row.")
                    }
                } else {
                    print("DELETE statement could not be prepared")
                }
                sqlite3_finalize(deleteStatement)
                recipeList.remove(at: indexPath.row)
            recipePercentage.remove(at: indexPath.row)
                tableView.reloadData()
            
        }
        
    }




    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DisplayRecipeTableViewController{
            let vc = segue.destination as? DisplayRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle as String?
        }
        
        if segue.destination is AddRecipeViewController
        {
            let vc = segue.destination as? AddRecipeViewController
            vc?.db = db
            vc?.label = label
        }
    }
    
    func GetId(recipeName: String) -> Int32 {
        var newId: Int32 = 0
        let queryIdStatementString = "SELECT recipeId FROM Recipes WHERE name = '\(recipeName)';"
        var queryIdStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryIdStatementString, -1, &queryIdStatement, nil) != SQLITE_OK{
            print("Error binding get Id query")
        }
        
        while (sqlite3_step(queryIdStatement) == SQLITE_ROW){
            newId = sqlite3_column_int(queryIdStatement, 0)
        }
        
        return newId
    }
    
    func UsesIngredient(recipeId: Int32) -> Bool{
        var ingredientsUsed: [String] = []
        let queryStatementString = "SELECT name FROM Ingredients WHERE recipeId = '\(recipeId)';"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let someName = String(cString: queryResultCol1!)
                ingredientsUsed.append(someName)
            }
            
        } else {
            print("SELECT statement for recipes could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        if ingredientsUsed.count != 0{
        for ingredient in ingredientsUsed{
            if nearExpired?.count != nil {
                if nearExpired!.contains(ingredient){
                return true
                }
            }
        }
            
        }
        
        return false
    }
    
    func populateIngredientList(recipeId: Int32) -> [String] {
        var ingredientList: [String] = []
        let queryIngredientString = "SELECT name FROM Ingredients WHERE recipeId = \(recipeId);"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryIngredientString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let ingredient = String(cString: queryResultCol1!)
                
                ingredientList.append(ingredient)
            }
            
        } else {
            print("Error Selecting Ingredients")
        }
        sqlite3_finalize(queryStatement)
        return ingredientList
        
    }
    
    func populateFoodList() {
        let queryFoodString = "SELECT food FROM Food;"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryFoodString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let food = String(cString: queryResultCol1!)
                
                foodList.append(food)
            }
            
        } else {
            print("Error Selecting Food")
        }
        sqlite3_finalize(queryStatement)
        
    }



}
