//
//  LandingViewController.swift
//  Recipe Crunch
//
//  Created by Emily Mason on 4/8/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

    var result: NSString?


class LandingViewController: UIViewController {
    var cellLabels = ["Food", "Recipes", "Recipe Match", "Shopping List"]
    var myIndex = 0
    var lastDate: Date?
    var foodList: [String] = []
    var dateList: [String] = []
    var isExpired: [Int32] = []
    var idList: [Int32] = []
    var expirFood: [String] = []
    var label: String?
    var db: OpaquePointer?
    
    @IBAction func PantryButton(_ sender: Any) {
        label = "Food"
        performSegue(withIdentifier: "firstSegue", sender: self)

    }
    
    @IBAction func recipeButton(_ sender: Any) {
        label = "Recipes"
        performSegue(withIdentifier: "recipeSegue", sender: self)

    }
    @IBAction func recipeMatchButton(_ sender: Any) {
        label = "Recipe Match"
        performSegue(withIdentifier: "recipeSegue", sender: self)

    }
    @IBAction func shoppingButton(_ sender: Any) {
        label = "Shopping List"
        performSegue(withIdentifier: "firstSegue", sender: self)

    }
    @IBAction func aboutButton(_ sender: Any) {
    }
    
//Creates the database if it doesn't already exist
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GroceryDatabase.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("Error opening database")
            return
        }
        
        let createFoodTableQuery = "CREATE TABLE IF NOT EXISTS Food (Id INTEGER PRIMARY KEY AUTOINCREMENT, food TEXT, date TEXT, expired INTEGER)"
        
        let createRecipeTableQuery = "CREATE TABLE IF NOT EXISTS Recipes (recipeId INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, percentage DOUBLE)"
        
        let createIngredientTableQuery = "CREATE TABLE IF NOT EXISTS Ingredients (Id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, wholeMeasure TEXT, fractionMeasure TEXT, measureUnits TEXT, recipeId INTEGER, FOREIGN KEY(recipeId) REFERENCES Recipes(recipeId))"
        
        let createStepTableQuery = "CREATE TABLE IF NOT EXISTS Steps (Id INTEGER PRIMARY KEY AUTOINCREMENT, step TEXT, recipeId INTEGER, FOREIGN KEY(recipeId) REFERENCES Recipes(recipeId))"
        
        let createShoppingListTableQuery = "CREATE TABLE IF NOT EXISTS ShoppingList (Id INTEGER PRIMARY KEY AUTOINCREMENT, item TEXT)"
        
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
        
        if sqlite3_exec(db, createShoppingListTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating ShoppingList table")
            return
        }
        prepopulateRecipes()
        checkExpirDates()
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
        if segue.destination is RecipeTestTableViewController{
            let vc = segue.destination as? RecipeTestTableViewController
            vc?.db = db
            vc?.label = label
            vc?.nearExpired = expirFood
        }
    }
    
