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
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet var pieChartView: PieChartView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        cameraButton.isEnabled = false
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        // Set the page title
        self.navigationItem.title = "Distribution"
    }
    
    // Load the graph before view appears. We do this here because data may change
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Sync data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // If no data, set the noDataText
        pieChartView.noDataText = "You must have at least one budget."
        
        // Grab Names and amount spent to populate the Pie Chart
        let map = BudgetVariables.nameToNetAmtSpentMap()
        let budgetNames = BudgetVariables.getBudgetNames(map: map)
        let amtSpent = BudgetVariables.getAmtSpent(map: map)
        print(budgetNames)
        print(amtSpent)
        
        if budgetNames.isEmpty == false && amtSpent.isEmpty == false
        {
            setPieGraph(names: budgetNames, values: amtSpent)
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
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Net Amount Spent")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var customEntries: [LegendEntry] = []
        var colors = [UIColor]()
        
        // Pick a random UIColor Scheme
        let randNum = Int(arc4random_uniform(9) + 1)
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
            // Chinese
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
        default:
            colors = ChartColorTemplates.colorful()
            break
        }
        
        for i in 0..<names.count
        {
            // Find random colors and append them to the colors array
//            let red = Double(arc4random_uniform(201))
//            let green = Double(arc4random_uniform(201))
//            let blue = Double(arc4random_uniform(201))
//            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
//            colors.append(color)
            
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
        pieChartView.legend.formSize = 12
        
        // Set description texts
        pieChartView.chartDescription?.text = ""
        
        // Set Font Size and Color
        pieChartData.setValueFont(UIFont.systemFont(ofSize: 18))
        pieChartData.setValueTextColor(UIColor.black)
    }
    
    // In construction
    @IBAction func cameraButtonWasPressed(_ sender: AnyObject)
    {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
}
