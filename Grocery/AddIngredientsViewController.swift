//
//  AddIngredientsViewController.swift
//  Grocery
//
//  Created by Emily Mason on 2/23/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class AddIngredientsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var db: OpaquePointer?
    var label: String?
    var recipeTitle: String?
    var recipeId: Int32?
    var wholeMeasure = ["None"]
    var fractionMeasure: [String] = []
    var measureUnits: [String] = []
    var whole: NSString = ""
    var fraction: NSString = ""
    var unit: NSString = ""
    
    
    
    @IBOutlet weak var textFieldIngredient: UITextField!
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBAction func saveButton(_ sender: Any) {
        let ingredient: NSString = textFieldIngredient.text! as NSString
        
        
        if (ingredient == ""){
            print("ingredient field is empty")
            return;
        }
        
        var insertStatement: OpaquePointer? = nil
        
        let insertStatementString = "INSERT INTO Ingredients (name, wholeMeasure, fractionMeasure, measureUnits, recipeId) VALUES (?, ?,?,?,?)"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_bind_text(insertStatement, 1, ingredient.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding ingredient")
        }
        
        if sqlite3_bind_text(insertStatement, 2, whole.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding whole measurement")
        }
        
        if sqlite3_bind_text(insertStatement, 3, fraction.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding fraction measurement")
        }
        
        if sqlite3_bind_text(insertStatement, 4, unit.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding measurement unit")
        }
        
        if sqlite3_bind_int(insertStatement, 5, recipeId ?? -1) != SQLITE_OK{
            print("Error binding recipe Id")
            }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingredient saved successfully")
        }
        performSegue(withIdentifier: "saveSegue", sender: self)

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...100
        {
            wholeMeasure.append(String(i))
        }
        fractionMeasure.append("None")
        fractionMeasure.append("1/8")
        fractionMeasure.append("1/4")
        fractionMeasure.append("1/3")
        fractionMeasure.append("1/2")
        fractionMeasure.append("2/3")
        fractionMeasure.append("3/4")
        
        measureUnits.append("None")
        measureUnits.append("tsp")
        measureUnits.append("tbsp")
        measureUnits.append("cup")
        measureUnits.append("oz")
        measureUnits.append("lbs")
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AddRecipeTableViewController
        {
            let vc = segue.destination as? AddRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle! as NSString
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return wholeMeasure[row]
        }
        else if component == 1{
            return fractionMeasure[row]
        }
        else{
            return measureUnits[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return wholeMeasure.count
        }
        else if component == 1{
            return fractionMeasure.count
        }
        else{
            return measureUnits.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        whole = wholeMeasure[pickerView.selectedRow(inComponent: 0)] as NSString
        fraction = fractionMeasure[pickerView.selectedRow(inComponent: 1)] as NSString
        unit = measureUnits[pickerView.selectedRow(inComponent: 2)] as NSString
    }
    

}