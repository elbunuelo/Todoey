//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var selectedCategory: Category? {
        didSet {
            //loadData()
        }
    }

    var items: Results<TodoItem>?
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        
        loadData()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist.")
            }
            
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)
                ]
            }
            
            title = selectedCategory!.name
            searchBar.barTintColor = UIColor(hexString: colorHex)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let todoItem = items?[indexPath.row] {
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.textLabel?.text = todoItem.name
            cell.accessoryType = todoItem.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Found"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print(error)
            }
            
            
            tableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        textField.placeholder = "Create new item"
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let category = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newTodo = TodoItem()
                        newTodo.name = textField.text!
                        newTodo.dateCreated = Date()
                        category.items.append(newTodo)
                    }
                } catch {
                    print(error)
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
                 textField = alertTextField
             }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion:  nil)
    }

    func loadData() {
        items = selectedCategory?.items.sorted(byKeyPath: "name", ascending: true)
    }
    
    func save(item: TodoItem) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print(error)
        }
        
        self.tableView.reloadData()
    }
    
    override func deleteItem(at indexPath: IndexPath) {
        if let item = selectedCategory?.items[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print(error)
            }
        }
    }
    

}


// MARK: - Search Bar Delegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
}
