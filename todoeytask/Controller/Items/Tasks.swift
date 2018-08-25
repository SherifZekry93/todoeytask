//
//  ViewController.swift
//  todoeytask
//
//  Created by Sherif  Wagih on 8/22/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import CoreData
class Tasks: UITableViewController
{
    var colors = [UIColor.black, UIColor.blue,UIColor.magenta,UIColor.purple,UIColor.orange]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todoItems :[ToDoItem] = []
    var selectedCategory:Category?
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        loadItems()
        tableView.reloadData()
        title = selectedCategory?.name
    }
    //MARK:- Segue Methods
    @IBAction func AddItem(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "AddNewTask", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "AddNewTask"
        {
            let dest = segue.destination as! TaskDetailsTableViewController
            dest.selectedCategory = selectedCategory;
            dest.delegate = self
        }
        if segue.identifier == "EditTask"
        {
            
            let dest = segue.destination as! TaskDetailsTableViewController
            let index = tableView.indexPath(for: sender as! UITableViewCell)
            dest.delegate = self
            dest.selectedCategory = selectedCategory;
            dest.toDoItem = todoItems[(index?.row)!];
            
        }
        
    }
    //MARK:- Core Data Manipulation Methods
    func saveData()
    {
        do
        {
            try context.save()
        }
        catch
        {
            print("Error Encoding Item Arrau\(error)")
        }
    }
    func loadItems(for request:NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(),predicate:NSPredicate? = nil)
    {
        let categoryPredicate = NSPredicate(format: "category.name MATCHES %@", (selectedCategory?.name)!)
        if let additionalPredicate = predicate
        {
            request.predicate =  NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }
        else
        {
            request.predicate = categoryPredicate
        }
        do
        {
            todoItems = try! context.fetch(request)
        }
    }
}

//MARK:- interface for data transfer methods
extension Tasks : taskManipulation
{
    func editItem(item: ToDoItem, deleteItem: Bool) {
        if deleteItem == false
        {
            if let index = todoItems.index(of: item)
            {
                let indexPath = IndexPath(row: index, section: 0)
                
                if let cell = tableView.cellForRow(at: indexPath) as? ToDoItemCustomCell
                {
                    configureCell(for:cell,item:item)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        else
        {
            
            if let index = todoItems.index(of: item)
            {
                let indexPath = IndexPath(row: index, section: 0)
                context.delete(todoItems[indexPath.row])
                todoItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath] , with: .automatic)
                saveData()
            }
        }
    }
    
    func addItem(item: ToDoItem)
    {
        addRowToTableView(item: item)
    }
    
}
//MARK:- table view methods
extension Tasks
{
    func addRowToTableView(item:ToDoItem)
    {
        let newIndex = self.todoItems.count
        self.todoItems.append(item)//(ToDoItem(title: itemName.text!, done: false))
        let index = IndexPath(row: newIndex, section: 0)
        self.tableView.insertRows(at: [index], with: .automatic)
    }
    func configureCell(for cell:ToDoItemCustomCell,item:ToDoItem)
    {
        cell.tintColor = UIColor.white
        cell.titleLabel.text = item.item
        cell.checkBoxLabel.text = item.checked ? "√" : ""
        if let date = item.date
        {
            cell.dateLabel.text = "\(date)"
        }
        else
        {
            cell.dateLabel.text = ""
        }
        cell.checkBoxLabel.text = item.checked ? "√" : ""
        saveData();
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell") as! ToDoItemCustomCell
        let toDoItem:ToDoItem = todoItems[indexPath.row]
        cell.backgroundColor = colors[Int((toDoItem.category?.color)!)]
        configureCell(for: cell, item: toDoItem)
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! ToDoItemCustomCell
        let toDoItem:ToDoItem = todoItems[indexPath.row]
        toDoItem.checked = !toDoItem.checked
        cell.checkBoxLabel.text = toDoItem.checked ? "√" : ""
        saveData();
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let index = IndexPath(row: indexPath.row, section: 0)
        context.delete(todoItems[index.row])
        todoItems.remove(at: index.row)
        tableView.deleteRows(at: [index] , with: .automatic)
        saveData()
    }
}
//MARK:- Search Bar Functions
extension Tasks:UISearchBarDelegate
{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        let request:NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let predicate = NSPredicate(format: "item CONTAINS[cd] %@",searchBar.text!);
        let sortDescriptor = NSSortDescriptor(key: "item", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        loadItems(for: request,predicate:   predicate)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        if searchBar.text?.count == 0
        {
            loadItems()
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
}
