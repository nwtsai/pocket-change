//
//  BudgetVariables.swift
//  Budget Manager
//
//  Created by Nathan Tsai on 12/13/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import CoreData

class BudgetVariables: UIViewController
{
    // CoreData maintains this array even when app isn't running
    static var budgetArray = [MyBudget]()
    
    // The current index always gets initialized as the index of the last budget
    static var currentIndex = budgetArray.count - 1
    
    // This function fetches from CoreData
    class func getData()
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do
        {
            budgetArray = try context.fetch(MyBudget.fetchRequest())
        }
        catch
        {
            print("Fetching Failed")
        }
    }
    
    // If we don't need commas, return number as double precision
    // If we do need commas, return number as regular precision unless adding precision is more accurate
    // For instance myNum = 999 returns 999.00 and myNum = 1000 becomes 1,000
    // This saves screen space unless we need more space to be more precise
    class func numFormat(myNum: Double) -> String
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
    
    // If name does not exist already, return argument
    // If name exists, try adding (num++) until the name does not exist
    class func createName(myName: String, myNum: Int) -> String
    {        
        // Temporary variables for testing
        var testName = myName
        var testNum = myNum
        
        // While the testName exists already, increment the testNum and try again with a modified testName
        while nameExistsAlready(str: testName) == true
        {
            testNum += 1
            testName = myName + " (\(testNum))"
        }
        
        // Return the test name once we know it does not already exist
        return testName
    }
    
    // Returns true if the name exists already
    class func nameExistsAlready(str: String) -> Bool
    {
        // If the array is not empty
        if budgetArray.isEmpty == false
        {
            for x in 0...(budgetArray.count - 1)
            {
                if str == budgetArray[x].name
                {
                    return true
                }
            }
        }
        
        // If the array is empty just return false, there can't be a repeating name
        // If it isn't empty but the name was not found after the search, return false
        return false
    }
    
    // Get current date in any format based on argument
    class func todaysDate(format: String) -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
