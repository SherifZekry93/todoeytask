//
//  GroupDetailsTableViewController.swift
//  todoeytask
//
//  Created by Sherif  Wagih on 8/24/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit

protocol categoryManipulation
{
    func addItem(item:Category)
    func editItem(item:Category)
}
class GroupDetailsTableViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate:categoryManipulation?
    var catItem:Category?
    var selectedColor:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isEnabled = false
        if let toEditItem = catItem
        {
            title = "Edit Task"
            doneButton.isEnabled = true;
            catName.text = toEditItem.name
            generateColors(category: toEditItem)
        }
        else
        {
            title = "Add New Task"
        }
        for view in slackViewColors.subviews
        {
            (view as! UIButton).layer.cornerRadius = (view as! UIButton).frame.size.width / 2
        }
        configureTable()
    }
    override func viewWillAppear(_ animated: Bool) {
        catName.becomeFirstResponder()
    }
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var catName: UITextField!
    @IBOutlet weak var slackViewColors: UIStackView!
    @IBAction func doneButtonPress(_ sender: Any)
    {
            if !(catName.text?.isEmpty)! || catName.text == " "
            {
                if catItem != nil
                {
                    catItem?.name = catName.text
                    if selectedColor != nil
                    {
                        catItem?.color = Int16(selectedColor!)
                    }
                    delegate?.editItem(item: catItem!)
                }
                else
                {
                    let newItem = Category(context: context)
                    newItem.name = catName.text
                    if selectedColor != nil
                    {
                        newItem.color = Int16(selectedColor!)
                    }
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
    @IBAction func colorButtonClick(_ sender: Any) {
        selectedColor = (sender as! UIButton).tag
        for view in slackViewColors.subviews
        {
            (view as! UIButton).layer.borderColor = UIColor.lightGray.cgColor
            (view as! UIButton).layer.borderWidth  = 0;
            if (sender as! UIButton).tag == (view as! UIButton).tag
            {
                (sender as! UIButton).layer.borderWidth = 5;
            }
        }
    }
    func showAlert(message:String)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    func configureTable()
    {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
    }
}
//MARK:- simple color control
extension GroupDetailsTableViewController
{
    func generateColors(category:Category)
    {
        for view in slackViewColors.subviews
        {
            if (view as! UIButton).tag == Int(category.color)
            {
                (view as! UIButton).layer.borderColor = UIColor.gray.cgColor
                (view as! UIButton).layer.borderWidth  = 5;
            }
            (view as! UIButton).layer.cornerRadius = (view as! UIButton).frame.size.width / 2
        }
    }
}
//MARK:- text field delegate
extension GroupDetailsTableViewController:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
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
        }
        else
        {
            doneButton.isEnabled = true;
        }
        return true;
    }
}
