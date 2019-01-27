//
//  ViewController.swift
//  Grocery
//
//  Created by Emily Mason on 1/17/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
    
    var db: OpaquePointer?

    @IBOutlet weak var descLabel: UILabel!
    var foodList = [Food]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        descLabel.text = cellDescriptions[myIndex]
    }
    
    func readValues(){
        foodList.removeAll()
        
        let foodQueryString = "SELECT * FROM Grocery"
        
        var foodQuery: OpaquePointer? = nil
        
        if sqlite3_prepare(db, foodQueryString, -1, &foodQuery, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
    }


}

