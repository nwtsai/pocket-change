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
    // sharedDelegate
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        // Make sure the table is up to date
        super.viewWillAppear(animated)
        
        // Get data from CoreData
        getData()
        
        // Reload the budget table
        self.historyTable.reloadData()
    }
    
    // When the clear history button gets pressed, clear the history and disable button
    @IBAction func clearHistoryButtonWasPressed(_ sender: AnyObject)
    {
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray = [String]()
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray = [String]()
        self.sharedDelegate.saveContext()
        self.getData()
        self.historyTable.reloadData()
        clearHistoryButton.isEnabled = false
    }
    
    // Functions that conform to UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell:UITableViewCell = historyTable.dequeueReusableCell(withIdentifier: "prototype1", for: indexPath)
        
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
        // myCell.imageView?.image = UIImage(named: historyArray)
        
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
            self.getData()
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
