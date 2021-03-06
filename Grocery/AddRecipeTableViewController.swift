//
//  AddRecipeTableViewController.swift
//  Grocery
//
//  Created by Emily Mason on 2/22/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class AddRecipeTableViewController: UITableViewController {
    
    var db: OpaquePointer?
    var label: String?
    var recipeTitle: NSString?
    var recipeId: Int32?
    var lists = [["Click to add Ingredients: "],["Click to add Steps: "]]
    var measurements:[(measure: String, unit: String)] = []
    var sendMeasure: (measure: String, unit: String)?
    var myIndex = 0
    var ingredientList: [String] = []
    var foodList: [String] = []
    var match: Double = 0.0
    var step: String = ""
    var editIngredient: String = ""
    
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    
//Updates recipe percentages and performs segue
    @IBAction func finalizeButton(_ sender: Any) {
        //Calculate Percentages for Recipe
        populateIngredientList()
        populateFoodList()
        for ingredient in ingredientList {
            if foodList.contains(ingredient){
                match += 1
            }
        }
        
        let percentage = match/Double(ingredientList.count)
        
        let updateStatementString = "UPDATE Recipes SET percentage = \(percentage) WHERE recipeId = \(recipeId!);"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) != SQLITE_OK{
            print("Error preparing update statement")
        }
        if sqlite3_step(updateStatement) == SQLITE_DONE{
            print("Recipe edited successfully")
        }
        performSegue(withIdentifier: "finalizeRecipeSegue", sender: self)
    }
    
   
//Populate lists and set self sizing view cells
    override func viewDidLoad() {
        super.viewDidLoad()
        getId()
        queryIngredients()
        querySteps()
        navTitle.title = recipeTitle! as String
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return lists.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return lists[0].count
        } else {
            return lists[1].count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! SelfSizingStepsTableViewCell
        //Set cell selection color
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(red: 175/255, green: 206/255, blue: 255/255, alpha: 0.4)
        cell.selectedBackgroundView = cellBGView

        //If in ingredients section
        if indexPath.section == 0{
            cell.editStepLabel.text = lists[0][indexPath.row]
            if indexPath.row >= 1{
                let row = indexPath.row - 1
                var measure = measurements[row].measure
                var units = measurements[row].unit
                
                // Parse measurements if either fraction measure or whole measure is "None"
                if measure.contains("None"){
                    let none: Set<Character> = ["n", "o", "e", "N", " "]
                    measure.removeAll(where: { none.contains($0) })
                }
                
                if units == "None"{
                    units = ""
                }
                let boldText = measure + " " + units
                let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
                let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
                
                
                let normalText = "  " + cell.editStepLabel.text!
                let normalString = NSMutableAttributedString(string:normalText)
                
                attributedString.append(normalString)
                cell.editStepLabel.attributedText = attributedString
                
                // Fix alignment if measure and units are empty.
                if measure == " " && units == "" || measure == "" && units == ""{
                    cell.editStepLabel.text! = lists[0][indexPath.row]
                }
            }
        }
        // Else in steps section
        else{
            cell.editStepLabel.text = lists[1][indexPath.row]
        }
        return cell
    }
    
    //Can select rows that are not section headers
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex =  indexPath.row
        if indexPath.row == 0 && indexPath.section == 0 {
            performSegue(withIdentifier: "newIngredientSegue", sender: self)
        }
        else if indexPath.row == 0 && indexPath.section == 1 {
            performSegue(withIdentifier: "addStepSegue", sender: self)
        }
        else if indexPath.section == 1{
            step = lists[1][indexPath.row]
            performSegue(withIdentifier: "editStepSegue", sender: self)
        }
        else if indexPath.section == 0{
            editIngredient = lists[0][indexPath.row]
            sendMeasure = measurements[indexPath.row-1]
            performSegue(withIdentifier: "editIngredSegue", sender: self)
        }
    }
        

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is RecipeTestTableViewController
        {
            let vc = segue.destination as? RecipeTestTableViewController
            vc?.db = db
            vc?.label = label
        }
        
        if segue.destination is AddIngredientsViewController
        {
            let vc = segue.destination as? AddIngredientsViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle! as String
            vc?.recipeId = recipeId
            vc?.cameFrom = "Add"
        }
        
        if segue.destination is AddStepsViewController
        {
            let vc = segue.destination as? AddStepsViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle!
            vc?.recipeId = recipeId
            vc?.cameFrom = "Add"
        }
        
        if segue.destination is EditStepViewController
        {
            let vc = segue.destination as? EditStepViewController
            vc?.db = db
            vc?.label = label
            vc?.step = step
            vc?.recipeTitle = recipeTitle
            vc?.recipeId = recipeId
            vc?.cameFrom = "Add"
        }
        if segue.destination is EditIngredientViewController
        {
            let vc = segue.destination as? EditIngredientViewController
            vc?.db = db
            vc?.label = label
            vc?.ingredient = editIngredient
            vc?.recipeTitle = recipeTitle
            vc?.recipeId = recipeId
            vc?.cameFrom = "Add"
            vc?.sendMeasure = sendMeasure
        }
    }
    
