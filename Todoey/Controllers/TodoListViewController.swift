//
//  ViewController.swift
//  Todoey
//
//  Created by Chase Klingel on 5/28/18.
//  Copyright © 2018 Chase Klingel. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
           loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // gets location of sqlLite db
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.backgroundColor else { fatalError() }
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Controller does not exist.") }
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    //MARK: - Tableview Datasouce methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let bColor = UIColor(hexString: selectedCategory!.backgroundColor)?
                .darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = bColor
                cell.textLabel?.textColor = ContrastColorOf(bColor, returnFlat: true)
            } else {
                if let defaultBackground = UIColor(hexString: "006699")!
                    .darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                        cell.backgroundColor = defaultBackground
                        cell.textLabel?.textColor = ContrastColorOf(defaultBackground, returnFlat: true)
                }
            }
        
            cell.accessoryType = (item.done == true) ? .checkmark : .none
        }
        else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                   item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if (textField.text! != "") {
                self.saveItem(item: textField.text!)
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: false)
        tableView.reloadData()
    }
    
    func saveItem(item: String) {
        if let currentCategory = self.selectedCategory {
            do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = item
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                }
            } catch {
                print("save item error: \(error)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func deleteRecord(at indexPath: IndexPath) {
        do {
            try realm.write {
                if let itemForDeletion = todoItems?[indexPath.row] {
                    realm.delete(itemForDeletion)
                }
            }
        } catch {
            print("delete item error: \(error)")
        }
    }
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0) {
            loadItems()

            // DispatchQueue : object that manages the execution of work items
            DispatchQueue.main.async {
                // ask search bar to remove cursor / remove keyboard
                searchBar.resignFirstResponder()
            }
        }
    }

}



