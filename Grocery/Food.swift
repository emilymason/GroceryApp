//
//  Food.swift
//  Grocery
//
//  Created by Emily Mason on 1/25/19.
//  Copyright © 2019 Emily Mason. All rights reserved.
//

class Food {
    
    var id: Int
    var food: String?
    var date: String?
    
    init(id: Int, food: String?, date: String?){
        self.id = id
        self.food = food
        self.date = date
    }
}
