//
//  TableViewController.swift
//  Grocery
//
//  Created by Emily Mason on 1/17/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

import UIKit

var cellLabels = ["Food", "Recipes", "Shopping List"]
var cellDescriptions = ["display my food", "display my recipes", "display my shopping list"]
var myIndex = 0

class TableViewController: UITableViewController {
 
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  cellLabels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = cellLabels[indexPath.row]
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex =  indexPath.row
        performSegue(withIdentifier: "segue", sender: self)
    }
}
