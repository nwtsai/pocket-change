//
//  BudgetListViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/20/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import CoreData

// Rounds doubles to a certain number of decimal places
extension Double
{
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

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
        
        self.navigationItem.title = "My Budgets"
        budgetTable.dataSource = self
        budgetTable.delegate = self
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WithdrawalViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Reload table data everytime the view is about to appear
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
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
    
    // Use this variable to enable and disable the Save button
    weak var confirmButton : UIAlertAction?
    
    // Function that shows the alert pop-up
    func showAlert()
    {
        let alert = UIAlertController(title: "Create a Budget", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Enter Budget Name (Optional)"
            textField.delegate = self
        })
        
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Amount from $0 to $1,000,000"
            textField.keyboardType = .decimalPad
            textField.delegate = self
            textField.addTarget(self, action: #selector(self.inputAmountDidChange(_:)), for: .editingChanged)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (_) -> Void in
        })
        
        let confirm = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            var inputName = alert.textFields![0].text
            
            // Trim the inputName first
            inputName = inputName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if let inputAmount = Double(alert.textFields![1].text!)
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
                    budget.netTotalAmountSpent = 0.0
                    
                    // Save and get data to coredata
                    self.sharedDelegate.saveContext()
                    BudgetVariables.getData()
                    
                    // Set the new current index and reload the table
                    BudgetVariables.currentIndex = BudgetVariables.budgetArray.count - 1
                    self.budgetTable.reloadData()
                }
            }
        })
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        self.confirmButton = confirm
        confirm.isEnabled = false
        self.present(alert, animated: true, completion: nil)
    }
    
    // This function limits the maximum character count for each textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var maxLength = 0
        if textField.placeholder == "Enter Budget Name (Optional)"
        {
            maxLength = 18
        }
        else if textField.placeholder == "Amount from $0 to $1,000,000"
        {
            maxLength = 10
        }
        
        let currentString = textField.text as NSString?
        let newString = currentString?.replacingCharacters(in: range, with: string)
        return newString!.characters.count <= maxLength
    }
    
    // This function disables the save button if the input amount is not valid
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
                // Save button gets enabled
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
        return BudgetVariables.budgetArray.count
    }
    
    // Set the title and description of each corresponding cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell:UITableViewCell = self.budgetTable.dequeueReusableCell(withIdentifier: "clickableCell", for: indexPath)
        myCell.textLabel?.text = BudgetVariables.budgetArray[indexPath.row].name
        myCell.detailTextLabel?.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[indexPath.row].balance)
        
        return myCell
    }
    
    // When a cell is selected segue to corresponding view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Set current index to row # of cell pressed, then segue
        BudgetVariables.currentIndex = indexPath.row
        performSegue(withIdentifier: "viewBudget", sender: nil)
    }
    
    // This handles the delete functionality
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // If the deleting swipe motion happens, remove the budget from the budgetArray, decrement the currentIndex, and delete the row
        if editingStyle == .delete
        {
            let budget = BudgetVariables.budgetArray[indexPath.row]
            context.delete(budget)
            sharedDelegate.saveContext()
            
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
    }
}
