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
    var myIndex = 0
    
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    
    
    @IBAction func finalizeButton(_ sender: Any) {
        performSegue(withIdentifier: "finalizeRecipeSegue", sender: self)
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        getId()
        queryIngredients()
        querySteps()
        navTitle.title = recipeTitle! as String

        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)

        if indexPath.section == 0{
            cell.textLabel?.text = lists[0][indexPath.row]
        }
        else{
            cell.textLabel?.text = lists[1][indexPath.row]
        }
        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex =  indexPath.row
        if indexPath.row == 0 && indexPath.section == 0 {
            performSegue(withIdentifier: "newIngredientSegue", sender: self)
        }
        else if indexPath.row == 0 && indexPath.section == 1 {
            performSegue(withIdentifier: "addStepSegue", sender: self)
        }
    }
        

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ListTableViewController
        {
            let vc = segue.destination as? ListTableViewController
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
        }
        
        if segue.destination is AddStepsViewController
        {
            let vc = segue.destination as? AddStepsViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle!
            vc?.recipeId = recipeId
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

}


