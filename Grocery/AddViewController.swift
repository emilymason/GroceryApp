//
//  AddViewController.swift
//  Grocery
//
//  Created by Emily Mason on 1/25/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class AddViewController: UIViewController {
    
    var db: OpaquePointer?
    var label: String?

    let datePicker = UIDatePicker()
    
    @IBOutlet weak var textFieldFood: UITextField!
    
    @IBOutlet weak var textFieldDate: UITextField!
    
    @IBAction func buttonSave(_ sender: Any) {
        let food: NSString = textFieldFood.text! as NSString
        let date: NSString = textFieldDate.text! as NSString
        
        if (food == ""){
             print("food field is empty")
            return;
        }
        
        var insertStatement: OpaquePointer? = nil
            
        let insertStatementString = "INSERT INTO Food (food, date) VALUES (?, ?)"
            
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) != SQLITE_OK{
            print("Error binding query")
        }
            
        if sqlite3_bind_text(insertStatement, 1, food.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding food")
        }
        
        if sqlite3_bind_text(insertStatement, 2, date.utf8String, -1, nil) != SQLITE_OK{
            print("Error binding date")
        }
            
        if sqlite3_step(insertStatement) == SQLITE_DONE{
            print("Food saved successfully")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        
        
    }
    
    func createDatePicker(){
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
        textFieldDate.inputView = datePicker
        
        //create toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //add done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))
        toolbar.setItems([doneButton], animated: true)
        
        textFieldDate.inputAccessoryView = toolbar

    }
    
    @objc func doneClicked(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        textFieldDate.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    

    @objc func dateChanged(datePicker: UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm/dd/yyyy"
        
        textFieldDate.text = dateFormatter.string(from: datePicker.date)
        
        view.endEditing(true)
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
