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
    let queryStatementString = "SELECT * FROM Grocery ORDER BY food ASC;"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GroceryDatabase.sqlite")
        
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("Error opening database")
            return
        }
        //Please take this out before you turn it in Emily
        print("SQLITE URL!!" + fileURL.path)
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Grocery (Id INTEGER PRIMARY KEY AUTOINCREMENT, food TEXT, date TEXT)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        
        print("Everything is fine")
        query()
        tableView.reloadData()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AddViewController
        {
            let vc = segue.destination as? AddViewController
            vc?.db = db
        }
        if segue.destination is EditViewController
        {
            let vc = segue.destination as? EditViewController
            vc?.db = db
            vc?.editFood = editFood
            vc?.editDate = editDate
            
            let queryIdStatementString = "SELECT Id FROM Grocery WHERE food = '\(editFood)' AND date = '\(editDate)';"
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
        // #warning Incomplete implementation, return the number of rows
        return foodList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        cell.textLabel?.text = foodList[indexPath.row]
        cell.detailTextLabel?.text = dateList[indexPath.row]
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
        label.text = dateList[indexPath.row]
        cell.accessoryView = label
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            let deleteStatementString = "DELETE FROM Grocery WHERE food = '\(foodList[indexPath.row])' AND date = '\(dateList[indexPath.row])';"
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
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
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
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex =  indexPath.row
        editFood = foodList[indexPath.row] as NSString
        editDate = dateList[indexPath.row] as NSString
        performSegue(withIdentifier: "editSegue", sender: self)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */


}
