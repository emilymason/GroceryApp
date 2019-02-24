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
    var label: String?
    let queryFoodStatementString = "SELECT * FROM Food ORDER BY food ASC;"
    let queryRecipeStatementString = "SELECT * FROM Recipes ORDER BY name ASC;"
    
    @IBAction func addButton(_ sender: Any) {
        if label == "Food"{
            performSegue(withIdentifier: "addFoodSegue", sender: self)
        }
        else if label == "Recipes"{
            performSegue(withIdentifier: "addRecipeSegue", sender: self)
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
                print("IDDDDDDDD!~!!!!!!")
                print(newId)
            }
            
        }
    }
 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if label == "Food"{
           return foodList.count
        }
        else if label == "Recipes"{
            return recipeList.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        if label == "Food"
        {
        cell.textLabel?.text = foodList[indexPath.row]
        cell.detailTextLabel?.text = dateList[indexPath.row]
        let dateLabel = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
        dateLabel.text = dateList[indexPath.row]
        cell.accessoryView = dateLabel
        }
        else if label == "Recipes"
        {
            cell.textLabel?.text = recipeList[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            let deleteStatementString = "DELETE FROM Food WHERE food = '\(foodList[indexPath.row])' AND date = '\(dateList[indexPath.row])';"
            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
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
            tableView.reloadData()


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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex =  indexPath.row
        if label == "Food"{
        editFood = foodList[indexPath.row] as NSString
        editDate = dateList[indexPath.row] as NSString
        performSegue(withIdentifier: "editSegue", sender: self)
        }
    }



}
