//
//  HistoryViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/20/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{
    // Clean code
    var sharedDelegate: AppDelegate!
    
    // IBOutlet for components
    @IBOutlet var historyTable: UITableView!
    @IBOutlet weak var clearHistoryButton: UIBarButtonItem!
    
    // When the screen loads, display the table
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set Navbar Color
        let color = UIColor.white
        self.navigationController?.navigationBar.tintColor = color
        
        self.navigationItem.title = "History"
        historyTable.dataSource = self
        historyTable.delegate = self
        
        // If there is no history, disable the clear history button
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true
        {
            clearHistoryButton.isEnabled = false
        }
        else
        {
            clearHistoryButton.isEnabled = true
        }
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SpendViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    // Function runs everytime the screen appears
    override func viewWillAppear(_ animated: Bool)
    {
        // Make sure the table is up to date
        super.viewWillAppear(animated)
        
        // Get data from CoreData
        BudgetVariables.getData()
        
        // Reload the budget table
        self.historyTable.reloadData()
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // When the clear history button gets pressed, clear the history and disable button
    @IBAction func clearHistoryButtonWasPressed(_ sender: AnyObject)
    {
        // Empty out arrays
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray = [String]()
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray = [String]()
        
        // Revert the balance to its original value, and reset the variables
        let totalAmtAdded = BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountAdded
        let totalAmtSpent = BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountSpent
        let myBalance = BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance
        let newBalanceAndBudgetAmount = myBalance - totalAmtAdded + totalAmtSpent
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance = newBalanceAndBudgetAmount
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalBudgetAmount = newBalanceAndBudgetAmount
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountAdded = 0.0
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountSpent = 0.0

        // Zero out the spending's for this array per date and total
        for (key, _) in BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[key] = 0.0
        }
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountSpent = 0.0
        
        // Save context and get data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Reload the table and disable the clear history button
        self.historyTable.reloadData()
        clearHistoryButton.isEnabled = false
    }
    
    // Functions that conform to UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // represents the number of rows the UITableView should have
        return BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.count + 1
    }
    
    // Determines what data goes in what cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell:UITableViewCell = historyTable.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let count = BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.count
        
        // If it's the last cell, customize the message
        if indexPath.row == count
        {
            myCell.textLabel?.textColor = UIColor.lightGray
            myCell.detailTextLabel?.textColor = UIColor.lightGray
            myCell.textLabel?.text = "Swipe left to undo"
            myCell.detailTextLabel?.text = "Tap to edit"
        }
        else
        {
            myCell.textLabel?.textColor = UIColor.black
            myCell.detailTextLabel?.textColor = UIColor.black
            
            let str = BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray[indexPath.row]
            let index = str.index(str.startIndex, offsetBy: 0)
            
            if str[index] == "+"
            {
                myCell.textLabel?.textColor = BudgetVariables.hexStringToUIColor(hex: "00B22C")
            }
            
            if str[index] == "–"
            {
                myCell.textLabel?.textColor = BudgetVariables.hexStringToUIColor(hex: "FF0212")
            }
            
            myCell.textLabel?.text = BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray[indexPath.row]
            
            // String of the description
            let descripStr = BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray[indexPath.row]
            
            // Create Detail Text
            let detailText = BudgetVariables.getDetailFromDescription(descripStr: descripStr)
            
            // Create Date Text
            let dateText = BudgetVariables.createDateText(descripStr: descripStr)
                        
            // Display text
            let displayText = detailText + dateText
            myCell.detailTextLabel?.text = displayText
        }
        
        return myCell
    }
    
    // User cannot delete the last cell which contains information
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // If it is the last cell which contains information, user cannot delete this cell
        if indexPath.row == BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.count
        {
            return false
        }
        
        // Extract the amount spent for this specific transaction into the variable amountSpent
        let historyStr = BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray[indexPath.row]
        let index1 = historyStr.index(historyStr.startIndex, offsetBy: 0) // Index spans the first character in the string
        let index2 = historyStr.index(historyStr.startIndex, offsetBy: 3) // Index spans the amount spent in that transaction
        let amountSpent = Double(historyStr.substring(from: index2))
            
        // If after the deletion of a spend action the new balance is over 1M, user cannot delete this cell
        if historyStr[index1] == "–"
        {
            let newBalance = BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance + amountSpent!
            if newBalance > 1000000
            {
                return false
            }
        }
        else if historyStr[index1] == "+"
        {
            let newBalance = BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - amountSpent!
            if newBalance < 0
            {
                return false
            }
        }
        
        return true
    }
    
    // Generates an array of custom buttons that appear after the swipe to the left
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Title is the text of the button
        let undo = UITableViewRowAction(style: .normal, title: " Undo  ")
        { (action, indexPath) in
            
            // Undo item at indexPath
            
            // Extract the key to the map in the format "MM/dd/YYYY" into the variable date
            let descripStr = BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray[indexPath.row]
            let dateIndex = descripStr.index(descripStr.endIndex, offsetBy: -10)
            let date = descripStr.substring(from: dateIndex)
            
            // Extract the amount spent for this specific transaction into the variable amountSpent
            let historyStr = BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray[indexPath.row]
            let index1 = historyStr.index(historyStr.startIndex, offsetBy: 0) // Index spans the first character in the string
            let index2 = historyStr.index(historyStr.startIndex, offsetBy: 3) // Index spans the amount spent in that transaction
            let historyValue = Double(historyStr.substring(from: index2))
            
            // If this specific piece of history logged a "Spend" action, the total amount spent should decrease after deletion
            if historyStr[index1] == "–"
            {
                let newAmtSpentOnDate = BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[date]! - historyValue!
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[date] = newAmtSpentOnDate
                let newTotalAmountSpent = BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountSpent - historyValue!
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountSpent = newTotalAmountSpent
                let newBalance = BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance + historyValue!
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance = newBalance
            }
            // If this action was an "Added to Budget" action
            else if historyStr[index1] == "+"
            {
                let newTotalAmountAdded = BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountAdded - historyValue!
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountAdded = newTotalAmountAdded
                let newBalance = BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - historyValue!
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance = newBalance
                let newBudgetAmount = BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalBudgetAmount - historyValue!
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalBudgetAmount = newBudgetAmount
            }
            
            // Delete the row
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.remove(at: indexPath.row)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.sharedDelegate.saveContext()
            BudgetVariables.getData()
            
            // Disable the clear history button if the cell deleted was the last item
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true
            {
                self.clearHistoryButton.isEnabled = false
            }
            else
            {
                self.clearHistoryButton.isEnabled = true
            }
        }
        
        // Change the color of the button
        undo.backgroundColor = BudgetVariables.hexStringToUIColor(hex: "BBB7B0")
        
        return [undo]
    }
    
    // When a cell is selected, show an alert
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // If it is not the last row
        if indexPath.row != BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.count
        {
            let descripStr = BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray[indexPath.row]
            let index = descripStr.index(descripStr.endIndex, offsetBy: -14)
            self.oldDescription = descripStr.substring(to: index)
            
            showEditDescriptionAlert(indexPath: indexPath)
        }
    }
    
    // Use this variable to enable and disable the Save button
    weak var saveButton : UIAlertAction?
    
    // Shows the alert pop-up
    func showEditDescriptionAlert(indexPath: IndexPath)
    {
        let alert = UIAlertController(title: "Edit Description", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "New Description"
            
            // Grab old description and put it into the initial textfield
            let oldDescription = BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray[indexPath.row]
            textField.text = BudgetVariables.getDetailFromDescription(descripStr: oldDescription)
            
            textField.delegate = self
            textField.autocapitalizationType = .sentences
            textField.addTarget(self, action: #selector(self.inputDescriptionDidChange(_:)), for: .editingChanged)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
        })
        
        let save = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            var inputDescription = alert.textFields![0].text
            
            // Trim the inputName first
            inputDescription = inputDescription?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // Get old description
            let oldDescription = BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray[indexPath.row]
            
            // Change the current description
            let date = BudgetVariables.getDateFromDescription(descripStr: oldDescription)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray[indexPath.row] = inputDescription! + "    " + date
            self.historyTable.reloadRows(at: [indexPath], with: .fade)
            
            // Save and get data to coredata
            self.sharedDelegate.saveContext()
            BudgetVariables.getData()
                
            // Reload the table
            self.historyTable.reloadData()
        })
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        self.saveButton = save
        save.isEnabled = false
        self.present(alert, animated: true, completion: nil)
    }
    
    // Holds the old description of cell pressed
    var oldDescription: String = ""
    
    // Enable save button if the description doesn't equal current description
    func inputDescriptionDidChange(_ textField: UITextField)
    {
        let inputDescription = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if inputDescription != self.oldDescription
        {
            self.saveButton?.isEnabled = true
        }
        else
        {
            self.saveButton?.isEnabled = false
        }
    }
    
    // This function limits the maximum character count for a textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var maxLength = 0
        
        if textField.placeholder == "New Description"
        {
            maxLength = 22
        }
        
        let currentString = textField.text as NSString?
        let newString = currentString?.replacingCharacters(in: range, with: string)
        return newString!.characters.count <= maxLength
    }
}
