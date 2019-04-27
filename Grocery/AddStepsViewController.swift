//
//  AddStepsViewController.swift
//  Grocery
//
//  Created by Emily Mason on 2/23/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class AddStepsViewController: UIViewController {
    
    var db: OpaquePointer?
    var recipeTitle: NSString?
    var recipeId: Int32?
    var label: String?
    var cameFrom: String?
    
    @IBOutlet weak var textView: UITextView!
    
//Inserts steps into database and performs segue
    @IBAction func saveButton(_ sender: Any) {
        let step: NSString = textView.text! as NSString
        
        //Don't add step if there is nothing entered.
        if (step == ""){
            print("step field is empty")
            return;
        }
        
        var insertStatement: OpaquePointer? = nil
        
        let insertStatementString = "INSERT INTO Steps (step, recipeId) VALUES (?, ?)"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_bind_text(insertStatement, 1, step.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding step")
        }
        
        if sqlite3_bind_int(insertStatement, 2, recipeId ?? -1) != SQLITE_OK{
            print("Error binding recipe Id")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Step saved successfully")
        }
        if(cameFrom == "Add"){
        performSegue(withIdentifier: "saveStepSegue", sender: self)
        }
        else{
            performSegue(withIdentifier: "addStepBackToEdit", sender: self)
        }
        
        
    }
    
//Add border so text box is visible
    override func viewDidLoad() {
        self.textView.layer.borderColor = UIColor.gray.cgColor
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.cornerRadius = 2
        super.viewDidLoad()
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

}
