//
//  EditViewController.swift
//  Grocery
//
//  Created by Emily Mason on 2/1/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class EditViewController: UIViewController {
    var db: OpaquePointer?
    var label: String?
    var editFood: NSString = ""
    var editDate: NSString = ""
    var editId: Int32? = nil

    @IBOutlet weak var foodEdit: UITextField!
    
    @IBOutlet weak var dateEdit: UITextField!
    
    @IBAction func editSave(_ sender: Any) {
        let newFood: NSString = foodEdit.text! as NSString
        let newDate: NSString = dateEdit.text! as NSString
        
        let updateStatementString = "UPDATE Food SET food = '\(newFood)', date = '\(newDate)' WHERE Id = \(editId!);"
        var updateStatement: OpaquePointer? = nil

        
        if (newFood == ""){
            print("food field is empty")
            return;
        }
        
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }

//  don't  need because not doing VALUES() in query....
//        if sqlite3_bind_text(updateStatement, 1, newFood.utf8String, -1, nil) != SQLITE_OK{
//            print("Error binding ID food")
//        }
//        if sqlite3_bind_text(updateStatement, 2, newDate.utf8String, -1, nil) != SQLITE_OK{
//            print("Error binding ID date")
//        }
//        if sqlite3_bind_int(updateStatement, 3, editId ?? -1) != SQLITE_OK{
//            print("Error binding Id")
//        }
        
        if sqlite3_step(updateStatement) == SQLITE_DONE{
            print("Food edited successfully")
        }
        
        
    }
    override func viewDidLoad() {
        foodEdit.text? = editFood as String
        dateEdit.text? = editDate as String
        print("ID IN EDIT VIEW")
        print(editId!)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

}
