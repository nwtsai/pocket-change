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
        
        self.navigationItem.title = "My Budgets"
        budgetTable.dataSource = self
        budgetTable.delegate = self
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
    }
    
    // Reload table data everytime the view is about to appear
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Get data from CoreData
        getData()
        
        // Reload the budget table
        self.budgetTable.reloadData()        
    }
    
    // Use this variable to enable and disable the Save button
    weak var saveButton : UIAlertAction?
    
    // Function that shows the alert pop-up
    func showAlert()
    {
        let alert = UIAlertController(title: "Create a Budget", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Enter Budget Name (Optional)"
        })
        
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "Amount from $0 to $1,000,000"
            textField.keyboardType = .decimalPad
            textField.delegate = self
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (_) -> Void in
        })
        
        let save = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            var inputName = alert.textFields![0].text
            if let inputAmount = Double(alert.textFields![1].text!)
            {
                if inputAmount >= 0 && inputAmount <= 1000000
                {
                    if inputName == ""
                    {
                        inputName = "Untitled Budget"
                    }
                    // let budget = BudgetVariables(budgetName: inputName!, myBalance: inputAmount, historyArray: [String](), descriptionArray: [String]())
                    // BudgetVariables.budgetArray.append(budget)
                    
                    let context = self.sharedDelegate.persistentContainer.viewContext
                    let budget = MyBudget(context: context)
                    budget.name = inputName
                    budget.balance = inputAmount
                    budget.descriptionArray = [String]()
                    budget.historyArray = [String]()
                    
                    // Save data to coredata
                    self.sharedDelegate.saveContext()
                    
                    // Get data and reload the GroceryTable everytime confirm button is pressed
                    self.getData()
                    
                    // Increment current index and reload the table
                    BudgetVariables.currentIndex += 1
                    self.budgetTable.reloadData()
                }
            }
        })
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        self.saveButton = save
        save.isEnabled = false
        self.present(alert, animated: true, completion: nil)
    }
    
    // This function disables the save button if the input amount is not valid
    func textFieldDidChange(_ textField: UITextField)
    {
        // If the input is a number
        if let inputAmount = Double(textField.text!)
        {
            // If the input is also between 0 and 1 million
            if inputAmount >= 0 && inputAmount <= 1000000
            {
                // Save button gets enabled
                self.saveButton?.isEnabled = true
            }
            else
            {
                self.saveButton?.isEnabled = false
            }
        }
        else
        {
            self.saveButton?.isEnabled = false
        }
    }
    
    // When the compose button is pressed, show an alert pop-up
    @IBAction func composeButtonWasPressed(_ sender: AnyObject)
    {
        // Alert Pop-up
        showAlert()
    }
    
    // If a cell is pressed, go to the corresponding budget
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "viewBudget"
        {
            // code for viewing a budget after a cell is pressed
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
        myCell.detailTextLabel?.text = "Balance: $" + numFormat(myNum: BudgetVariables.budgetArray[indexPath.row].balance)
        // myCell.imageView?.image = UIImage(named: historyArray)
        
        return myCell
    }
    
    // When a cell is selected segue to corresponding view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        BudgetVariables.currentIndex = indexPath.row
        performSegue(withIdentifier: "viewBudget", sender: composeButton)
    }
    
    // This handles the delete functionality
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // If the deleting swipe motion happens, remove the budget from the budgetArray, decrement the currentIndex, and delete the row
        if editingStyle == .delete
        {
            BudgetVariables.currentIndex -= 1
            
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
