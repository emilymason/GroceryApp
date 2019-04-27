//
//  EditRecipeTableViewController.swift
//  Recipe Crunch
//
//  Created by Emily Mason on 4/3/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class EditRecipeTableViewController: UITableViewController {
    
    var db: OpaquePointer?
    var label: String?
    var recipeTitle: String?
    var recipeId: Int32?
    var list = [["Click to add Ingredients: "],["Click to add Steps: "]]
    var measurements:[(measure: String, unit: String)] = []
    var sendMeasure: (measure: String, unit: String)?
    var myIndex = 0
    var ingredientList: [String] = []
    var foodList: [String] = []
    var match: Double = 0.0
    var step: String = ""
    var editIngredient: String = ""
    
    @IBOutlet weak var editTitle: UINavigationItem!
    @IBAction func saveButton(_ sender: Any) {
        performSegue(withIdentifier: "saveRecipeSegue", sender: self)
    }
    
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "saveRecipeSegue", sender: self)
    }
    
    override func viewDidLoad() {
        editTitle.title = "Edit " + recipeTitle!
        
        super.viewDidLoad()
        querySteps()
        queryIngredients()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return list[0].count
        } else {
            return list[1].count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "displayCell", for: indexPath) as! SelfSizingStepsTableViewCell
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(red: 175/255, green: 206/255, blue: 255/255, alpha: 0.4)
        cell.selectedBackgroundView = cellBGView
        
        if indexPath.section == 0{
            cell.editStepAgainLabel.text = list[0][indexPath.row]
            if indexPath.row >= 1{
                let row = indexPath.row - 1
                var measure = measurements[row].measure
                var units = measurements[row].unit
                
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
                
                
                let normalText = "  " + cell.editStepAgainLabel.text!
                let normalString = NSMutableAttributedString(string:normalText)
                
                attributedString.append(normalString)
                
                cell.editStepAgainLabel.attributedText = attributedString
                print("EDIT MEASUREMENTS!!!")
                print("/" + measure + "/")
                print("/" + units + "/")
                if measure == "" && units == "" || measure == " " && units == ""{
                    cell.editStepAgainLabel.text! = list[0][indexPath.row]
                }
            }
        }
        else{
            cell.editStepAgainLabel.text = list[1][indexPath.row]
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex =  indexPath.row
        if indexPath.row == 0 && indexPath.section == 0 {
            performSegue(withIdentifier: "EditAddIngredient", sender: self)
        }
        else if indexPath.row == 0 && indexPath.section == 1 {
            performSegue(withIdentifier: "EditAddStep", sender: self)
        }
        else if indexPath.section == 1{
            step = list[1][indexPath.row]
            performSegue(withIdentifier: "editStepSegue", sender: self)
        }
        else if indexPath.section == 0{
            editIngredient = list[0][indexPath.row]
            sendMeasure = measurements[indexPath.row-1]
            performSegue(withIdentifier: "editIngredientSegue", sender: self)
        }
    }
    
    
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
                
                list[0].append(name)
                let totalMeasure = wholeMeasure + " " + fractionMeasure
                measurements.append((measure: totalMeasure, unit: measureUnits ))
            }
            
        } else {
            print("SELECT ingredients statement for recipes could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }
    
    func querySteps() {
        var queryStatement: OpaquePointer? = nil
        let queryStepStatementString = "SELECT * FROM Steps WHERE recipeId = '\(recipeId!)';"
        
        if sqlite3_prepare_v2(db, queryStepStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                _ = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let step = String(cString: queryResultCol1!)
                
                list[1].append(step)
            }
            
        } else {
            print("SELECT ingredients statement for recipes could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DisplayRecipeTableViewController
        {
            let vc = segue.destination as? DisplayRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeId = recipeId
            vc?.recipeTitle = recipeTitle
        }
        if segue.destination is EditStepViewController
        {
            let vc = segue.destination as? EditStepViewController
            vc?.db = db
            vc?.label = label
            vc?.step = step
            vc?.recipeTitle = recipeTitle as NSString?
            vc?.recipeId = recipeId
            vc?.cameFrom = "Edit"
        }
        if segue.destination is EditIngredientViewController
        {
            let vc = segue.destination as? EditIngredientViewController
            vc?.db = db
            vc?.label = label
            vc?.ingredient = editIngredient
            vc?.recipeTitle = recipeTitle as NSString?
            vc?.recipeId = recipeId
            vc?.cameFrom = "Edit"
            vc?.sendMeasure = sendMeasure
        }
        if segue.destination is AddStepsViewController
        {
            let vc = segue.destination as? AddStepsViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle as NSString?
            vc?.recipeId = recipeId
            vc?.cameFrom = "Edit"
        }
        if segue.destination is AddIngredientsViewController
        {
            let vc = segue.destination as? AddIngredientsViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle
            vc?.recipeId = recipeId
            vc?.cameFrom = "Edit"
        }
        
    }
    
    // Can't delete header cells
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 && list[0][indexPath.row] == "Click to add Ingredients: "{
            return false
        }
        else if indexPath.section == 1 && list[1][indexPath.row] == "Click to add Steps: "{
            return false
        }
        else{
            
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let id: Int32 = recipeId!
            if indexPath.section == 0{
                let deleteStatmentString = "DELETE FROM Ingredients WHERE name = '\(list[0][indexPath.row])' AND recipeId = '\(id)';"
                
                
                var deleteStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(db, deleteStatmentString, -1, &deleteStatement, nil) == SQLITE_OK {
                    if sqlite3_step(deleteStatement) == SQLITE_DONE {
                        print("Successfully deleted ingredient \(list[0][indexPath.row]) \(id)) row.")
                    } else {
                        print("Could not delete row.")
                    }
                } else {
                    print("DELETE statement could not be prepared")
                }
                sqlite3_finalize(deleteStatement)
                list[0].remove(at: indexPath.row)
                tableView.reloadData()
            }
            else if indexPath.section == 1{
                let deleteStatmentString = "DELETE FROM Steps WHERE step = '\(list[1][indexPath.row])' AND recipeId = '\(id)';"
                
                
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
                list[1].remove(at: indexPath.row)
                tableView.reloadData()
            }
            
        }
        
    }

}
