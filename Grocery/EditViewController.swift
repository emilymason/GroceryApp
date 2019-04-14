//
//  EditViewController.swift
//  Grocery
//
//  Created by Emily Mason on 2/1/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class EditViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var db: OpaquePointer?
    var label: String?
    var editFood: NSString = ""
    var editDate: NSString = ""
    var editId: Int32? = nil
    var months: [String] = ["None"]
    var days: [String] = ["None"]
    var years: [String] = ["None"]
    var newDate: NSString = ""
    var recipeIdList: [Int32] = []
    var foodList: [String] = []
    var parseDate: String = ""
    var parseMonth: String = ""
    var parseDay: String = ""
    var parseYear: String = ""

    @IBOutlet weak var foodEdit: UITextField!
    
    @IBOutlet weak var picker: UIPickerView!
    

    @IBAction func saveButton(_ sender: Any) {
        
        let newFood: NSString = foodEdit.text! as NSString
        //let newDate: NSString = dateEdit.text! as NSString
        
        if (newFood == ""){
            print("food field is empty")
            return;
        }
        if newDate.contains("None"){
            newDate = ""
        }
        
        let updateStatementString = "UPDATE Food SET food = '\(newFood)', date = '\(newDate)' WHERE Id = \(editId!);"
        var updateStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_step(updateStatement) == SQLITE_DONE{
            print("Food edited successfully")
        }
        
        getRecipeId()
        populateFoodList()
        
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
        
        performSegue(withIdentifier: "editFoodSegue", sender: self)
        
    }
    
    override func viewDidLoad() {
        foodEdit.text? = editFood as String
       // dateEdit.text? = editDate as String
        print("ID IN EDIT VIEW")
        print(editId!)
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
        
        parseDate = editDate as String
        var parseArray = parseDate.components(separatedBy: "/")
        if parseArray.count == 1{
            parseArray[0] = "None"
            parseArray.append("None")
            parseArray.append("None")
        }
        print(parseArray)
        
        picker.selectRow(months.index(of: parseArray[0])!, inComponent: 0, animated: true)
        picker.selectRow(days.index(of: parseArray[1])!, inComponent: 1, animated: true)
        picker.selectRow(years.index(of: parseArray[2])!, inComponent: 2, animated: true)

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
        newDate = ((month as String) + "/" + (day as String) + "/" + (year as String)) as NSString
        
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
