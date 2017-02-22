//
//  BudgetListViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/20/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import CoreData

class BudgetListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{
    // sharedDelegate
    var sharedDelegate: AppDelegate!
    
    // IBOutlets
    @IBOutlet weak var composeButton: UIBarButtonItem!
    @IBOutlet var budgetTable: UITableView!
    
    // When the view initially loads set the title
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set Navbar Color
        let color = UIColor.white
        self.navigationController?.navigationBar.tintColor = color
        
        budgetTable.dataSource = self
        budgetTable.delegate = self
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SpendViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Reload table data everytime the view is about to appear
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Budgets"
        
        // Get data from CoreData
        BudgetVariables.getData()
        
        // Reload the budget table
        self.budgetTable.reloadData()
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Use this variable to enable and disable the Confirm button
    weak var confirmButton : UIAlertAction?
    
    // Function that shows the alert pop-up
    func showAlert()
    {
        let alert = UIAlertController(title: "Create a Budget", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Budget Name (Optional)"
            textField.delegate = self
            textField.autocapitalizationType = .words
        })
        
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "From $0 to $1,000,000"
            textField.keyboardType = .decimalPad
            textField.delegate = self
            textField.addTarget(self, action: #selector(self.inputAmountDidChange(_:)), for: .editingChanged)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
        })
        
        let create = UIAlertAction(title: "Create", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            var inputName = alert.textFields![0].text
            
            // Trim the inputName first
            inputName = inputName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if let inputAmount = (Double(alert.textFields![1].text!))?.roundTo(places: 2)
            {
                if inputAmount >= 0 && inputAmount <= 1000000
                {
                    if inputName == ""
                    {
                        inputName = "Untitled Budget"
                    }
                    
                    // Generate the correct name taking into account repeats
                    inputName = BudgetVariables.createName(myName: inputName!, myNum: 0)
                    
                    let context = self.sharedDelegate.persistentContainer.viewContext
                    let budget = MyBudget(context: context)
                    budget.name = inputName
                    budget.balance = inputAmount
                    budget.descriptionArray = [String]()
                    budget.historyArray = [String]()
                    budget.totalAmountSpent = 0.0
                    budget.totalBudgetAmount = inputAmount
                    budget.totalAmountAdded = 0.0
                    budget.barGraphColor = 0
                    
                    // Save and get data to coredata
                    self.sharedDelegate.saveContext()
                    BudgetVariables.getData()
                    
                    // Set the new current index and reload the table
                    BudgetVariables.currentIndex = BudgetVariables.budgetArray.count - 1
                    self.budgetTable.reloadData()
                }
            }
        })
        
        alert.addAction(create)
        alert.addAction(cancel)
        
        self.confirmButton = create
        create.isEnabled = false
        self.present(alert, animated: true, completion: nil)
    }
    
    // This function limits the maximum character count for each textField and limits the decimal places input to 2
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var maxLength = 0
        
        if textField.placeholder == "From $0 to $1,000,000"
        {
            maxLength = 10
        }
        else if textField.placeholder == "Budget Name (Optional)" || textField.placeholder == "New Name"
        {
            maxLength = 18
        }
        
        let currentString = textField.text as NSString?
        let newString = currentString?.replacingCharacters(in: range, with: string)
        let isValidLength = newString!.characters.count <= maxLength
        
        if textField.placeholder == "From $0 to $1,000,000"
        {
            // Max 2 decimal places for input using regex :D
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let regex = try! NSRegularExpression(pattern: "\\..{3,}", options: [])
            let matches = regex.matches(in: newText, options:[], range:NSMakeRange(0, newText.characters.count))
            guard matches.count == 0 else { return false }
            
            switch string
            {
            case "0","1","2","3","4","5","6","7","8","9":
                if isValidLength == true
                {
                    return true
                }
            case ".":
                let array = textField.text?.characters.map { String($0) }
                var decimalCount = 0
                for character in array!
                {
                    if character == "."
                    {
                        decimalCount += 1
                    }
                }
                if decimalCount == 1
                {
                    return false
                }
                else if isValidLength == true
                {
                    return true
                }
            default:
                let array = string.characters.map { String($0) }
                if array.count == 0
                {
                    return true
                }
                return false
            }
        }
        
        // For any other text field, return true if the length is valid
        if isValidLength == true
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // This function disables the Confirm button if the input amount is not valid
    func inputAmountDidChange(_ textField: UITextField)
    {
        // Trim the input first
        let trimmedInput = (textField.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input is a number
        if let inputAmount = Double(trimmedInput!)
        {
            // If the input is also between 0 and 1 million
            if inputAmount >= 0 && inputAmount <= 1000000
            {
                // Confirm button gets enabled
                self.confirmButton?.isEnabled = true
            }
            else
            {
                self.confirmButton?.isEnabled = false
            }
        }
        else
        {
            self.confirmButton?.isEnabled = false
        }
    }
    
    // When the compose button is pressed, show an alert pop-up
    @IBAction func composeButtonWasPressed(_ sender: AnyObject)
    {
        // Alert Pop-up
        showAlert()
    }
    
    // When the pie chart button is pressed, segue to the pie chart view
    @IBAction func pieChartButtonPressed(_ sender: AnyObject)
    {
        performSegue(withIdentifier: "showPieChart", sender: nil)
    }
    
    // If a cell is pressed, go to the corresponding budget
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "viewBudget"
        {
            // code for viewing a budget after a cell is pressed
        }
        else if segue.identifier == "showPieChart"
        {
            // code for viewing the pie chart
        }
    }
    
    // Functions that conform to UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // represents the number of rows the UITableView should have
        return BudgetVariables.budgetArray.count + 1
    }
    
    // Set the title and description of each corresponding cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell:UITableViewCell = self.budgetTable.dequeueReusableCell(withIdentifier: "clickableCell", for: indexPath)
        let count = BudgetVariables.budgetArray.count
        
        // If it's the last cell, customize the message
        if indexPath.row == count
        {
            myCell.textLabel?.textColor = UIColor.lightGray
            myCell.detailTextLabel?.textColor = UIColor.lightGray
            myCell.textLabel?.text = "Budget Name"
            myCell.detailTextLabel?.text = "Balance / Budget"
        }
        else
        {
            myCell.textLabel?.textColor = UIColor.black
            myCell.detailTextLabel?.textColor = UIColor.black
            myCell.textLabel?.text = BudgetVariables.budgetArray[indexPath.row].name
            let currentBalance = (BudgetVariables.budgetArray[indexPath.row].balance).roundTo(places: 2)
            let currentBalanceString = BudgetVariables.numFormat(myNum: currentBalance)
            let totalBudgetAmt = lround((BudgetVariables.budgetArray[indexPath.row].totalBudgetAmount))
            let totalBudgetAmtString = String(totalBudgetAmt)
            myCell.detailTextLabel?.text = currentBalanceString + " / $" + totalBudgetAmtString
        }
        
        return myCell
    }
    
    // User cannot delete the last cell which contains information
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // If it is the last cell which contains information, user cannot delete this cell
        if indexPath.row == BudgetVariables.budgetArray.count
        {
            return false
        }
        
        return true
    }
    
    // When a cell is selected segue to corresponding view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // If it is not the last row, set current index to row # of cell pressed, then segue
        if indexPath.row != BudgetVariables.budgetArray.count
        {
            BudgetVariables.currentIndex = indexPath.row
            performSegue(withIdentifier: "viewBudget", sender: nil)
        }
    }
    
    // Generates an array of custom buttons that appear after the swipe to the left
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Title is the text of the button
        let delete = UITableViewRowAction(style: .normal, title: " Delete  ")
        { (action, indexPath) in
            let budget = BudgetVariables.budgetArray[indexPath.row]
            context.delete(budget)
            self.sharedDelegate.saveContext()
            
            do
            {
                BudgetVariables.budgetArray = try context.fetch(MyBudget.fetchRequest())
            }
            catch
            {
                print("Fetching Failed")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            BudgetVariables.currentIndex = BudgetVariables.budgetArray.count - 1
            
        }
        
        // Title is the text of the button
        let rename = UITableViewRowAction(style: .normal, title: " Rename")
        { (action, indexPath) in
            self.showEditNameAlert(indexPath: indexPath)
        }
        
        // Change the color of the buttons
        // rename.backgroundColor = BudgetVariables.hexStringToUIColor(hex: "3498DB")
        rename.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        delete.backgroundColor = BudgetVariables.hexStringToUIColor(hex: "E74C3C")
        
        return [delete, rename]
    }
    
    // Use this variable to enable or disable the Save button
    weak var nameSaveButton : UIAlertAction?
    
    // Show Edit Name Pop-up
    func showEditNameAlert(indexPath: IndexPath)
    {
        let editAlert = UIAlertController(title: "Edit Budget Name", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        editAlert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "New Name"
            
            // Set the initial text to be the budget name of the row selected
            textField.text = BudgetVariables.budgetArray[indexPath.row].name
            
            textField.delegate = self
            textField.autocapitalizationType = .words
            textField.addTarget(self, action: #selector(self.newNameTextFieldDidChange(_:)), for: .editingChanged)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
        })
        
        let save = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            var inputName = editAlert.textFields![0].text
            
            // If the input name isn't empty and it isn't the old name
            if inputName != "" && inputName != BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
            {
                // Trim all extra white space and new lines
                inputName = inputName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                // Create the name with the newly trimmed String
                inputName = BudgetVariables.createName(myName: inputName!, myNum: 0)
                BudgetVariables.budgetArray[indexPath.row].name = inputName!
                self.budgetTable.reloadRows(at: [indexPath], with: .right)
            }
            
            // Save data to coredata
            self.sharedDelegate.saveContext()
            
            // Get data
            BudgetVariables.getData()
        })
        
        editAlert.addAction(save)
        editAlert.addAction(cancel)
        
        self.nameSaveButton = save
        save.isEnabled = false
        self.present(editAlert, animated: true, completion: nil)
    }
    
    // This function disables the save button if the input name is not valid
    func newNameTextFieldDidChange(_ textField: UITextField)
    {
        // Trim the input first
        let input = (textField.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input is not empty and it doesn't currently exist, enable the Save button
        if input != "" && BudgetVariables.nameExistsAlready(str: input!) == false
        {
            self.nameSaveButton?.isEnabled = true
        }
        else
        {
            self.nameSaveButton?.isEnabled = false
        }
    }
}
