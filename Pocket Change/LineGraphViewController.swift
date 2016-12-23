//
//  LineGraphViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/22/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import Charts
import Foundation
import CoreData

// The point of this is to add X axis labels of the past 7 days to the graph
@objc(LineChartFormatter)
public class LineChartFormatter: NSObject, IAxisValueFormatter
{
    // Grab past 7 days into an array
    var days = BudgetVariables.pastSevenDays()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return days[Int(value)]
    }
}

class LineGraphViewController: UIViewController
{
    // Clean code
    var sharedDelegate: AppDelegate!
    
    // IB Outlets
    @IBOutlet var lineGraphView: LineChartView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Days Array
    var days: [String]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        saveButton.isEnabled = false
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Sync data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Grab past 7 days into an array
        // let days = BudgetVariables.pastSevenDays()
        //self.navigationItem.title = "Weekly Spendings (" + days[0] + " – " + days[6] + ")"
        self.navigationItem.title = "Weekly Spendings"
        
        // Grab past 7 days into an array
        days = BudgetVariables.pastSevenDays()
        
        // Grab amount spent for each day in the past week into a double array
        let amountSpent = BudgetVariables.amountSpent()
        
        setLineGraph(dataPoints: days, values: amountSpent)
    }

    // Set Line Graph
    func setLineGraph(dataPoints: [String], values: [Double])
    {
        // LINE CHART SPECS //
        
        let lineChartFormatter:LineChartFormatter = LineChartFormatter()
        let xAxis:XAxis = XAxis()
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count
        {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
            
            lineChartFormatter.stringForValue(Double(i), axis: xAxis)
        }
        
        xAxis.valueFormatter = lineChartFormatter
        lineGraphView.xAxis.valueFormatter = xAxis.valueFormatter
        
        // Set the position of the x axis label
        lineGraphView.xAxis.labelPosition = .bottom
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Amount Spent ($)")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineGraphView.data = lineChartData
        
        // Set description texts
        lineGraphView.chartDescription?.text = ""
        
        // Animate the chart
        lineGraphView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    // Save button was pressed (not completed)
    @IBAction func saveButtonWasPressed(_ sender: UIBarButtonItem)
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
