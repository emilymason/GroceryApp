//
//  AddShoppingViewController.swift
//  Grocery
//
//  Created by Emily Mason on 3/20/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class AddShoppingViewController: UIViewController {
    var label: String?
    var db: OpaquePointer?
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func doneButton(_ sender: Any) {
        let item: NSString = textField.text! as NSString
        
        if (item == ""){
            print("item field is empty")
            return;
        }
        
        var insertStatement: OpaquePointer? = nil
        
        let insertStatementString = "INSERT INTO ShoppingList (item) VALUES (?);"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_bind_text(insertStatement, 1, item.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding shopping item")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Shopping Item saved successfully")
        }
        
        performSegue(withIdentifier: "saveShoppingSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
