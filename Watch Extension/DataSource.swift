//
//  DataSource.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 2/4/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

struct DataSource {
    
    let item: Item
    
    enum Item {
        case food(String)
        case unknown
    }
    
    init(data: [String : AnyObject]) {
        if let foodItem = data["food"] as? String {
            item = Item.food(foodItem)
        } else {
            item = Item.unknown
        }
    }
}
