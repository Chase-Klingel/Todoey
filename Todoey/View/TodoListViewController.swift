//
//  ViewController.swift
//  Todoey
//
//  Created by Chase Klingel on 5/28/18.
//  Copyright © 2018 Chase Klingel. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    /* 1. tapping into UIApplication class
     2. getting the shared singleton object which corresponds to the current application as an OBJECT
     3. tapping into the current apps delegate (of type optional UIApplicationDelegate)
     4. casting the current apps delegate into our class AppDelegate -- perfectly fine b/c AppDelegate is a subclass of UIApplicationDelegate
     */
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // gets location of sqlLite db
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        print("entering view did load")
        loadItems()
    }
    
    //MARK - Tableview Datasouce methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(itemArray.count)
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]

        cell.textLabel?.text = item.title
        cell.accessoryType = (item.done == true) ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)

        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if (textField.text! != "") {
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                self.itemArray.append(newItem)
                
                self.saveItems()
                
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do {
           try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}

