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
    @IBOutlet var barGraphView: BarChartView!
    
    // Days Array
    var days: [String]!
    
    // Initially load delegate
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        // If there is no data
        barGraphView.noDataText = "You must have at least one transaction."
    }
    
    // Load the graph before view appears. We do this here because data may change
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Sync data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Grab past 7 days into an array
        days = BudgetVariables.pastSevenDays()
        
        // Set the title to be the range of dates displayed
        self.navigationItem.title = days[0] + " – " + days[6]
        
        // Grab amount spent for each day in the past week into a double array
        let amountSpent = BudgetVariables.amountSpentInThePastWeek()
        
        if days.isEmpty == false && amountSpent.isEmpty == false
        {
            setBarGraph(values: amountSpent)
        }
    }
    
    // Set Bar Graph
    func setBarGraph(values: [Double])
    {
        let barChartFormatter:BarChartFormatter = BarChartFormatter()
        let xAxis:XAxis = XAxis()
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<values.count
        {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
            
            let _ = barChartFormatter.stringForValue(Double(i), axis: xAxis)
        }
        
        xAxis.valueFormatter = barChartFormatter
        barGraphView.xAxis.valueFormatter = xAxis.valueFormatter
        
        
        // Set a limit line to be the average amount spent in that week
        let average = BudgetVariables.calculateAverage(nums: values)
        
        // Only add the average line if there is actually data in the bar graph
        if average != 0.0
        {
            let ll = ChartLimitLine(limit: average, label: "Average: " + BudgetVariables.numFormat(myNum: average))
            ll.lineColor = BudgetVariables.hexStringToUIColor(hex: "092140")
            ll.valueFont = UIFont.systemFont(ofSize: 12)
            ll.lineWidth = 2
            ll.labelPosition = .leftTop
            barGraphView.rightAxis.addLimitLine(ll)
        }
        
        // Set the position of the x axis label
        barGraphView.rightAxis.axisMinimum = 0
        barGraphView.xAxis.labelPosition = .bottom
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Amount Spent Per Day")
        chartDataSet.axisDependency = .right
        let chartData = BarChartData(dataSet: chartDataSet)
        barGraphView.data = chartData
        
        // Legend font size
        barGraphView.legend.font = UIFont.systemFont(ofSize: 13)
        barGraphView.legend.formSize = 8
        
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true
        {
            chartDataSet.label = "You must spend to see data"
            chartData.setDrawValues(false)
            barGraphView.rightAxis.drawLabelsEnabled = false
        }
        else if BudgetVariables.isAllZeros(array: values) == true
        {
            chartDataSet.label = "No spendings this week"
            chartData.setDrawValues(false)
            barGraphView.rightAxis.drawLabelsEnabled = false
        }
        
        // Set where axis starts
        barGraphView.setScaleMinima(0, scaleY: 0.0)
        
        // Customization
        barGraphView.pinchZoomEnabled = false
        barGraphView.scaleXEnabled = false
        barGraphView.scaleYEnabled = false
        barGraphView.xAxis.drawGridLinesEnabled = false
        barGraphView.leftAxis.drawGridLinesEnabled = false
        barGraphView.rightAxis.drawGridLinesEnabled = false
        barGraphView.leftAxis.drawLabelsEnabled = false
        barGraphView.rightAxis.spaceBottom = 0
        barGraphView.leftAxis.spaceBottom = 0
        
        // Set font size
        chartData.setValueFont(UIFont.systemFont(ofSize: 12))
        
        let format = NumberFormatter()
        format.numberStyle = .currency
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter)
        
        // Set Y Axis Font
        barGraphView.rightAxis.labelFont = UIFont.systemFont(ofSize: 11)
        
        // Set X Axis Font
        barGraphView.xAxis.labelFont = UIFont.systemFont(ofSize: 13)
        
        // Set description texts
        barGraphView.chartDescription?.text = ""
        
        // Set the color scheme
        chartDataSet.colors = ChartColorTemplates.liberty()
        
        // Set the background color
        // barGraphView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        // Animate the chart
        barGraphView.animate(xAxisDuration: 0.0, yAxisDuration: 2.0)
    }
}
