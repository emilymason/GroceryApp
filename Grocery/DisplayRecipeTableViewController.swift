//
//  DisplayRecipeTableViewController.swift
//  Grocery
//
//  Created by Emily Mason on 2/24/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class DisplayRecipeTableViewController: UITableViewController {
    
    var db: OpaquePointer?
    var label: String?
    var recipeTitle: String?
    var recipeId: Int32?
    var list = [["Ingredients: "],["Steps: "]]
    var measurements:[(measure: String, unit: String)] = []

    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "backToListSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getId()
        queryIngredients()
        querySteps()
        navTitle.title = recipeTitle! as String
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
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
        
        
        if indexPath.section == 0{
            cell.StepLabel.text = list[0][indexPath.row]
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
                
                
                let normalText = "  " + cell.StepLabel.text!
                let normalString = NSMutableAttributedString(string:normalText)
                
                attributedString.append(normalString)

                cell.StepLabel.attributedText = attributedString
            }
        }
        else{
            cell.StepLabel.text = list[1][indexPath.row]
        }
        return cell
    }
    
    func getId(){
        let queryIdStatementString = "SELECT recipeId FROM Recipes WHERE name = '\(recipeTitle!)';"
        var queryIdStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryIdStatementString, -1, &queryIdStatement, nil) != SQLITE_OK{
            print("Error binding get Id query")
        }
        
        while (sqlite3_step(queryIdStatement) == SQLITE_ROW){
            recipeId = sqlite3_column_int(queryIdStatement, 0)
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
        if segue.destination is ListTableViewController
        {
            let vc = segue.destination as? ListTableViewController
            vc?.db = db
            vc?.label = label
        }
    }
    

  // FOR EDITING!!!!!!!!!!!!!!!!!!!
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        myIndex =  indexPath.row
//        if indexPath.row == 0 && indexPath.section == 0 {
//            performSegue(withIdentifier: "newIngredientSegue", sender: self)
//        }
//        else if indexPath.row == 0 && indexPath.section == 1 {
//            performSegue(withIdentifier: "addStepSegue", sender: self)
//        }
//    }

  

    /* NEED THIS FOR EDITING (EXCLUDE 0,0 and 1,0
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
