//
//  GroupsTableViewController.swift
//  todoeytask
//
//  Created by Sherif  Wagih on 8/24/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import CoreData
class GroupsTableViewController: UITableViewController {
    var colors = [UIColor.black, UIColor.blue,UIColor.magenta,UIColor.purple,UIColor.orange]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var allCats:[Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        loadItems()
        
        if UserDefaults.standard.string(forKey: "FirstTime") == nil
        {
            UserDefaults.standard.setValue(true, forKey: "SendNotification")
            UserDefaults.standard.setValue("no", forKey: "FirstTime")
            print("setting it to true")
        }
        if UserDefaults.standard.bool(forKey: "SendNotification")
        {
            print("schedule")
            LocalPushManager.shared.requestAuth()
            LocalPushManager.shared.sendLocalPush(in: 60)
        }
      }
    //MARK:- Core Data Manipulation Methods
    func loadItems(for request:NSFetchRequest<Category>  = Category.fetchRequest()){
        do
        {
            allCats = try context.fetch(request)
        }
        catch
        {
            showAlert(message: error.localizedDescription)
        }
    }
    func saveItems()
    {
        do
        {
            try context.save()
        }
        catch
        {
            showAlert(message: error.localizedDescription)
        }
    }
    //MARK:-Segue Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "AddNewCategory"
        {
            let dest = segue.destination as! GroupDetailsTableViewController
            dest.delegate = self
        }
        if segue.identifier == "EditCategory"
        {
            let dest = segue.destination as! GroupDetailsTableViewController
            let cellsender = (sender as! UIButton).superview?.superview
            let index = tableView.indexPath(for: (cellsender) as! UITableViewCell)
            dest.delegate = self
            dest.catItem = allCats[(index?.row)!];
        }
        if segue.identifier == "ShowTasks"
        {
            let dest = segue.destination as! Tasks
            if let index = tableView.indexPathForSelectedRow
            {
                dest.selectedCategory = allCats[index.row]
            }
        }
    }
    //Show Alert
    func showAlert(message:String)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
}
//MARK:- Conforming to group edit and add interface
extension GroupsTableViewController:categoryManipulation
{
    func editItem(item: Category) {
        if let index = allCats.index(of: item)
        {
            let indexPath = IndexPath(row: index, section: 0)
            
            if let cell = tableView.cellForRow(at: indexPath) as? CategoyCustomCell
            {
                configureCell(for:cell,item:item)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        saveItems()
    }
    
    func addItem(item: Category)
    {
        addRowToTableView(item: item)
        saveItems()
    }
    
}
//MARK:- table view methods
extension GroupsTableViewController
{
    func addRowToTableView(item:Category)
    {
        let newIndex = allCats.count
        allCats.append(item)
        let index = IndexPath(row: newIndex, section: 0)
        self.tableView.insertRows(at: [index], with: .automatic)
    }
    func configureCell(for cell:CategoyCustomCell,item:Category)
    {
        cell.titleLabel.text = item.name
        cell.backgroundColor = colors[Int(item.color)]
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoyCustomCell
        let catItem:Category  = allCats[indexPath.row]
        configureCell(for: cell, item: catItem)
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCats.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "ShowTasks", sender: self)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let index = IndexPath(row: indexPath.row, section: 0)
        context.delete(allCats[index.row])
        allCats.remove(at: index.row)
        tableView.deleteRows(at: [index] , with: .automatic)
        saveItems()
    }

}
