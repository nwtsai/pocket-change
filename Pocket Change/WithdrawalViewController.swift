//
//  WithdrawalViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/20/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit

class WithdrawalViewController: UIViewController, UITextFieldDelegate
{
    // sharedDelegate
    var sharedDelegate: AppDelegate!
    
    // IB Outlets
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var depositButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var inputAmount: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    
    // Buttons get initially enabled or disabled based on conditions
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        // Set Navbar Color
        let color = UIColor.white
        self.navigationController?.navigationBar.tintColor = color
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WithdrawalViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Syncs labels with global variables
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Get data from CoreData
        BudgetVariables.getData()
        
        // Set Navbar title and other labels
        self.navigationItem.title = BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
        totalBalance.text = "$" + BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance == 0
        {
            withdrawButton.isEnabled = false
        }
        
        // Reset the text fields and disable both buttons
        inputAmount.text = ""
        descriptionText.text = ""
        depositButton.isEnabled = false
        withdrawButton.isEnabled = false
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // When the action button in the navbar gets pressed
    @IBAction func actionButtonPressed(_ sender: AnyObject)
    {
        showEditAlert()
    }
    // Use this variable to enable or disable the Save button
    weak var saveButton : UIAlertAction?
    
    // Show Edit Pop-up
    func showEditAlert()
    {
        let editAlert = UIAlertController(title: "Edit Name", message: "", preferredStyle: UIAlertControllerStyle.alert)
        editAlert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Enter New Budget Name"
            textField.delegate = self
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (_) -> Void in
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
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].name = inputName!
                self.navigationItem.title = BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
                
                // Save data to coredata
                self.sharedDelegate.saveContext()
                
                // Get data
                BudgetVariables.getData()
            }
        })
        
        editAlert.addAction(save)
        editAlert.addAction(cancel)
        
        self.saveButton = save
        save.isEnabled = false
        self.present(editAlert, animated: true, completion: nil)
    }
    
    // This function disables the save button if the input amount is not valid
    func textFieldDidChange(_ textField: UITextField)
    {
        // Trim the input first
        let input = (textField.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input is not empty and it doesn't currently exist, enable the Save button
        if input != "" && BudgetVariables.nameExistsAlready(str: input!) == false
        {
            self.saveButton?.isEnabled = true
        }
        else
        {
            self.saveButton?.isEnabled = false
        }
    }
    
    // This function gets called when the Deposit button is pressed
    @IBAction func depositButtonWasPressed(_ sender: AnyObject)
    {
        // Get current date, append to historyArray
        let date = BudgetVariables.todaysDate(format: "MM/dd")
        
        // Trim input first
        let trimmedInput = (inputAmount.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input amount is a number
        if let input = Double(trimmedInput!)
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance += input
            totalBalance.text = "$" + BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.append("+ $" + String(format: "%.2f", input))
            
            // Trim description text before appending
            let description = (descriptionText.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.append(description! + "    " + date)
            
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input >= 0
            {
                withdrawButton.isEnabled = true
            }
            
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance + input > 1000000
            {
                depositButton.isEnabled = false
            }
        }
        else
        {
            // Our amountEnteredChanged should take into account all non-Number cases and 
            // disable this button before it can be pressed
            totalBalance.text = "If this message is seen check func amountEnteredChanged"
        }
        
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        historyButton.isEnabled = true
    }
    
    // This function gets called when the Withdraw button is pressed
    @IBAction func withdrawButtonWasPressed(_ sender: AnyObject)
    {
        // Get current date, append to history Array
        let date = BudgetVariables.todaysDate(format: "MM/dd")
        
        // Trim input first
        let trimmedInput = (inputAmount.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input amount is a number
        if let input = Double(trimmedInput!)
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance -= input
            totalBalance.text = "$" + BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.append("– $" + String(format: "%.2f", input))
            
            // Trim description text before appending
            let description = (descriptionText.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.append(description! + "    " + date)
            
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input < 0
            {
                withdrawButton.isEnabled = false
            }
            
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance + input <= 1000000
            {
                depositButton.isEnabled = true
            }
        }
        else
        {
            // Our amountEnteredChanged should take into account all non-Number cases and
            // disable this button before it can be pressed
            totalBalance.text = "If this message is seen check func amountEnteredChanged"
        }
        
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        historyButton.isEnabled = true
    }
    
    // This function dynamically configures button availability depending on input
    @IBAction func amountEnteredChanged(_ sender: AnyObject)
    {
        // Trim input first
        let trimmedInput = (inputAmount.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input is empty, show current balance and disable buttons
        // Else if the input is a number and isn't empty, calculate whether or not to disable or enable the buttons
        // Else if the input is not a number and isn't empty, disable buttons and print error statement
        if trimmedInput == ""
        {
            totalBalance.text = "$" + BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            depositButton.isEnabled = false
            withdrawButton.isEnabled = false
        }
        else if trimmedInput == "-" || trimmedInput == "-."
        {
            totalBalance.text = "Must be positive"
            withdrawButton.isEnabled = false
            depositButton.isEnabled = false
        }
        else if trimmedInput == "."
        {
            totalBalance.text = "$" + BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            withdrawButton.isEnabled = false
            depositButton.isEnabled = false
        }
        else if let input = Double(trimmedInput!)
        {
            // Print error statement if input exceeeds 1 million
            if input > 1000000
            {
                totalBalance.text = "Must be under $1M"
                withdrawButton.isEnabled = false
                depositButton.isEnabled = false
            }
            else if input < 0
            {
                depositButton.isEnabled = false
                withdrawButton.isEnabled = false
                totalBalance.text = "Must be positive"
            }
            else
            {
                totalBalance.text = "$" + BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
                if input == 0
                {
                    depositButton.isEnabled = false
                    withdrawButton.isEnabled = false
                }
                else
                {
                    if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance + input > 1000000
                    {
                        depositButton.isEnabled = false
                    }
                    else
                    {
                        depositButton.isEnabled = true
                    }
                    
                    if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input < 0
                    {
                        withdrawButton.isEnabled = false
                    }
                    else
                    {
                        withdrawButton.isEnabled = true
                    }
                }
            }
        }
        else
        {
            depositButton.isEnabled = false
            withdrawButton.isEnabled = false
            totalBalance.text = "Numbers only"
        }
    }
    
    // When the history button gets pressed segue to the HistoryViewController file
    @IBAction func historyButtonPressed(_ sender: AnyObject)
    {
        performSegue(withIdentifier: "showHistory", sender: nil)
    }
}

