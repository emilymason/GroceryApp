//
//  RecipeMatchTableViewController.swift
//  Grocery
//
//  Created by Emily Mason on 3/4/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class RecipeMatchTableViewController: UITableViewController {
    
    var db: OpaquePointer?
    var label: String?
    var recipeList: [String] = []
    var recipeTitle: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        query()
        tableView.reloadData()

    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeList.count
    }
    
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        let queryStatementString = "SELECT * FROM Recipes ORDER BY percentage DESC;"
        
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath)
        cell.textLabel?.text = recipeList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipeTitle = recipeList[indexPath.row]
        performSegue(withIdentifier: "recipeMatchSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DisplayRecipeTableViewController
        {
            let vc = segue.destination as? DisplayRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle
        }
    }



}
