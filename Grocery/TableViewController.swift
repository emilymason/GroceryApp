//
//  TableViewController.swift
//  Grocery
//
//  Created by Emily Mason on 1/17/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

var cellLabels = ["Food", "Recipes", "Recipe Match", "Shopping List"]
var myIndex = 0
var lastDate: Date?
var result: NSString?
var expirFood: [String] = []
var label: String?



class TableViewController: UITableViewController {
    var db: OpaquePointer?
 
    
    override func viewDidLoad() {
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GroceryDatabase.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("Error opening database")
            return
        }
        //Please take this out before you turn it in Emily
        print("SQLITE URL!!" + fileURL.path)
        
        let createFoodTableQuery = "CREATE TABLE IF NOT EXISTS Food (Id INTEGER PRIMARY KEY AUTOINCREMENT, food TEXT, date TEXT)"
        
        let createRecipeTableQuery = "CREATE TABLE IF NOT EXISTS Recipes (recipeId INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, percentage DOUBLE)"
        
        let createIngredientTableQuery = "CREATE TABLE IF NOT EXISTS Ingredients (Id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, wholeMeasure TEXT, fractionMeasure TEXT, measureUnits TEXT, recipeId INTEGER, FOREIGN KEY(recipeId) REFERENCES Recipes(recipeId))"
        
        let createStepTableQuery = "CREATE TABLE IF NOT EXISTS Steps (Id INTEGER PRIMARY KEY AUTOINCREMENT, step TEXT, recipeId INTEGER, FOREIGN KEY(recipeId) REFERENCES Recipes(recipeId))"
        
        if sqlite3_exec(db, createFoodTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating food table")
            return
        }
        
        if sqlite3_exec(db, createRecipeTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating recipe table")
            return
        }
        if sqlite3_exec(db, createIngredientTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating ingredient table")
            return
        }
        
        if sqlite3_exec(db, createStepTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating Steps table")
            return
        }
        
        print("Everything is fine")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ListTableViewController
        {

            let vc = segue.destination as? ListTableViewController
            vc?.db = db
            vc?.label = label
           
        }
        if segue.destination is RecipeMatchTableViewController{
            let vc = segue.destination as? RecipeMatchTableViewController
            vc?.db = db
            vc?.label = label
        }
    }
    


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  cellLabels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = cellLabels[indexPath.row]
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex =  indexPath.row
        label = cellLabels[myIndex]
        if label == "Recipe Match"{
            performSegue(withIdentifier: "recipeMatchSegue", sender: self)
        }
        else{
            performSegue(withIdentifier: "segue", sender: self)
        }
        
    }

    
    override func viewDidAppear(_ animated: Bool) {

        let currDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        var dateComponents = DateComponents()
        dateComponents.setValue(1, for: .day); // +1 day
        
        let nextDate = Calendar.current.date(byAdding: dateComponents, to: currDate)
        let thirdDate = Calendar.current.date(byAdding: dateComponents, to: nextDate!)
        
        let today = formatter.string(from: currDate) as NSString
        let tomorrow = formatter.string(from: nextDate!) as NSString
        let nextDay = formatter.string(from: thirdDate!) as NSString

        
        if result != today{
            expirFood = []
            print("TOOOOOODDDDDAAAAAYYYYY")
            print(today)
            let queryFoodStatementString = "SELECT food FROM Food WHERE date = '\(today)' OR date = '\(tomorrow)' OR date = '\(nextDay)';"
            var queryFoodStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, queryFoodStatementString, -1, &queryFoodStatement, nil) != SQLITE_OK{
                print("Error binding get food query")
            }
            
            while (sqlite3_step(queryFoodStatement) == SQLITE_ROW){
                
                let queryResultCol0 = sqlite3_column_text(queryFoodStatement, 0)
                let food = String(cString: queryResultCol0!)
                expirFood.append(food)
            }
            
            var string = expirFood.joined(separator: ", ")
            if string == ""{
                string = "None"
            }
            
            let alert = UIAlertController(title: "Food Expiring Within 3 Days:", message: "\(string)", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
            lastDate = Date()
            
            result = formatter.string(from: lastDate!) as NSString
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
}
