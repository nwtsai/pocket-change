//
//  SpendViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/20/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import CoreData

class SpendViewController: UIViewController, UITextFieldDelegate
{
    // sharedDelegate
    var sharedDelegate: AppDelegate!
    
    // IB Outlets
    @IBOutlet weak var spendButton: UIButton!
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
        
        // Set textField delegates to themselves
        inputAmount.delegate = self
        descriptionText.delegate = self
        
        // Set placeholder text for each textfield
        inputAmount.placeholder = "$0.00"
        descriptionText.placeholder = "What's it for?"
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SpendViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Syncs labels with global variables
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Save context and get data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Set Navbar title and other labels
        self.navigationItem.title = BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
        totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance == 0
        {
            spendButton.isEnabled = false
        }
        
        // Reset the text fields and disable both buttons
        inputAmount.text = ""
        descriptionText.text = ""
        spendButton.isEnabled = false
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // When the add to budget balance button is pressed
    @IBAction func addToBudgetButtonPressed(_ sender: Any)
    {
        showEditBalanceAlert()
    }
    // Use this variable to enable or disable the Save button
    weak var amountSaveButton : UIAlertAction?
    
    // Show Edit Balance Pop-up
    func showEditBalanceAlert()
    {
        let budgetName = BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
        let editAlert = UIAlertController(title: "Add to " + budgetName!, message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        editAlert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "$0.00"
            textField.delegate = self
            textField.keyboardType = .decimalPad
            textField.addTarget(self, action: #selector(self.newAmountTextFieldDidChange(_:)), for: .editingChanged)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
        })
        
        let add = UIAlertAction(title: "Add", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            
            let date = BudgetVariables.todaysDate(format: "MM/dd/YYYY")
            
            // Trim the input Amount
            let inputAmountText = (editAlert.textFields![0].text!).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let inputAmountNum = (Double(inputAmountText))?.roundTo(places: 2)
            
            // If the input amount isn't empty and the new balance doesn't exceed 1M
            let myBalance = BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance
            if inputAmountText != "" && (inputAmountNum! + myBalance) <= 1000000
            {
                // Update balance and balance label
                let newBalance = myBalance + inputAmountNum!
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance = newBalance
                self.totalBalance.text = BudgetVariables.numFormat(myNum: newBalance)
                
                // Log this into the history and description arrays, and then update the totalAmountAdded and totalBudgetAmount
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.append("+ $" + String(format: "%.2f", inputAmountNum!))
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.append("Added to budget" + "    " + date)
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountAdded += inputAmountNum!
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalBudgetAmount += inputAmountNum!
            }
            
            // Save data to coredata
            self.sharedDelegate.saveContext()
            
            // Get data
            BudgetVariables.getData()
        })
        
        editAlert.addAction(add)
        editAlert.addAction(cancel)
        
        self.amountSaveButton = add
        add.isEnabled = false
        self.present(editAlert, animated: true, completion: nil)
    }
    
    // This function disables the save button if the input amount is not valid
    func newAmountTextFieldDidChange(_ textField: UITextField)
    {
        // Trim input first
        let trimmedInput = (textField.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let balance = BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance
        
        // Disable button if input is empty or just a "."
        if trimmedInput == "" || trimmedInput == "."
        {
            self.amountSaveButton?.isEnabled = false
        }
        // If the input is a number
        else if let input = (Double(trimmedInput!))?.roundTo(places: 2)
        {
            if input + balance <= 1000000 && input != 0.00
            {
                self.amountSaveButton?.isEnabled = true
            }
            else
            {
                self.amountSaveButton?.isEnabled = false
            }
        }
        // If the input is not a number
        else
        {
            self.amountSaveButton?.isEnabled = false
        }
    }
    
    // This function limits the maximum character count for each textField and limits the decimal places input to 2
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var maxLength = 0
        
        if textField.placeholder == "$0.00"
        {
            maxLength = 10
        }
        else if textField.placeholder == "What's it for?"
        {
            maxLength = 22
        }
        
        let currentString = textField.text as NSString?
        let newString = currentString?.replacingCharacters(in: range, with: string)
        let isValidLength = newString!.characters.count <= maxLength
        
        if textField.placeholder == "$0.00"
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
    
    // This function gets called when the Spend button is pressed
    @IBAction func spendButtonPressed(_ sender: Any)
    {
        // Get current date, append to history Array
        let date = BudgetVariables.todaysDate(format: "MM/dd/YYYY")
        
        // Trim input first
        let trimmedInput = (inputAmount.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input amount is a number, round the input to two decimal places before doing further calculations
        if let input = (Double(trimmedInput!))?.roundTo(places: 2)
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance -= input
            totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.append("– $" + String(format: "%.2f", input))
            
            // Trim description text before appending
            let description = (descriptionText.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.append(description! + "    " + date)
            
            // Log the amount withdrawn for today's spendings for this specific budget
            BudgetVariables.logTodaysSpendings(num: input)
            
            // Log the total amount spent for this budget
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountSpent += input
            
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input < 0
            {
                spendButton.isEnabled = false
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
            totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            spendButton.isEnabled = false
        }
        else if trimmedInput == "-" || trimmedInput == "-."
        {
            totalBalance.text = "Must be positive"
            spendButton.isEnabled = false
        }
        else if trimmedInput == "."
        {
            totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            spendButton.isEnabled = false
        }
        else if let input = (Double(trimmedInput!))?.roundTo(places: 2)
        {
            // Print error statement if input exceeeds 1 million
            if input > 1000000
            {
                totalBalance.text = "Must be under $1M"
                spendButton.isEnabled = false
            }
            else if input < 0
            {
                spendButton.isEnabled = false
                totalBalance.text = "Must be positive"
            }
            else
            {
                totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
                if input == 0
                {
                    spendButton.isEnabled = false
                }
                else
                {
                    if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input < 0
                    {
                        spendButton.isEnabled = false
                    }
                    else
                    {
                        spendButton.isEnabled = true
                    }
                }
            }
        }
        else
        {
            spendButton.isEnabled = false
            totalBalance.text = "Numbers only"
        }
    }
    
    // When the Daily button gets pressed segue to the BarGraphViewController file
    @IBAction func dailyButtonWasPressed(_ sender: AnyObject)
    {
        // Save context and get data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        performSegue(withIdentifier: "showDaily", sender: nil)
    }
    
    // When the Weekly button gets pressed segue to the HistoryViewController file
    @IBAction func weeklyButtonWasPressed(_ sender: AnyObject)
    {
        // Save context and get data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        performSegue(withIdentifier: "showBarGraph", sender: nil)
    }
}

