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
    static var currentIndex = 0
    
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
    
    // Grab the past 7 days into a String array
    class func pastSevenDays() -> [String]
    {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var sevenDaysAgo = cal.date(byAdding: .day, value: -6, to: today)
        var days = [String]()
        
        for _ in 1 ... 7
        {
            let day = cal.component(.day, from: sevenDaysAgo!)
            let month = cal.component(.month, from: sevenDaysAgo!)
            let stringDate = String(month) + "/" + String(day)
            days.append(stringDate)
            sevenDaysAgo = cal.date(byAdding: .day, value: 1, to: sevenDaysAgo!)!
        }
        
        return days
    }
    
    // Grab amount spent for the past 7 days into a Double array
    class func amountSpent() -> [Double]
    {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var aWeekAgo = cal.date(byAdding: .day, value: -6, to: today)
        var amountSpentArray = [Double]()
        
        for _ in 1 ... 7
        {
            let day = cal.component(.day, from: aWeekAgo!)
            let month = cal.component(.month, from: aWeekAgo!)
            let year = cal.component(.year, from: aWeekAgo!)
            let key = String(month) + "/" + String(day) + "/" + String(year)
            
            // If the amount spent is empty, set it to 0.0 for that day
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentPastWeek[key] == nil
            {
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentPastWeek[key] = 0.0
            }
            
            amountSpentArray.append(BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentPastWeek[key]!)
            aWeekAgo = cal.date(byAdding: .day, value: 1, to: aWeekAgo!)!
        }
        
        return amountSpentArray
    }
    
    // Log the amount withdrawn for today's spendings for each budget, depending on current index
    class func logTodaysSpendings(num: Double)
    {
        // Key is generated by today's date
        let key = BudgetVariables.todaysDate(format: "MM/dd/YYYY")
        
        // If the item is nil, that means nothing has been withdrawn today. If so, initialize it to 0.0
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentPastWeek[key] == nil
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentPastWeek[key] = 0.0
        }
        
        // Store the new amount into the dictionary with the key being today's date (MM/dd/YYYY)
        let newAmount = BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentPastWeek[key]! + num
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentPastWeek[key] = newAmount
    }
}
