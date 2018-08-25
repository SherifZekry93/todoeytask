//
//  TaskDetailsTableViewController.swift
//  todoeytask
//
//  Created by Sherif  Wagih on 8/23/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import CoreData
import  IQKeyboardManagerSwift
//MARK:- Interface Implementation
protocol taskManipulation
{
    func addItem(item:ToDoItem)
    func editItem(item:ToDoItem)
}

class TaskDetailsTableViewController: UITableViewController
{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate:taskManipulation?
    var toDoItem:ToDoItem?
    var selectedCategory:Category?
    var datePickerValueChanged:Bool = false;
    let dateFormatter = DateFormatter()
    var selectedColor:Int?
    var allCats:[Category]  = []
    var selectedDate:String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadCategories()
        dateFormatter.dateFormat = "dd MMM yyyy"
        datePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        taskName.delegate = self;
        doneButton.isEnabled = false
        for view in slackViewColors.subviews
        {
            (view as! UIButton).layer.cornerRadius = (view as! UIButton).frame.size.width / 2
        }
        if let toEditItem = toDoItem
        {
            title = "Edit Task"
            doneButton.isEnabled = true;
            taskName.text = toEditItem.item
            setColors(category: toEditItem.category!)
            
            if toEditItem.date != nil
            {
                datePicker.date = dateFormatter.date(from: toEditItem.date!)!
                let index = allCats.index(of: toEditItem.category!)
                pickerView.selectRow(index!, inComponent: 0, animated: false)
            }
        }
        else
        {
            if let index = allCats.index(of: selectedCategory!)
            {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
            setColors(category: selectedCategory!)
            title = "Add New Task"
        }
        
    }
    @objc func datePickerChanged(picker: UIDatePicker) {
        datePickerValueChanged = true;
    }
    override func viewWillAppear(_ animated: Bool) {
        taskName.becomeFirstResponder()
    }
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var slackViewColors: UIStackView!
    @IBAction func doneButtonPress(_ sender: Any)
    {
        if datePickerValueChanged
        {
            if datePicker.date.timeIntervalSinceNow.sign == .plus
            {
                selectedDate = dateFormatter.string(from: datePicker.date)
                addOrEditItem()
            }
            else
            {
                showAlert(message: "Date Can't be in the past!")
            }
        }
        else
        {
            addOrEditItem()
        }
    }
    func addOrEditItem()
    {
        if !(taskName.text!.isEmpty) || taskName.text != " "
        {
            if toDoItem != nil
            {
                toDoItem?.item = taskName.text
                if let date = selectedDate
                {
                    toDoItem?.date = date
                }
                toDoItem?.category = selectedCategory;
                delegate?.editItem(item: toDoItem!)
            }
            else
            {
                let newItem = ToDoItem(context: context)
                newItem.item = taskName.text
                newItem.checked = false
                if let date = selectedDate
                {
                    newItem.date = date
                }
                newItem.category = selectedCategory;
                delegate?.addItem(item: newItem)
            }
            navigationController?.popViewController(animated: true)
        }
        else
        {
            showAlert(message: "Must Enter To Do Item Name!")
        }
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    //to be shared globally
    func showAlert(message:String)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    func loadCategories(for request:NSFetchRequest<Category>  = Category.fetchRequest()){
        do
        {
            allCats = try context.fetch(request)
        }
        catch
        {
            showAlert(message: error.localizedDescription)
        }
    }
}
//MARK:- Text Fiekd Delegate Methods
extension TaskDetailsTableViewController:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range,in:oldText)
        let newText = oldText.replacingCharacters(in: stringRange!, with: string)
        if range.location == 0 && string == " "
        {
            return false;
        }
        if newText.isEmpty
        {
            doneButton.isEnabled = false;
            textField.keyboardToolbar.doneBarButton.isEnabled = false;
        }
        else
        {
            doneButton.isEnabled = true;
        }
        return true;
    }
}

//MARK:- uipicker view delegate methods
extension TaskDetailsTableViewController:
    UIPickerViewDelegate,UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return allCats.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allCats[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = allCats[row]
        clearBorders()
        setColors(category: selectedCategory!)
    }
}
//MARK:- color picker methods
extension TaskDetailsTableViewController
{
    func clearBorders()
    {
        for view in slackViewColors.subviews
        {
            (view as! UIButton).layer.borderWidth = 0;
        }
    }
    func setColors(category:Category)
    {
        for view in slackViewColors.subviews
        {
            if (view as! UIButton).tag == Int((category.color))
            {
                (view as! UIButton).layer.borderColor = UIColor.gray.cgColor
                (view as! UIButton).layer.borderWidth  = 5;
            }
        }
        
    }
}
