//
//  Category.swift
//  Todoey
//
//  Created by Nicolas Arias on 3/9/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = "#FFFFFF"
    let items = List<TodoItem>()
}
