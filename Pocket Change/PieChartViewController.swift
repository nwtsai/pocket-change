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
        
        // If you want random colors, uncomment below and empty the array below
        // var colors: [UIColor] = ChartColorTemplates.colorful()
        
        // Adobe color scheme called "Pear Lemon Fizz"
        let colors:[UIColor] =
            [
                BudgetVariables.hexStringToUIColor(hex: "588F27"),
                BudgetVariables.hexStringToUIColor(hex: "04BFBF"),
                BudgetVariables.hexStringToUIColor(hex: "CAFCD8"),
                BudgetVariables.hexStringToUIColor(hex: "A9CF54"),
                BudgetVariables.hexStringToUIColor(hex: "F7E967")
            ]
        
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
