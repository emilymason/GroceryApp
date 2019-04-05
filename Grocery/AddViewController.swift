//
//  AddViewController.swift
//  Grocery
//
//  Created by Emily Mason on 1/25/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class AddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var db: OpaquePointer?
    var label: String?
    var months: [String] = ["None"]
    var days: [String] = ["None"]
    var years: [String] = ["None"]
    var date: NSString = ""
    var recipeIdList: [Int32] = []
    var foodList: [String] = []

    let datePicker = UIDatePicker()
    
    @IBOutlet weak var textFieldFood: UITextField!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func doneButton(_ sender: Any) {
        let food: NSString = textFieldFood.text! as NSString
        getRecipeId()
        populateFoodList()
        
        if (food == ""){
            print("food field is empty")
            return;
        }
        else if (food == "Completely Empty Pantry"){
            let alert = UIAlertController(title: "Error", message: "Invalid food item", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        else if (foodList.contains(food as String)){
            let alert = UIAlertController(title: "Duplicate Food", message: "Food is already in pantry", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        if date.contains("None"){
            date = ""
        }
        
        var insertStatement: OpaquePointer? = nil
        
        let insertStatementString = "INSERT INTO Food (food, date) VALUES (?, ?)"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_bind_text(insertStatement, 1, food.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding food")
        }
        
        if sqlite3_bind_text(insertStatement, 2, date.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding date")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Food saved successfully")
        }
        
        
    
        
        for recipe in recipeIdList{
            var match: Double = 0
            let ingredients: [String] = populateIngredientList(recipeId: recipe)
            for ingredient in ingredients{
                if foodList.contains(ingredient){
                    match += 1
                }
            }
            let percentage = match/Double(ingredients.count)
            
            let updateStatementString = "UPDATE Recipes SET percentage = \(percentage) WHERE recipeId = \(recipe);"
            var updateStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) != SQLITE_OK{
                print("Error preparing update statement")
            }
            if sqlite3_step(updateStatement) == SQLITE_DONE{
                print("Recipe percentage edited successfully")
            }
            
        }
        
        performSegue(withIdentifier: "saveFoodSegue", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        months.append("01")
        months.append("02")
        months.append("03")
        months.append("04")
        months.append("05")
        months.append("06")
        months.append("07")
        months.append("08")
        months.append("09")
        months.append("10")
        months.append("11")
        months.append("12")
        
        days.append("01")
        days.append("02")
        days.append("03")
        days.append("04")
        days.append("05")
        days.append("06")
        days.append("07")
        days.append("08")
        days.append("09")
        
        for i in 10...31
        {
            days.append(String(i))
        }
        
        for i in 2019...2070
        {
            years.append(String(i))
        }
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return months[row]
        }
        else if component == 1{
            return days[row]
        }
        else{
            return years[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return months.count
        }
        else if component == 1{
            return days.count
        }
        else{
            return years.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = months[pickerView.selectedRow(inComponent: 0)] as NSString
        let day = days[pickerView.selectedRow(inComponent: 1)] as NSString
        let year = years[pickerView.selectedRow(inComponent: 2)] as NSString
        date = ((month as String) + "/" + (day as String) + "/" + (year as String)) as NSString
        
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
    
    
   func getRecipeId() {
    var queryStatement: OpaquePointer? = nil
    let queryStatementString = "SELECT recipeId FROM Recipes;"
    
    if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            let id = sqlite3_column_int(queryStatement, 0)
            recipeIdList.append(id)
        }
        
    } else {
        print("SELECT statement for recipe ids could not be prepared")
    }
    sqlite3_finalize(queryStatement)
    }
    
    func populateIngredientList(recipeId: Int32) -> [String] {
        var ingredientList: [String] = []
        let queryIngredientString = "SELECT name FROM Ingredients WHERE recipeId = \(recipeId);"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryIngredientString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let ingredient = String(cString: queryResultCol1!)
                
                ingredientList.append(ingredient)
            }
            
        } else {
            print("Error Selecting Ingredients")
        }
        sqlite3_finalize(queryStatement)
        return ingredientList
        
    }
    
    func populateFoodList() {
        let queryFoodString = "SELECT food FROM Food;"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryFoodString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let food = String(cString: queryResultCol1!)
                
                foodList.append(food)
            }
            
        } else {
            print("Error Selecting Food")
        }
        sqlite3_finalize(queryStatement)
        
    }
    
    
}
