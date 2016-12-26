//
//  BudgetVariables.swift
//  Budget Manager
//
//  Created by Nathan Tsai on 12/13/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import CoreData

extension String {
    var html2AttStr: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.code)
            return nil
        }
    }
}

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
    
    // Converts a Double like 80.0 and adds a $ sign to the front and rounds number to 2 decimal places
    // Returns "$80.00" in this example
    class func numFormat(myNum: Double) -> String
    {
        let largeNumber = Double(myNum)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: largeNumber))!
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
    
    // Returns true if every budget's history log is empty
    class func isAllHistoryEmpty() -> Bool
    {
        for i in 0...BudgetVariables.budgetArray.count - 1
        {
            if BudgetVariables.budgetArray[i].historyArray.isEmpty == false
            {
                return false
            }
        }
        return true
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
    class func amountSpentInThePastWeek() -> [Double]
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
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[key] == nil
            {
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[key] = 0.0
            }
            
            amountSpentArray.append(BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[key]!)
            aWeekAgo = cal.date(byAdding: .day, value: 1, to: aWeekAgo!)!
        }
        
        return amountSpentArray
    }
    
    // Log the net amount SPENT for today's spendings for each budget, depending on current index
    class func logTodaysSpendings(num: Double)
    {
        // Key is generated by today's date
        let key = BudgetVariables.todaysDate(format: "MM/dd/YYYY")
        
        // If the item is nil, that means nothing has been spent today. If so, initialize it to 0.0
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[key] == nil
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[key] = 0.0
        }
        
        // Store the new amount into the dictionary with the key being today's date (MM/dd/YYYY)
        let newAmount = BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[key]! + num
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].amountSpentOnDate[key] = newAmount
    }
    
    // If there are more than 5 budgets, return the top 4 budget names in sorted order based on its 
    // key value and then append the "Other" category as the fifth item in the String array
    // If there are 5 or less budgets, just return the String array of budget names
    class func getBudgetNames(map: [String:Double]) -> [String]
    {
        var keys = [String]()
        
        // String array of all the keys (non-sorted)
        for (key, value) in map
        {
            if value > 0.0
            {
                keys.append(key)
            }
        }
        
        // Sort the dictionary by its value, so keys holds the greatest to least Budget in terms of net amount spent
        if keys.count > 5
        {
            keys.sort { (o1, o2) -> Bool in
                return map[o1]! > map[o2]!
            }
            
            var first4:[String] = Array(keys.prefix(4)) 
            first4.append("Other")
            keys = first4
        }
        
        return keys
    }
    
    // If there are more than 5 budgets, return the top 4 amount spent values in sorted order,
    // and then sum the values of the remaining budgets and append it as the fifth item in the Double array
    // If there are 5 or less budgets, just return the Double array of amount spent
    class func getAmtSpent(map: [String:Double]) -> [Double]
    {
        var valuesArray = [Double]()
        
        // Grab just the ordered values into a Double array
        for (_, value) in map
        {
            if value > 0.0
            {
                valuesArray.append(value)
            }
        }
        
        if valuesArray.count > 5
        {
            // Sort the values from greatest to least
            valuesArray = valuesArray.sorted(by: >)
            
            // Grab the top 4, and 5th should be the sum of all of the rest of the values
            var first4 = Array(valuesArray.prefix(4))
            
            var otherValue = 0.0
            for i in 4...valuesArray.count - 1
            {
                otherValue += valuesArray[i]
            }
            
            first4.append(otherValue)
            valuesArray = first4
        }
        
        return valuesArray
    }
    
    // Return a map that maps the budget name to its corresponding net amount spent
    class func nameToNetAmtSpentMap() -> [String:Double]
    {
        var nameToNetAmountMap = [String:Double]()
        if BudgetVariables.budgetArray.isEmpty == false
        {
            for i in 0...BudgetVariables.budgetArray.count - 1
            {
                nameToNetAmountMap[BudgetVariables.budgetArray[i].name!] = BudgetVariables.budgetArray[i].totalAmountSpent
            }
        }
        return nameToNetAmountMap
    }
    
    // This takes a hex color (IE: #ffffff) and returns a UIColor
    class func hexStringToUIColor(hex:String) -> UIColor
    {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Calculates the average of a Double array
    class func calculateAverage(nums: [Double]) -> Double
    {
        var total = 0.0
        for num in nums
        {
            total += num
        }
        return total/Double(nums.count)
    }
    
    // Returns true if the array is filled with all 0.0's
    class func isAllZeros(array: [Double]) -> Bool
    {
        if array.isEmpty == true
        {
            return false
        }
        
        for num in array
        {
            if num != 0.0
            {
                return false
            }
        }
        return true
    }
}
