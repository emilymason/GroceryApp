//
//  EditIngredientViewController.swift
//  Recipe Crunch
//
//  Created by Emily Mason on 4/1/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class EditIngredientViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var db: OpaquePointer?
    var label: String?
    var ingredient: String?
    var recipeTitle: NSString?
    var recipeId: Int32?
    var wholeMeasure = ["None"]
    var fractionMeasure: [String] = []
    var measureUnits: [String] = []
    var whole: NSString = ""
    var fraction: NSString = ""
    var unit: NSString = ""
    var cameFrom: String?
    
    
    @IBOutlet weak var ingredientText: UITextField!
    @IBOutlet weak var measurePicker: UIPickerView!
    
    @IBAction func backButton(_ sender: Any) {
        if (cameFrom == "Add"){
        performSegue(withIdentifier: "backEditIngredSegue", sender: self)
        }
        else{
            performSegue(withIdentifier: "editIngredtoEdit", sender: self)
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let newIngredient: NSString = ingredientText.text! as NSString
        
        
        if (newIngredient == ""){
            print("ingredient field is empty")
            return;
        }
        
        var insertStatement: OpaquePointer? = nil
        
        let insertStatementString = "UPDATE Ingredients SET name = '\(newIngredient)', wholeMeasure = '\(whole)', fractionMeasure = '\(fraction)', measureUnits = '\(unit)' WHERE name = '\(ingredient!)' AND recipeId = '\(recipeId!)';"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Ingredient saved successfully")
        }
        
        if(cameFrom == "Add"){
        performSegue(withIdentifier: "backEditIngredSegue", sender: self)
        }
        else{
            performSegue(withIdentifier: "editIngredtoEdit", sender: self)
        }
        
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ingredientText.text = ingredient
        //measurePicker.selectRow(2, inComponent: 0, animated: true)
        
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
        if segue.destination is EditRecipeTableViewController
        {
            let vc = segue.destination as? EditRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle! as String
            vc?.recipeId = recipeId
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
