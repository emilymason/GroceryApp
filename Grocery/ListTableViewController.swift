//
//  ListTableViewController.swift
//  Grocery
//
//  Created by Emily Mason on 1/26/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3


class ListTableViewCell: UITableViewCell{
    
   
    @IBOutlet weak var cellView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expirLabel: UILabel!
    
    
}

class ListTableViewController: UITableViewController {
    
    var db: OpaquePointer?
    var foodList: [String] = []
    var dateList: [String] = []
    var isExpired: [Int32] = []
    var editFood: NSString = ""
    var editDate: NSString = ""
    var editId: Int32?
    var recipeList: [String] = []
    var recipeTitle: String?
    var shoppingList: [String] = []
    var label: String?
    let queryFoodStatementString = "SELECT * FROM Food ORDER BY food ASC;"
    let queryRecipeStatementString = "SELECT * FROM Recipes ORDER BY name ASC;"
    let queryShoppingStatementString = "SELECT * FROM ShoppingList ORDER BY item ASC;"
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var navTitle: UINavigationBar!
    @IBAction func addButton(_ sender: Any) {
        if label == "Food"{
            performSegue(withIdentifier: "addFoodSegue", sender: self)
        }
        else if label == "Shopping List"{
            performSegue(withIdentifier: "addShoppingSegue", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        if label == "Food"{
        let backgroundImage = UIImage(named: "dietBack.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        imageView.contentMode = .center
        imageView.alpha = 0.1
        }
        if label == "Shopping List"{
            let backgroundImage = UIImage(named: "shopping.png")
            let imageView = UIImageView(image: backgroundImage)
            self.tableView.backgroundView = imageView
            imageView.contentMode = .center
            imageView.alpha = 0.2
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 20)!]

        //Set title of table view depending on label
        if label == "Food"{
            navBar.title = "My Pantry"
        }

        else if label == "Shopping List"{
            navBar.title = "Shopping List"
        }
        else if label == "Recipe Match"{
            navBar.title = "Recipe Match"
        }
        
        query()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AddViewController
        {
            let vc = segue.destination as? AddViewController
            vc?.db = db
            vc?.label = label
        }
        if segue.destination is LandingViewController
        {
            let vc = segue.destination as? LandingViewController
            vc?.db = db
            
            
        }
        if segue.destination is AddShoppingViewController
        {
            let vc = segue.destination as? AddShoppingViewController
            vc?.db = db
            vc?.label = label
            
            
        }
        if segue.destination is AddRecipeViewController
        {
            let vc = segue.destination as? AddRecipeViewController
            vc?.db = db
            vc?.label = label
        }
        if segue.destination is EditViewController
        {
            let vc = segue.destination as? EditViewController
            vc?.db = db
            vc?.editFood = editFood
            vc?.editDate = editDate
            vc?.label = label
            // Get the food id for editing and pass it to EditViewController
            let queryIdStatementString = "SELECT Id FROM Food WHERE food = '\(editFood)' AND date = '\(editDate)';"
            var queryIdStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, queryIdStatementString, -1, &queryIdStatement, nil) != SQLITE_OK{
                print("Error binding get Id query")
            }
            if sqlite3_bind_text(queryIdStatement, 1, editFood.utf8String, -1, nil) != SQLITE_OK{
                print("Error binding get ID food")
            }
            if sqlite3_bind_text(queryIdStatement, 1, editDate.utf8String, -1, nil) != SQLITE_OK{
                print("Error binding get ID date")
            }
            
            while (sqlite3_step(queryIdStatement) == SQLITE_ROW){
               let newId = sqlite3_column_int(queryIdStatement, 0)
                vc?.editId = newId
            }
            
        }

    }
 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if label == "Food"{
           return foodList.count
        }
        else if label == "Shopping List"{
            return shoppingList.count
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell
        cell.backgroundColor = .clear

        if label == "Food"
        {
            cell.titleLabel.text = foodList[indexPath.row]
            cell.expirLabel.text = dateList[indexPath.row]
            
            if foodList[indexPath.row] != "Completely Empty Pantry"{
            cell.cellView.image = UIImage(named: "bananana.png")
            }
            

            if foodList[indexPath.row] == "Completely Empty Pantry"{
                cell.textLabel?.text = foodList[indexPath.row]
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .red
                cell.titleLabel?.text = ""
                cell.expirLabel?.text = ""
                cell.cellView.image = nil
                
            }
            if isExpired[indexPath.row] == 1{
                cell.expirLabel.textColor = .red
            }
        }

        else if label == "Shopping List"{
            cell.titleLabel?.text = " "
            cell.expirLabel?.text = " "
            
            cell.textLabel?.text = shoppingList[indexPath.row]
            if shoppingList[indexPath.row] == "Completely Empty Shopping List"{
                cell.textLabel?.textColor = .red
                cell.textLabel?.textAlignment = .center
            }
        }
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(red: 175/255, green: 206/255, blue: 255/255, alpha: 0.4)
        cell.selectedBackgroundView = cellBGView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if label == "Recipes"{
            if recipeList[indexPath.row] == "Honey Mustard Grilled Chicken" || recipeList[indexPath.row] == "Banana Bread" || recipeList[indexPath.row] == "Peanut Butter Banana Smoothie"{
                return false
            }
        }
        if label == "Food"{
            if foodList[indexPath.row] == "Completely Empty Pantry"{
                return false
            }
        }
        if label == "Shopping List"{
            if shoppingList[indexPath.row] == "Completely Empty Shopping List"{
                return false
            }
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            if label == "Food"{
                let deleteStatmentString = "DELETE FROM Food WHERE food = '\(foodList[indexPath.row])' AND date = '\(dateList[indexPath.row])';"
            
          
            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, deleteStatmentString, -1, &deleteStatement, nil) == SQLITE_OK {
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Successfully deleted row.")
                } else {
                    print("Could not delete row.")
                }
            } else {
                print("DELETE statement could not be prepared")
            }
            sqlite3_finalize(deleteStatement)
            foodList.remove(at: indexPath.row)
            dateList.remove(at: indexPath.row)
                if foodList.count == 1{
                    foodList.removeAll()
                    dateList.removeAll()
                }
            tableView.reloadData()
                

            }
            else if label == "Shopping List" {
                let deleteStatmentString = "DELETE FROM ShoppingList WHERE item = '\(shoppingList[indexPath.row])';"
                
                
                var deleteStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(db, deleteStatmentString, -1, &deleteStatement, nil) == SQLITE_OK {
                    if sqlite3_step(deleteStatement) == SQLITE_DONE {
                        print("Successfully deleted row.")
                    } else {
                        print("Could not delete row.")
                    }
                } else {
                    print("DELETE statement could not be prepared")
                }
                sqlite3_finalize(deleteStatement)
                shoppingList.remove(at: indexPath.row)
                if shoppingList.count == 1{
                    shoppingList.removeAll()
                }
                tableView.reloadData()
            }
        }
        
    }
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        if label == "Food"{
        if sqlite3_prepare_v2(db, queryFoodStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let food = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let date = String(cString: queryResultCol2!)
                let expired = sqlite3_column_int(queryStatement, 3)
                foodList.append(food)
                dateList.append(date)
                isExpired.append(expired)
                print("Query Result:")
                print("\(id) | \(food) | \(date)")
            }
            if foodList.count > 0{
            foodList.append("Completely Empty Pantry")
            dateList.append("")
            isExpired.append(2)
            }
            
            
        } else {
            print("SELECT statement for food could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        }
        
        else {
            if sqlite3_prepare_v2(db, queryShoppingStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    let id = sqlite3_column_int(queryStatement, 0)
                    let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                    let item = String(cString: queryResultCol1!)
                    shoppingList.append(item)
                    print("Query Result:")
                    print("\(id) | \(item)")
                }
                if shoppingList.count > 0{
                    shoppingList.append("Completely Empty Shopping List")
                }

                
            } else {
                print("SELECT statement for shopping list could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if label == "Food"{
            if foodList[indexPath.row] == "Completely Empty Pantry"{
                let alert = UIAlertController(title: "Warning", message: "Are you sure you want to completely empty your pantry?", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                    self.emptyPantry()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
                
                self.present(alert, animated: true, completion: nil)
            }
            else{
                editFood = foodList[indexPath.row] as NSString
                editDate = dateList[indexPath.row] as NSString
                performSegue(withIdentifier: "editSegue", sender: self)
            }
        }

        else if label == "Shopping List"{
            if shoppingList[indexPath.row] == "Completely Empty Shopping List"{
                let alert = UIAlertController(title: "Warning", message: "Are you sure you want to completely empty your shopping list?", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                    self.emptyShoppingList()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
                
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Do you want to add \(shoppingList[indexPath.row]) to your pantry?", message: "", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                    self.AddToPantry(food: self.shoppingList[indexPath.row])
                    tableView.reloadData()

                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))

                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func GetId(recipeName: String) -> Int32 {
        var newId: Int32 = 0
        let queryIdStatementString = "SELECT recipeId FROM Recipes WHERE name = '\(recipeName)';"
        var queryIdStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryIdStatementString, -1, &queryIdStatement, nil) != SQLITE_OK{
            print("Error binding get Id query")
        }
        
        while (sqlite3_step(queryIdStatement) == SQLITE_ROW){
            newId = sqlite3_column_int(queryIdStatement, 0)
        }
        
        return newId
    }
    
    func emptyPantry() {
        let emptyString = "DELETE FROM Food;"
        var emptyStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, emptyString, -1, &emptyStatement, nil) != SQLITE_OK{
            print("Error deleting all")
        }
        
        if sqlite3_step(emptyStatement) == SQLITE_DONE {
            print("Successfully deleted food.")
        } else {
            print("Could not delete food.")
        }
        sqlite3_finalize(emptyStatement)
        foodList.removeAll()
        dateList.removeAll()
        tableView.reloadData()
    }
    
    func emptyShoppingList() {
        let emptyString = "DELETE FROM ShoppingList;"
        var emptyStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, emptyString, -1, &emptyStatement, nil) != SQLITE_OK{
            print("Error deleting all")
        }
        
        if sqlite3_step(emptyStatement) == SQLITE_DONE {
            print("Successfully deleted list.")
        } else {
            print("Could not delete list.")
        }
        sqlite3_finalize(emptyStatement)
        shoppingList.removeAll()
        tableView.reloadData()
    }

    func AddToPantry(food: String){
        let date = ""
        let expired = 0
        let queryStatementString = "INSERT INTO Food (food,date,expired) VALUES('\(food)','\(date)','\(expired)');"
        let queryDeleteStatementString = "DELETE FROM ShoppingList WHERE item = '\(food)';"
        var queryStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }

        if sqlite3_step(queryStatement) == SQLITE_DONE{
            print("Food saved successfully")
        }
        if sqlite3_prepare_v2(db, queryDeleteStatementString, -1, &queryStatement, nil) != SQLITE_OK{
            print("Error binding delete")
        }
        if sqlite3_step(queryStatement) == SQLITE_DONE{
            print("Food deleted successfully")
        }



        sqlite3_finalize(queryStatement)
        shoppingList.remove(at: shoppingList.index(of: food)!)
        print(shoppingList.count)
        if shoppingList.count == 1{
            shoppingList.removeAll()
        }
        tableView.reloadData()


    }

}
