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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       // descLabel.text = cellDescriptions[myIndex]
        
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GroceryDatabase.sqlite")
        
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK{
            print("Error opening database")
            return
        }
        //Please take this out before you turn it in Emily
        print("SQLITE URL!!" + fileURL.path)
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Grocery (Id INTEGER PRIMARY KEY AUTOINCREMENT, food TEXT, date TEXT)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        
        print("Everything is fine")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AddViewController
        {
            let vc = segue.destination as? AddViewController
            vc?.db = db
        }
    }

}

