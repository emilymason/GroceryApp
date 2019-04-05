//
//  ListTableViewController.swift
//  Grocery
//
//  Created by Emily Mason on 1/26/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class ListTableViewController: UITableViewController {
    
    var db: OpaquePointer?
    var foodList: [String] = []
    var dateList: [String] = []
    var editFood: NSString = ""
    var editDate: NSString = ""
    var editId: Int32?
    var recipeList: [String] = []
    var recipeTitle: String?
    var shoppingList: [String] = []
    var label: String?
    let queryFoodStatementString = "SELECT * FROM Food ORDER BY food ASC;"
    let queryRecipeStatementString = "SELECT * FROM Recipes ORDER BY name ASC;"
    let queryShoppingStatementString = "SELECT * FROM ShoppingList ORDER BY item ASC;"
    
    @IBAction func addButton(_ sender: Any) {
        if label == "Food"{
            performSegue(withIdentifier: "addFoodSegue", sender: self)
        }
        else if label == "Recipes"{
            performSegue(withIdentifier: "addRecipeSegue", sender: self)
        }
        else if label == "Shopping List"{
            performSegue(withIdentifier: "addShoppingSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query()
        tableView.reloadData()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AddViewController
        {
            let vc = segue.destination as? AddViewController
            vc?.db = db
            vc?.label = label
        }
        if segue.destination is TableViewController
        {
            let vc = segue.destination as? TableViewController
            vc?.db = db
            
            
        }
        if segue.destination is AddShoppingViewController
        {
            let vc = segue.destination as? AddShoppingViewController
            vc?.db = db
            vc?.label = label
            
            
        }
        if segue.destination is AddRecipeViewController
        {
            let vc = segue.destination as? AddRecipeViewController
            vc?.db = db
            vc?.label = label
        }
        if segue.destination is EditViewController
        {
            let vc = segue.destination as? EditViewController
            vc?.db = db
            vc?.editFood = editFood
            vc?.editDate = editDate
            vc?.label = label
            
            let queryIdStatementString = "SELECT Id FROM Food WHERE food = '\(editFood)' AND date = '\(editDate)';"
            var queryIdStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, queryIdStatementString, -1, &queryIdStatement, nil) != SQLITE_OK{
                print("Error binding get Id query")
            }
            if sqlite3_bind_text(queryIdStatement, 1, editFood.utf8String, -1, nil) != SQLITE_OK{
                print("Error binding get ID food")
            }
            if sqlite3_bind_text(queryIdStatement, 1, editDate.utf8String, -1, nil) != SQLITE_OK{
                print("Error binding get ID date")
            }
            
            while (sqlite3_step(queryIdStatement) == SQLITE_ROW){
               let newId = sqlite3_column_int(queryIdStatement, 0)
                vc?.editId = newId
            }
            
        }
        if segue.destination is DisplayRecipeTableViewController{
            let vc = segue.destination as? DisplayRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle as String?
        }
    }
 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if label == "Food"{
           return foodList.count
        }
        else if label == "Recipes"{
            return recipeList.count
        }
        else if label == "Shopping List"{
            return shoppingList.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        if label == "Food"
        {
            cell.textLabel?.text = foodList[indexPath.row]
            cell.detailTextLabel?.text = dateList[indexPath.row]

            if foodList[indexPath.row] == "Completely Empty Pantry"{
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .red
            }
            else {
                let dateLabel = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
                dateLabel.text = dateList[indexPath.row]
                cell.accessoryView = dateLabel
            }
        }
        else if label == "Recipes"
        {
            cell.textLabel?.text = recipeList[indexPath.row]
        }
        else if label == "Shopping List"{
            cell.textLabel?.text = shoppingList[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if label == "Recipes"{
            if recipeList[indexPath.row] == "Honey Mustard Grilled Chicken" || recipeList[indexPath.row] == "Banana Bread" || recipeList[indexPath.row] == "Peanut Butter Banana Smoothie"{
                return false
            }
        }
        if label == "Food"{
            if foodList[indexPath.row] == "Completely Empty Pantry"{
                return false
            }
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            if label == "Food"{
                let deleteStatmentString = "DELETE FROM Food WHERE food = '\(foodList[indexPath.row])' AND date = '\(dateList[indexPath.row])';"
            
          
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
            foodList.remove(at: indexPath.row)
            dateList.remove(at: indexPath.row)
                if foodList.count == 1{
                    foodList.removeAll()
                    dateList.removeAll()
                }
            tableView.reloadData()

            }
            else if label == "Recipes"{
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
                tableView.reloadData()
                
            }
            else if label == "Shopping List" {
                let deleteStatmentString = "DELETE FROM ShoppingList WHERE item = '\(shoppingList[indexPath.row])';"
                
                
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
                shoppingList.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
        
    }
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        if label == "Food"{
        if sqlite3_prepare_v2(db, queryFoodStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let food = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let date = String(cString: queryResultCol2!)
                foodList.append(food)
                dateList.append(date)
                print("Query Result:")
                print("\(id) | \(food) | \(date)")
            }
            if foodList.count > 0{
            foodList.append("Completely Empty Pantry")
            dateList.append("")
            }
            
            
        } else {
            print("SELECT statement for food could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        }
        
        else if label == "Recipes"{
            if sqlite3_prepare_v2(db, queryRecipeStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    let id = sqlite3_column_int(queryStatement, 0)
                    let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                    let name = String(cString: queryResultCol1!)
                    recipeList.append(name)
                    print("Query Result:")
                    print("\(id) | \(name)")
                }
                
            } else {
                print("SELECT statement for recipes could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }
        else {
            if sqlite3_prepare_v2(db, queryShoppingStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    let id = sqlite3_column_int(queryStatement, 0)
                    let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                    let item = String(cString: queryResultCol1!)
                    shoppingList.append(item)
                    print("Query Result:")
                    print("\(id) | \(item)")
                }
                
            } else {
                print("SELECT statement for shopping list could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex =  indexPath.row
        if label == "Food"{
            if foodList[indexPath.row] == "Completely Empty Pantry"{
                let alert = UIAlertController(title: "Warning", message: "Are you sure you want to completely empty your pantry?", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                    self.emptyPantry()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
                
                self.present(alert, animated: true, completion: nil)
            }
            else{
                editFood = foodList[indexPath.row] as NSString
                editDate = dateList[indexPath.row] as NSString
                performSegue(withIdentifier: "editSegue", sender: self)
            }
        }
        else if label == "Recipes"{
            recipeTitle = recipeList[indexPath.row]
            performSegue(withIdentifier: "displayRecipeSegue", sender: self)
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
    
    func emptyPantry() {
        let emptyString = "DELETE FROM Food;"
        var emptyStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, emptyString, -1, &emptyStatement, nil) != SQLITE_OK{
            print("Error deleting all")
        }
        
        if sqlite3_step(emptyStatement) == SQLITE_DONE {
            print("Successfully deleted food.")
        } else {
            print("Could not delete food.")
        }
        sqlite3_finalize(emptyStatement)
        foodList.removeAll()
        dateList.removeAll()
        tableView.reloadData()
    }
}
