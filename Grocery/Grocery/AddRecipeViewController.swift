//
//  AddRecipeViewController.swift
//  Grocery
//
//  Created by Emily Mason on 2/23/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class AddRecipeViewController: UIViewController {
    var db: OpaquePointer?
    var label: String?
    var recipeTitle: String?
    var recipeList: [String] = []
    var name: NSString?

    @IBOutlet weak var recipeName: UITextField!
    
    
    @IBAction func nextButtons(_ sender: Any) {
        name = recipeName.text! as NSString
        recipeTitle = recipeName.text!
        
        if (name == ""){
            print("name field is empty")
            return;
        }
        // Don't allow duplicate recipe names.
        if (recipeList.contains(name! as String)){
            let alert = UIAlertController(title: "Duplicate Recipe", message: "You already have a recipe with this name. Please choose something else.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var insertStatement: OpaquePointer? = nil
        
        let insertStatementString = "INSERT INTO Recipes (name) VALUES (?)"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
        
        if sqlite3_bind_text(insertStatement, 1, name!.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding name")
        }
        
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Recipe name saved successfully")
        }
        
        performSegue(withIdentifier: "newIngredientSegue", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is RecipeTestTableViewController
        {
            let vc = segue.destination as? RecipeTestTableViewController
            vc?.db = db
            vc?.label = label
        }
        if segue.destination is AddRecipeTableViewController
        {
            let vc = segue.destination as? AddRecipeTableViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = name
        }
        if segue.destination is AddRecipeViewController{
            let vc = segue.destination as? AddRecipeViewController
            vc?.db = db
            vc?.label = label
            vc?.recipeTitle = recipeTitle
        }
    }
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        let queryRecipeStatementString = "SELECT name FROM Recipes;"

            if sqlite3_prepare_v2(db, queryRecipeStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                    let name = String(cString: queryResultCol1!)
                    recipeList.append(name)
                    print("Query Result:")
                }
                
            } else {
                print("SELECT statement for recipes could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }

}
