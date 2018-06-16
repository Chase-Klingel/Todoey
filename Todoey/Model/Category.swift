//
//  Category.swift
//  Todoey
//
//  Created by Chase Klingel on 6/3/18.
//  Copyright © 2018 Chase Klingel. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var backgroundColor: String = ""
    let items = List<Item>()
}
