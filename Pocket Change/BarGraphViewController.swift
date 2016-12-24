//
//  BarGraphViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/23/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import Charts
import Foundation
import CoreData

// The point of this is to add X axis labels of the past 7 days to the graph
@objc(BarChartFormatter)
public class BarChartFormatter: NSObject, IAxisValueFormatter
{
    // Grab past 7 days into an array
    var days = BudgetVariables.pastSevenDays()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return days[Int(value)]
    }
}

class BarGraphViewController: UIViewController
{
    // Clean code
    var sharedDelegate: AppDelegate!

    // IB Outlets
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet var barGraphView: BarChartView!
    
    // Days Array
    var days: [String]!
    
    // Initially load delegate
    override func viewDidLoad()
    {
        super.viewDidLoad()
        cameraButton.isEnabled = false
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
    }
    
    // Load the graph before view appears. We do this here because data may change
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // If no data, set the noDataText
        barGraphView.noDataText = "You have no transaction history"
        
        // Sync data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Grab past 7 days into an array
        days = BudgetVariables.pastSevenDays()
        
        // Set the title to be the range of dates displayed
        self.navigationItem.title = days[0] + " – " + days[6]
        
        // Grab amount spent for each day in the past week into a double array
        let amountSpent = [20.0, 4.2, 6.89, 9.99, 60.8, 58.1, 35.0]
        // let amountSpent = BudgetVariables.amountSpent()
        
        setBarGraph(dataPoints: days, values: amountSpent)
    }
    
    // Set Bar Graph
    func setBarGraph(dataPoints: [String], values: [Double])
    {
        let barChartFormatter:BarChartFormatter = BarChartFormatter()
        let xAxis:XAxis = XAxis()
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count
        {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
            
            let _ = barChartFormatter.stringForValue(Double(i), axis: xAxis)
        }
        
        xAxis.valueFormatter = barChartFormatter
        barGraphView.xAxis.valueFormatter = xAxis.valueFormatter
        
        // Set the position of the x axis label
        barGraphView.xAxis.labelPosition = .bottom
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Net Amount Spent ($)")
        let chartData = BarChartData(dataSet: chartDataSet)
        barGraphView.data = chartData
        
        // Customize Bar Graph
        
        // Set font size
        chartData.setValueFont(UIFont.systemFont(ofSize: 12))
        
        // Legend font size
        barGraphView.legend.font = UIFont.systemFont(ofSize: 18)
        barGraphView.legend.formSize = 12
        
        // Set description texts
        barGraphView.chartDescription?.text = ""
        
        // Set the color scheme
        chartDataSet.colors = ChartColorTemplates.liberty()
        
        // Set the background color
        // barGraphView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        // Animate the chart
        barGraphView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }
    
    // Save the graph to the camera roll
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