//Populate ingredient list
    func queryIngredients() {
        var queryStatement: OpaquePointer? = nil
        let queryIngredientStatementString = "SELECT * FROM Ingredients WHERE recipeId = '\(recipeId!)';"
        
            if sqlite3_prepare_v2(db, queryIngredientStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    _ = sqlite3_column_int(queryStatement, 0)
                    let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                    let name = String(cString: queryResultCol1!)
                    let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                    let wholeMeasure = String(cString: queryResultCol2!)
                    let queryResult3 = sqlite3_column_text(queryStatement, 3)
                    let fractionMeasure = String(cString: queryResult3!)
                    let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
                    let measureUnits = String(cString: queryResultCol4!)
                    
                    lists[0].append(name)
                    print(lists[0])
                    print("Query Result:")
                    print("\(name) | \(wholeMeasure) | \(fractionMeasure)")
                    let totalMeasure = wholeMeasure + " " + fractionMeasure
                    measurements.append((measure: totalMeasure, unit: measureUnits ))
                }
                
            } else {
                print("SELECT ingredients statement for recipes could not be prepared")
            }
            sqlite3_finalize(queryStatement)
    
    
}
    
//Populate steps list
    func querySteps() {
        var queryStatement: OpaquePointer? = nil
        let queryStepStatementString = "SELECT * FROM Steps WHERE recipeId = '\(recipeId!)';"
        
        if sqlite3_prepare_v2(db, queryStepStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                _ = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let step = String(cString: queryResultCol1!)
                lists[1].append(step)
                print("Query Result:")
                print("\(step)")
            }
            
        } else {
            print("SELECT ingredients statement for recipes could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
    }
    
//Populate Id List
    func getId() {
        let queryIdStatementString = "SELECT recipeId FROM Recipes WHERE name = '\(recipeTitle!)';"
        var queryIdStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryIdStatementString, -1, &queryIdStatement, nil) != SQLITE_OK{
            print("Error binding get Id query")
        }

        while (sqlite3_step(queryIdStatement) == SQLITE_ROW){
        recipeId = sqlite3_column_int(queryIdStatement, 0)
        }
    }
    
//Populate ingredient List
    func populateIngredientList() {
        let queryIngredientString = "SELECT name FROM Ingredients WHERE recipeId = \(recipeId!);"
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

    }

//Populate food list
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
    
// Make sure we're not able to select the section headers.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       
            if indexPath.section == 0 && lists[0][indexPath.row] == "Click to add Ingredients: "{
                return false
            }
            else if indexPath.section == 1 && lists[1][indexPath.row] == "Click to add Steps: "{
                return false
        }
            else{
        return true
        }
    }
    
//This function allows swipe to delete and performs the necessary database deletions
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let id: Int32 = recipeId!
            if indexPath.section == 0{
                let deleteStatmentString = "DELETE FROM Ingredients WHERE name = '\(lists[0][indexPath.row])' AND recipeId = '\(id)';"
                
                
                var deleteStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(db, deleteStatmentString, -1, &deleteStatement, nil) == SQLITE_OK {
                    if sqlite3_step(deleteStatement) == SQLITE_DONE {
                        print("Successfully deleted ingredient \(lists[0][indexPath.row]) \(id)) row.")
                    } else {
                        print("Could not delete row.")
                    }
                } else {
                    print("DELETE statement could not be prepared")
                }
                sqlite3_finalize(deleteStatement)
                lists[0].remove(at: indexPath.row)
                tableView.reloadData()
            }
            else if indexPath.section == 1{
                let deleteStatmentString = "DELETE FROM Steps WHERE step = '\(lists[1][indexPath.row])' AND recipeId = '\(id)';"
                
                
                var deleteStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(db, deleteStatmentString, -1, &deleteStatement, nil) == SQLITE_OK {
                    if sqlite3_step(deleteStatement) == SQLITE_DONE {
                        print("Successfully deleted step row.")
                    } else {
                        print("Could not delete row.")
                    }
                } else {
                    print("DELETE statement could not be prepared")
                }
                sqlite3_finalize(deleteStatement)
                lists[1].remove(at: indexPath.row)
                tableView.reloadData()
            }
            
        }

}
}

