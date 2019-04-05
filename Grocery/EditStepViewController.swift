//
//  EditStepViewController.swift
//  Recipe Crunch
//
//  Created by Emily Mason on 4/1/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class EditStepViewController: UIViewController {

    var db: OpaquePointer?
    var label: String?
    var step: String?
    var recipeTitle: NSString?
    var recipeId: Int32?
    var cameFrom: String?
    var stepId: Int32?
    
    
    @IBOutlet weak var stepBox: UITextView!
    @IBAction func backButton(_ sender: Any) {
        if (cameFrom == "Add"){
        performSegue(withIdentifier: "backEditStepSegue", sender: self)
        }
        else{
            performSegue(withIdentifier: "editSteptoEdit", sender: self)
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let newStep: NSString = stepBox.text! as NSString

        let updateStatementString = "UPDATE Steps SET step = '\(newStep)' WHERE recipeId = '\(recipeId!)' AND Id = '\(stepId!)';"
        var updateStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_step(updateStatement) == SQLITE_DONE{
            print("Food edited successfully")
        }
        if(cameFrom == "Add"){
        performSegue(withIdentifier: "backEditStepSegue", sender: self)
        }
        else{
            performSegue(withIdentifier: "editSteptoEdit", sender: self)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepBox.text = step
        getStepId()

        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AddRecipeTableViewController
        {
            let vc = segue.destination as? AddRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle
            vc?.recipeId = recipeId
        }
        if segue.destination is EditRecipeTableViewController
        {
            let vc = segue.destination as? EditRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle as String?
            vc?.recipeId = recipeId
        }
    }
    
    func getStepId() {
        var queryStatement: OpaquePointer? = nil
        let queryStatementString = "SELECT Id FROM Steps WHERE step = '\(step!)' AND recipeId = '\(recipeId!)';"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                stepId = sqlite3_column_int(queryStatement, 0)
                
            }
            
        } else {
            print("SELECT statement for step id could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }


}
