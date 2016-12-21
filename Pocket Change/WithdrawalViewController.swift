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
    }
    
    // Syncs labels with global variables
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Get data from CoreData
        getData()
        
        // Set Navbar title and other labels
        self.navigationItem.title = BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
        totalBalance.text = "Balance: $" + numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
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
            let inputName = editAlert.textFields![0].text
            if inputName != "" && inputName != BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
            {
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].name = inputName!
                self.navigationItem.title = BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
                
                // Save data to coredata
                self.sharedDelegate.saveContext()
                
                // Get data
                self.getData()
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
        // If the input is not empty and not the old name
        if textField.text != "" && textField.text != BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
        {
            self.saveButton?.isEnabled = true
        }
        else
        {
            self.saveButton?.isEnabled = false
        }
    }
    
    // Deposit button was pressed
    @IBAction func depositButtonWasPressed(_ sender: AnyObject)
    {
        if let input = Double(inputAmount.text!)
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance += input
            totalBalance.text = "Balance: $" + numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.append("+ $" + String(format: "%.2f", input))
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.append(descriptionText.text!)
            
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input >= 0
            {
                withdrawButton.isEnabled = true
            }
        }
        else
        {
            totalBalance.text = "Only numbers are valid."
        }
        
        self.sharedDelegate.saveContext()
        self.getData()
        historyButton.isEnabled = true
    }
    
    // This function gets called when the Withdraw button is pressed
    @IBAction func withdrawButtonWasPressed(_ sender: AnyObject)
    {
        if let input = Double(inputAmount.text!)
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance -= input
            totalBalance.text = "Balance: $" + numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.append("– $" + String(format: "%.2f", input))
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.append(descriptionText.text!)
            
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input < 0
            {
                withdrawButton.isEnabled = false
            }
        }
        else
        {
            totalBalance.text = "Only numbers are valid."
        }
        
        self.sharedDelegate.saveContext()
        self.getData()
        historyButton.isEnabled = true
    }
    
    // This function dynamically configures button availability depending on input
    @IBAction func amountEnteredChanged(_ sender: AnyObject)
    {
        // If the input is empty, show current balance and disable buttons
        // Else if the input is a number and isn't empty, calculate whether or not to disable or enable the buttons
        // Else if the input is not a number and isn't empty, disable buttons and print error statement
        if inputAmount.text == ""
        {
            totalBalance.text = "Balance: $" + numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            depositButton.isEnabled = false
            withdrawButton.isEnabled = false
        }
        else if inputAmount.text == "-"
        {
            totalBalance.text = "Amount must be positive."
        }
        else if let input = Double(inputAmount.text!)
        {
            // Print error statement if input exceeeds 1 million
            if input > 1000000
            {
                totalBalance.text = "Cannot exceed $1,000,000"
                withdrawButton.isEnabled = false
                depositButton.isEnabled = false
            }
            else if input < 0
            {
                depositButton.isEnabled = false
                withdrawButton.isEnabled = false
                totalBalance.text = "Amount must be positive."
            }
            else
            {
                totalBalance.text = "Balance: $" + numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
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
            totalBalance.text = "Only numbers are valid."
        }
    }
    
    // If we don't need commas, return number as double precision
    // If we do need commas, return number as regular precision unless adding precision is more accurate
    // For instance myNum = 999 returns 999.00 and myNum = 1000 becomes 1,000
    // This saves screen space unless we need more space to be more precise
    func numFormat(myNum: Double) -> String
    {
        let temp = String(format: "%.2f", myNum)
        if myNum < 1000
        {
            return temp
        }
        else
        {
            let largeNumber = Double(temp)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            return numberFormatter.string(from: NSNumber(value: largeNumber!))!
        }
    }
    
    // When the history button gets pressed segue to the HistoryViewController file
    @IBAction func historyButtonPressed(_ sender: AnyObject)
    {
        performSegue(withIdentifier: "showHistory", sender: inputAmount.text)
    }
    
    // This function fetches from coredata
    func getData()
    {
        let context = sharedDelegate.persistentContainer.viewContext
        
        do
        {
            BudgetVariables.budgetArray = try context.fetch(MyBudget.fetchRequest())
        }
        catch
        {
            print("Fetching Failed")
        }
    }
}

