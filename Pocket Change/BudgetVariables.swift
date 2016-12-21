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
//    var budgetName = "Untitled Budget"
//    var myBalance = 0.00
//    var historyArray = [String]()
//    var descriptionArray = [String]()
//    
//    init(budgetName: String, myBalance: Double, historyArray: [String], descriptionArray: [String])
//    {
//        self.budgetName = budgetName
//        self.myBalance = myBalance
//        self.historyArray = historyArray
//        self.descriptionArray = descriptionArray
//    }
    
    // Global array of all my budgets as an array of this class
    // static var budgetArray: [BudgetVariables] = [BudgetVariables]()
    // static var currentIndex = -1
    
    // CoreData Method
    static var budgetArray = [MyBudget]()
    static var currentIndex = budgetArray.count - 1
}
