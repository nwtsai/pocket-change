//
//  HistoryViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/20/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
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
        
        self.navigationItem.title = "My History"
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
    
    // When the clear history button gets pressed, clear the history and disable button
    @IBAction func clearHistoryButtonWasPressed(_ sender: AnyObject)
    {
        // Empty out arrays
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray = [String]()
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray = [String]()
        
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
        return BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.count
    }
    
    // Determines what data goes in what cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell:UITableViewCell = historyTable.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        
        let str = BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray[indexPath.row]
        let index = str.index(str.startIndex, offsetBy: 0)
        if str[index] == "+"
        {
            myCell.textLabel?.textColor = UIColor.green
        }
        
        if str[index] == "–"
        {
            myCell.textLabel?.textColor = UIColor.red
        }
        
        myCell.textLabel?.text = BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray[indexPath.row]
        myCell.detailTextLabel?.text = BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray[indexPath.row]
        
        return myCell
    }
    
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        // If the deleting swipe motion happens, remove the budget from the budgetArray, decrement the currentIndex, and delete the row
        if editingStyle == .delete
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.remove(at: indexPath.row)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.sharedDelegate.saveContext()
            BudgetVariables.getData()
            
            // Disable the clear history button if the cell deleted was the last item
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true
            {
                clearHistoryButton.isEnabled = false
            }
            else
            {
                clearHistoryButton.isEnabled = true
            }
        }
    }
}
