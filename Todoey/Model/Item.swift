//
//  Item.swift
//  Todoey
//
//  Created by Chase Klingel on 6/3/18.
//  Copyright © 2018 Chase Klingel. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date? 
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