//Creates an alert if you have any food that will expire within 3 days.
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
            
            let string = expirFood.joined(separator: ", ")
            // If no food will expire within 3 days, don't display alert
            if string == ""{
                lastDate = Date()
                result = formatter.string(from: lastDate!) as NSString
                return
            }
            else{
                let alert = UIAlertController(title: "Food Expiring Within 3 Days:", message: "\(string)", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
                lastDate = Date()
                
                result = formatter.string(from: lastDate!) as NSString
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
// Prepopulate 3 recipes
    func prepopulateRecipes() {
        var insertStatement: OpaquePointer? = nil
        
        let prepopRecipe1 = "INSERT OR IGNORE INTO Recipes (recipeId, name) VALUES(1,'Honey Mustard Grilled Chicken');"
        if sqlite3_prepare_v2(db, prepopRecipe1, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("REC saved successfully")
        }
        
        let prepopIngr1 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(1,'Dijon Mustard', 'None', '1/3', 'cup', 1);"
        if sqlite3_prepare_v2(db, prepopIngr1, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 2 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepopIngr2 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(2, 'Honey', 'None', '1/4', 'cup', 1);"
        if sqlite3_prepare_v2(db, prepopIngr2, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 3 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepopIngr3 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(3,'Mayonnaise', 'None', '2', 'tbsp', 1);"
        if sqlite3_prepare_v2(db, prepopIngr3, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 4 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepopIngr4 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(4, 'Steak Sauce', '1', 'None', 'tsp', 1);"
        if sqlite3_prepare_v2(db, prepopIngr4, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 5 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepopIngr5 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(5, 'Chicken Breasts', '4', 'None', 'None', 1);"
        if sqlite3_prepare_v2(db, prepopIngr5, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 6 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepopStep1 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(1,'Preheat grill to medium heat', 1);"
        
        if sqlite3_prepare_v2(db, prepopStep1, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        
        let prepopStep2 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(2,'In a shallow bowl, mix the mustard, honey, mayonnaise, and steak sauce. Set aside a small amount of the honey mustard sauce for basting, and dip the chicken into the remaining sauce to coat.', 1);"
        if sqlite3_prepare_v2(db, prepopStep2, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        let prepopStep3 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(3,'Lightly oil the grill grate. Grill chicken over indirect heat for 18 to 20 minutes, turning occasionally, or until juices run clear. Baste occasionally with the reserved sauce during the last 10 minutes. Watch carefully to prevent burning!', 1);"
        if sqlite3_prepare_v2(db, prepopStep3, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        
        
        // RECIPE 2
        let prepopRecipe2 = "INSERT OR IGNORE INTO Recipes (recipeId, name) VALUES(2,'Banana Bread');"
        if sqlite3_prepare_v2(db, prepopRecipe2, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("REC saved successfully")
        }
        
        
        let prepop2Ingr1 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(6,'Sugar', '1', 'None', 'cup', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr1, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 2 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        
        let prepop2Ingr2 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(7, 'Butter', '8', 'None', 'tbsp', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr2, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 3 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        
        let prepop2Ingr3 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(8,'Eggs', '2', 'None', 'None', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr3, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 4 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        
        let prepop2Ingr4 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(9, 'Bananas', '3', 'None', 'None', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr4, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 5 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        
        let prepop2Ingr5 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(10, 'Milk', '1', 'None', 'tbsp', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr5, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 6 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop2Ingr6 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(11, 'Cinnamon', '1', 'None', 'tsp', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr6, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 7 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop2Ingr7 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(12, 'Flour', '2', 'None', 'cup', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr7, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 8 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop2Ingr8 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(13, 'Baking Powder', '1', 'None', 'tsp', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr8, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 9 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop2Ingr9 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(14, 'Baking Soda', '1', 'None', 'tsp', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr9, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 9 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop2Ingr10 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(14, 'Salt', '1', 'None', 'tsp', 2);"
        if sqlite3_prepare_v2(db, prepop2Ingr10, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 9 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop2Step1 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(4,'Preheat the oven to 325 degrees F. Butter a 9 x 5 x 3 inch loaf pan.', 2);"
        if sqlite3_prepare_v2(db, prepop2Step1, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        
        
        let prepop2Step2 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(5,'Cream the sugar and butter in a large mixing bowl until light and fluffy. Add the eggs one at a time, beating well after each addition.', 2);"
        if sqlite3_prepare_v2(db, prepop2Step2, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        let prepop2Step3 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(6,'In a small bowl, mash the bananas with a fork. Mix in the milk and cinnamon. In another bowl, mix together the flour, baking powder, baking soda and salt.', 2);"
        if sqlite3_prepare_v2(db, prepop2Step3, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        
        let prepop2Step4 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(7,'Add the banana mixture to the creamed mixture and stir until combined. Add dry ingredients, mixing just until flour disappears.', 2);"
        if sqlite3_prepare_v2(db, prepop2Step4, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        
        let prepop2Step5 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(8,'Pour batter into prepared pan and bake 1 hour to 1 hour 10 minutes, until a toothpick inserted in the center comes out clean. Set aside to cool on a rack for 15 minutes. Remove bread from pan, invert onto rack and cool completely before slicing.', 2);"
        if sqlite3_prepare_v2(db, prepop2Step5, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        
        
        let prepop2Step6 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(9,'Spread slices with honey or serve with ice cream.', 2);"
        if sqlite3_prepare_v2(db, prepop2Step6, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        
        //RECIPE 3
        
        let prepopRecipe3 = "INSERT OR IGNORE INTO Recipes (recipeId, name) VALUES(3,'Peanut Butter Banana Smoothie');"
        if sqlite3_prepare_v2(db, prepopRecipe3, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("REC saved successfully")
        }
        
        let prepop3Ingr1 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(15, 'Bananas', '2', 'None', 'None', 3);"
        if sqlite3_prepare_v2(db, prepop3Ingr1, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 10 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop3Ingr2 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(16, 'Milk', '2', 'None', 'cup', 3);"
        if sqlite3_prepare_v2(db, prepop3Ingr2, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 10 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop3Ingr3 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(17, 'Peanut Butter', 'None', '1/2', 'cup', 3);"
        if sqlite3_prepare_v2(db, prepop3Ingr3, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 10 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop3Ingr4 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(18, 'Honey', '2', 'None', 'tbsp', 3);"
        if sqlite3_prepare_v2(db, prepop3Ingr4, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 10 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop3Ingr5 = "INSERT OR IGNORE INTO Ingredients (Id, name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES(19, 'Ice Cubes', '2', 'None', 'cup', 3);"
        if sqlite3_prepare_v2(db, prepop3Ingr5, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding 10 query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingre saved successfully")
        }
        
        let prepop3Step1 = "INSERT OR IGNORE INTO Steps (Id, step, recipeId) VALUES(10,'Place bananas, milk, peanut butter, honey, and ice cubes in a blender; blend until smooth, about 30 seconds.', 3);"
        if sqlite3_prepare_v2(db, prepop3Step1, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding step query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("step saved successfully")
        }
        
        
    }
    
// Update the expired field in the food table
    func checkExpirDates() {
        let queryFoodStatementString = "SELECT * FROM Food;"
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryFoodStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let food = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let date = String(cString: queryResultCol2!)
                let expir = sqlite3_column_int(queryStatement, 3)
                foodList.append(food)
                dateList.append(date)
                isExpired.append(expir)
                idList.append(id)
                print("Query Result:")
                print("\(id) | \(food) | \(date)")
            }
            if foodList.count > 0{
                foodList.append("Completely Empty Pantry")
                dateList.append("")
                isExpired.append(2)
            }
        
    }
        let currDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let today = formatter.string(from: currDate) as NSString
        let todayArray = today.components(separatedBy: "/")
        let todayYear = Int(todayArray[2])
        let todayMonth = Int(todayArray[0])
        let todayDay = Int(todayArray[1])
        var isPast = 0
        
        if foodList.count > 0{
        for i in 0...(foodList.count-1){
            if isExpired[i] == 0{
                if dateList[i] != ""{
                let dateArray = dateList[i].components(separatedBy: "/")
                let checkYear = Int(dateArray[2])!
                let checkMonth = Int(dateArray[0])!
                let checkDay = Int(dateArray[1])!

                    if checkYear < todayYear!{
                        isPast = 1
                    }
                    else if checkYear == todayYear!{
                        if checkMonth < todayMonth!{
                            isPast = 1
                        }
                        else{
                            if checkMonth == todayMonth! && checkDay < todayDay!{
                                isPast = 1
                            }
                        }
                    }
                }
            }
            //Only update table if isPast has changed
            if isPast == 1 {
                let queryStatementString = "UPDATE Food SET expired = 1 WHERE id = '\(idList[i])';"
                var updateStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(db, queryStatementString, -1, &updateStatement, nil) != SQLITE_OK{
                    print("Error preparing update statement")
                }
                if sqlite3_step(updateStatement) == SQLITE_DONE{
                    print("Recipe percentage edited successfully")
                }

                isPast = 0
            }

        }
        }
    }

}
