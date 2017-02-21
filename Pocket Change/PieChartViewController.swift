//
//  PieChartViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/23/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import Charts
import CoreData
import Foundation

class PieChartViewController: UIViewController
{
    // Clean code
    var sharedDelegate: AppDelegate!

    // IB Outlets
    @IBOutlet var pieChartView: PieChartView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        // Set the page title
        self.navigationItem.title = "π"
    }
    
    // Load the graph before view appears. We do this here because data may change
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Sync data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Grab names and amount spent to populate the Pie Chart
        let map = BudgetVariables.nameToNetAmtSpentMap()
        var budgetNames = BudgetVariables.getBudgetNames(map: map)
        let amountSpent = BudgetVariables.getAmtSpent(map: map)
        
        // Format all names except the last name in the budgetNames array
        if budgetNames.count >= 2
        {
            for i in 0..<budgetNames.count - 1
            {
                budgetNames[i] = " " + budgetNames[i] + "    "
            }
        }
        
        // Format the last name in the budgetNames array
        if budgetNames.isEmpty == false
        {
            budgetNames[budgetNames.count - 1] = " " + budgetNames[budgetNames.count - 1]
        }
        
        // Set the no data text message
        if BudgetVariables.budgetArray.isEmpty == true
        {
            pieChartView.noDataText = "You must have at least one budget."
        }
        else if BudgetVariables.isAllHistoryEmpty() == true
        {
            pieChartView.noDataText = "You must have at least one transaction."
        }
        
        if budgetNames.isEmpty == false && amountSpent.isEmpty == false
        {
            if BudgetVariables.isAllZeros(array: amountSpent) == false
            {
                setPieGraph(names: budgetNames, values: amountSpent)
            }
        }
    }

    // Set Pie Graph
    func setPieGraph(names: [String], values: [Double])
    {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<names.count
        {
            // Set corresponding data
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Amount Spent Per Budget")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var customEntries: [LegendEntry] = []
        var colors = [UIColor]()
        
        // Pick a random UIColor Scheme
        let randNum = Int(arc4random_uniform(16) + 1)
        switch randNum
        {
        case 1:
            // Pear Lemon Fizz
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "588F27"),
                    BudgetVariables.hexStringToUIColor(hex: "04BFBF"),
                    BudgetVariables.hexStringToUIColor(hex: "CAFCD8"),
                    BudgetVariables.hexStringToUIColor(hex: "A9CF54"),
                    BudgetVariables.hexStringToUIColor(hex: "F7E967")
            ]
        case 2:
            // Vintage Card
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "5C4B51"),
                    BudgetVariables.hexStringToUIColor(hex: "8CBEB2"),
                    BudgetVariables.hexStringToUIColor(hex: "F2EBBF"),
                    BudgetVariables.hexStringToUIColor(hex: "F3B562"),
                    BudgetVariables.hexStringToUIColor(hex: "F06060")
            ]
        case 3:
            // Marie Antoinette
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "C44C51"),
                    BudgetVariables.hexStringToUIColor(hex: "FFB6B8"),
                    BudgetVariables.hexStringToUIColor(hex: "FFEFB6"),
                    BudgetVariables.hexStringToUIColor(hex: "A2B5BF"),
                    BudgetVariables.hexStringToUIColor(hex: "5F8CA3")
            ]
        case 4:
            // Autumn Berries
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "588C7E"),
                    BudgetVariables.hexStringToUIColor(hex: "F2E394"),
                    BudgetVariables.hexStringToUIColor(hex: "F2AE72"),
                    BudgetVariables.hexStringToUIColor(hex: "D96459"),
                    BudgetVariables.hexStringToUIColor(hex: "8C4646")
            ]
        case 5:
            // Appalachian Spring
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "C24704"),
                    BudgetVariables.hexStringToUIColor(hex: "D9CC3C"),
                    BudgetVariables.hexStringToUIColor(hex: "FFEB79"),
                    BudgetVariables.hexStringToUIColor(hex: "A0E0A9"),
                    BudgetVariables.hexStringToUIColor(hex: "00ADA7")
            ]
        case 6:
            // Cultural Element
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "0067A6"),
                    BudgetVariables.hexStringToUIColor(hex: "00ABD8"),
                    BudgetVariables.hexStringToUIColor(hex: "008972"),
                    BudgetVariables.hexStringToUIColor(hex: "EFC028"),
                    BudgetVariables.hexStringToUIColor(hex: "F2572D")
            ]
        case 7:
            // Aviator
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "6A7059"),
                    BudgetVariables.hexStringToUIColor(hex: "FDEEA7"),
                    BudgetVariables.hexStringToUIColor(hex: "9BCC93"),
                    BudgetVariables.hexStringToUIColor(hex: "1A9481"),
                    BudgetVariables.hexStringToUIColor(hex: "003D5C")
            ]
        case 8:
            // Firenze
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "468966"),
                    BudgetVariables.hexStringToUIColor(hex: "FFF0A5"),
                    BudgetVariables.hexStringToUIColor(hex: "FFB03B"),
                    BudgetVariables.hexStringToUIColor(hex: "B64926"),
                    BudgetVariables.hexStringToUIColor(hex: "8E2800")
            ]
        case 9:
            // Phaedra
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "FF6138"),
                    BudgetVariables.hexStringToUIColor(hex: "FFFF9D"),
                    BudgetVariables.hexStringToUIColor(hex: "BEEB9F"),
                    BudgetVariables.hexStringToUIColor(hex: "79BD8F"),
                    BudgetVariables.hexStringToUIColor(hex: "00A388")
            ]
        case 10:
            // Ocean Sunset
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "F54F29"),
                    BudgetVariables.hexStringToUIColor(hex: "FF974F"),
                    BudgetVariables.hexStringToUIColor(hex: "FFD393"),
                    BudgetVariables.hexStringToUIColor(hex: "9C9B7A"),
                    BudgetVariables.hexStringToUIColor(hex: "405952")
            ]
        case 11:
            // Miami Sunset
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "FFAA5C"),
                    BudgetVariables.hexStringToUIColor(hex: "DA727E"),
                    BudgetVariables.hexStringToUIColor(hex: "AC6C82"),
                    BudgetVariables.hexStringToUIColor(hex: "685C79"),
                    BudgetVariables.hexStringToUIColor(hex: "455C7B")
            ]
        case 12:
            // Nam
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "425957"),
                    BudgetVariables.hexStringToUIColor(hex: "81AC8B"),
                    BudgetVariables.hexStringToUIColor(hex: "F2E5A2"),
                    BudgetVariables.hexStringToUIColor(hex: "F89883"),
                    BudgetVariables.hexStringToUIColor(hex: "D96666")
            ]
        case 13:
            // Spring
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "AF7575"),
                    BudgetVariables.hexStringToUIColor(hex: "EFD8A1"),
                    BudgetVariables.hexStringToUIColor(hex: "BCD693"),
                    BudgetVariables.hexStringToUIColor(hex: "AFD7DB"),
                    BudgetVariables.hexStringToUIColor(hex: "3D9CA8")
            ]
        case 14:
            // Flat Rainbow
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "F15A5A"),
                    BudgetVariables.hexStringToUIColor(hex: "F0C419"),
                    BudgetVariables.hexStringToUIColor(hex: "4EBA6F"),
                    BudgetVariables.hexStringToUIColor(hex: "2D95BF"),
                    BudgetVariables.hexStringToUIColor(hex: "955BA5")
            ]
        case 15:
            // Ramo
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "E15B64"),
                    BudgetVariables.hexStringToUIColor(hex: "F27F62"),
                    BudgetVariables.hexStringToUIColor(hex: "FBB36B"),
                    BudgetVariables.hexStringToUIColor(hex: "ABBC85"),
                    BudgetVariables.hexStringToUIColor(hex: "849B89")
            ]
        case 16:
            // Expo
            colors =
            [
                    BudgetVariables.hexStringToUIColor(hex: "CF2257"),
                    BudgetVariables.hexStringToUIColor(hex: "FD6041"),
                    BudgetVariables.hexStringToUIColor(hex: "FEAA3A"),
                    BudgetVariables.hexStringToUIColor(hex: "2DA4A8"),
                    BudgetVariables.hexStringToUIColor(hex: "435772")
            ]
        default:
            colors = ChartColorTemplates.colorful()
            break
        }
        
        for i in 0..<names.count
        {
            // Create a custom label for each entry (Max 5 Entries)
            let entry:LegendEntry=LegendEntry.init()
            entry.label = names[i]
            entry.formColor = colors[i]
            customEntries.append(entry)
        }
        
        // For a set color scheme
        pieChartDataSet.colors = colors
        
        // Custom Entries
        pieChartView.legend.setCustom(entries: customEntries)
        
        // Format the labels to be of currency format
        let format = NumberFormatter()
        format.numberStyle = .currency
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        // Legend font size
        pieChartView.legend.font = UIFont.systemFont(ofSize: 18)
        pieChartView.legend.formSize = 11
        
        // Set description texts
        pieChartView.chartDescription?.text = ""
        
        // Set Font Size and Color
        pieChartData.setValueFont(UIFont.systemFont(ofSize: 18))
        pieChartData.setValueTextColor(UIColor.black)
        
        pieChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }
}
