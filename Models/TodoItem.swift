//
//  TodoItem.swift
//  Todoey
//
//  Created by Nicolas Arias on 3/9/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var category = LinkingObjects(fromType: Category.self, property: "items")
}
