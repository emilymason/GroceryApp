//
//  AddViewController.swift
//  Grocery
//
//  Created by Emily Mason on 1/25/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class AddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var db: OpaquePointer?
    var label: String?
    var months: [String] = ["None"]
    var days: [String] = ["None"]
    var years: [String] = ["None"]
    var date: NSString = ""

    let datePicker = UIDatePicker()
    
    @IBOutlet weak var textFieldFood: UITextField!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    @IBAction func buttonSave(_ sender: Any) {
        let food: NSString = textFieldFood.text! as NSString
       // let date: NSString = textFieldDate.text! as NSString
        
        if (food == ""){
             print("food field is empty")
            return;
        }
        if date.contains("None"){
            date = ""
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
        
        
        //UPDATE PERCENTAGES
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        months.append("01")
        months.append("02")
        months.append("03")
        months.append("04")
        months.append("05")
        months.append("06")
        months.append("07")
        months.append("08")
        months.append("09")
        months.append("10")
        months.append("11")
        months.append("12")
        
        days.append("01")
        days.append("02")
        days.append("03")
        days.append("04")
        days.append("05")
        days.append("06")
        days.append("07")
        days.append("08")
        days.append("09")
        
        for i in 10...31
        {
            days.append(String(i))
        }
        
        for i in 2019...2070
        {
            years.append(String(i))
        }
        
        
        
        
       // createDatePicker()
        
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return months[row]
        }
        else if component == 1{
            return days[row]
        }
        else{
            return years[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return months.count
        }
        else if component == 1{
            return days.count
        }
        else{
            return years.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = months[pickerView.selectedRow(inComponent: 0)] as NSString
        let day = days[pickerView.selectedRow(inComponent: 1)] as NSString
        let year = years[pickerView.selectedRow(inComponent: 2)] as NSString
        date = ((month as String) + "/" + (day as String) + "/" + (year as String)) as NSString
        
    }
    
//    func createDatePicker(){
//
//        datePicker.datePickerMode = .date
//        datePicker.minimumDate = Date()
//
//        textFieldDate.inputView = datePicker
//
//        //create toolbar
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//
//        //add done button
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))
//        toolbar.setItems([doneButton], animated: true)
//
//        textFieldDate.inputAccessoryView = toolbar
//    }
//
//    @objc func doneClicked(){
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//
//        textFieldDate.text = dateFormatter.string(from: datePicker.date)
//        self.view.endEditing(true)
//    }
//
//
//    @objc func dateChanged(datePicker: UIDatePicker){
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "mm/dd/yyyy"
//
//        textFieldDate.text = dateFormatter.string(from: datePicker.date)
//
//        view.endEditing(true)
//    }
    
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
