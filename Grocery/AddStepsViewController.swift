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
    @IBOutlet weak var textView: UITextView!

    
    
    @IBAction func saveButton(_ sender: Any) {
        let step: NSString = textView.text! as NSString
        
        
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
        performSegue(withIdentifier: "saveStepSegue", sender: self)
        
        
    }
    
    
    override func viewDidLoad() {
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
    }

}
