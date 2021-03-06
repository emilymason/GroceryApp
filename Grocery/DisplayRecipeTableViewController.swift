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
    var image = ["First"]
    var measurements:[(measure: String, unit: String)] = []
    var foodList: [String] = []
    var shoppingList: [String] = []
    var imageView: UIImageView?
    let laymanFood: [String] = ["Water", "Salt", "Ice Cubes", "Pepper"]
    

    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "backToListSegue", sender: self)
        
    }
    
    @IBAction func editButton(_ sender: Any) {
        performSegue(withIdentifier: "editRecipeSegue", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.backgroundColor = .white
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
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(red: 175/255, green: 206/255, blue: 255/255, alpha: 0.4)
        cell.selectedBackgroundView = cellBGView
        
        //If we are in the ingredients section
        if (indexPath.section == 0){
            cell.StepLabel.text = list[0][indexPath.row]
            
            // Make sure that we do not calculate measurements for section header
            if indexPath.row >= 1{
                let row = indexPath.row - 1
                var measure = measurements[row].measure
                var units = measurements[row].unit
                
                //If user selected "None" in the picker view, do not show it
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
                
                // Fix alignment if measure and units are both empty.
                if measure == "" && units == "" || measure == " " && units == ""{
                    cell.StepLabel.text! = list[0][indexPath.row]
                }
                
                // Add Icons next to ingredients in a recipe. Green check if you have that item, shopping basket if it's in your shopping list, yellow check if it is a food that most people should have (salt, water, etc.), and a X if you do not have that ingredient and it is not in your shopping list.
                SelectStatements()
                if (indexPath.row > 0){
                    if foodList.contains(list[0][indexPath.row]) || foodList.contains(String(list[0][indexPath.row].dropLast())) || foodList.contains(list[0][indexPath.row] + "s") || foodList.contains(list[0][indexPath.row] + "es") || foodList.contains(list[0][indexPath.row].dropLast()+"ies") || foodList.contains(list[0][indexPath.row].dropLast(3) + "y"){
                        if cell.StepLabel.text != "Ingredients: "{
                    imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
                    imageView?.image = UIImage(named: "checkmark.png")
                    cell.accessoryView = imageView
                    image.append("Check")
                        }
                }
                else if laymanFood.contains(list[0][indexPath.row]) && cell.StepLabel.text != "Ingredients: "{
                        imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
                        imageView?.image = UIImage(named: "yellowcheck.png")
                        cell.accessoryView = imageView
                        image.append("yellow")
                    }
                else if (shoppingList.contains(list[0][indexPath.row]) && cell.StepLabel.text != "Ingredients: "){
                    imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
                    imageView?.image = UIImage(named: "shopping-basket.png")
                    cell.accessoryView = imageView
                    image.append("Shopping")

                }
                else{
                    if(cell.StepLabel.text != "Ingredients: "){
                        
                    imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
                    imageView?.image = UIImage(named: "cancel-mark.png")
                    cell.accessoryView = imageView
                    image.append("Need")
                        
                    }

                }
                }
                
            }
        }
        else{
            cell.accessoryView = nil
            cell.StepLabel.text = list[1][indexPath.row]
        }
        return cell
    }
    
//Select ingredients to be able to add them to your shopping list.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && image[indexPath.row] == "Need" ){
            let alert = UIAlertController(title: "Do you want to add \(list[0][indexPath.row]) to your shopping list?", message: "", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                self.AddToShoppingList(food: self.list[0][indexPath.row])
                self.image[indexPath.row] = "Shopping"
                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
            
            self.present(alert, animated: true, completion: nil)
        }
        else {
            return
        }
        
    }
    
//returns id of recipe given the title.
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
    
//Populates ingredients list and measurements list
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
    
//Populates steps list
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
        if segue.destination is RecipeTestTableViewController
        {
            let vc = segue.destination as? RecipeTestTableViewController
            vc?.db = db
            vc?.label = label
        }
        if segue.destination is EditRecipeTableViewController
        {
            let vc = segue.destination as? EditRecipeTableViewController
            getId()
            vc?.db = db
            vc?.label = label
            vc?.recipeId = recipeId
            vc?.recipeTitle = recipeTitle
        }

    }
    
// This function inserts food into shopping list.
    func AddToShoppingList(food: String){
        let queryStatementString = "INSERT INTO ShoppingList (item) VALUES('\(food)');"
        var queryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        if sqlite3_step(queryStatement) == SQLITE_DONE{
            print("Food saved successfully")
        }
        sqlite3_finalize(queryStatement)
        SelectStatements()
        

    }
    
//Populates food list and shopping list
    func SelectStatements(){
        foodList = []
        shoppingList = []
        let queryStatementString = "SELECT food FROM Food;"
        var queryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let food = String(cString: queryResultCol1!)
                
                foodList.append(food)
            }
            
        } else {
            print("Error Selecting Food")
        }
        sqlite3_finalize(queryStatement)
        
        
        let queryListString = "SELECT item FROM ShoppingList;"
        var queryListStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryListString, -1, &queryListStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryListStatement) == SQLITE_ROW) {
                let queryResultCol1 = sqlite3_column_text(queryListStatement, 0)
                let food = String(cString: queryResultCol1!)
                
                shoppingList.append(food)
            }
            
        } else {
            print("Error Selecting Food")
        }
        sqlite3_finalize(queryListStatement)
    }


}
