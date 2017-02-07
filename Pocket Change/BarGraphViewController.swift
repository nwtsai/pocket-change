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
@objc(BarChartFormatterWeek)
public class BarChartFormatterWeek: NSObject, IAxisValueFormatter
{
    // Grab past 7 days into an array
    var daysInWeek = BudgetVariables.pastInterval(interval: "Week")
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return daysInWeek[Int(value)]
    }
}

// The point of this is to add X axis labels of the past 7 days to the graph
@objc(BarChartFormatterMonth)
public class BarChartFormatterMonth: NSObject, IAxisValueFormatter
{
    // Grab past 31 days into an array
    var daysInMonth = BudgetVariables.pastInterval(interval: "Month")
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return daysInMonth[Int(value)]
    }
}

class BarGraphViewController: UIViewController
{
    // Clean code
    var sharedDelegate: AppDelegate!

    // IB Outlets
    @IBOutlet var barGraphView: BarChartView!
    @IBOutlet weak var timeIntervalButton: UIBarButtonItem!
    
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
        
        // Grab the days of this past week
        var days = BudgetVariables.pastInterval(interval: "Week")
        
        // Set the title to be the range of dates displayed
        self.navigationItem.title = "Week of " + days[0] + " – " + days[6]
        
        // Grab amount spent for each day in the past week into a double array
        var amountSpentPerWeek = BudgetVariables.amountSpentInThePast(interval: "Week")
        
        if (BudgetVariables.currentIndex == 0)
        {
            amountSpentPerWeek = [20, 4.2, 6.89, 9.99, 60.80, 58.10, 35]
        }
        
        // If there are actually values to display, display the graph
        if amountSpentPerWeek.isEmpty == false
        {
            setBarGraphWeek(values: amountSpentPerWeek)
        }
    }
    
    // Set Bar Graph for the past week
    func setBarGraphWeek(values: [Double])
    {
        let barChartFormatter:BarChartFormatterWeek = BarChartFormatterWeek()
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
        
        // Remove the average line from the previous graph
        barGraphView.rightAxis.removeAllLimitLines();
        
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
        
        // Set the color scheme
        var colors = ChartColorTemplates.liberty()
        let randNum = Int(arc4random_uniform(10) + 1)
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
        default:
            colors = ChartColorTemplates.colorful()
            break
        }
        
        chartDataSet.colors = colors
        
        chartDataSet.axisDependency = .right
        let chartData = BarChartData(dataSet: chartDataSet)
        barGraphView.data = chartData
        
        // Legend font size
        barGraphView.legend.font = UIFont.systemFont(ofSize: 13)
        barGraphView.legend.formSize = 8
        
        // Defaults
        chartData.setDrawValues(true)
        barGraphView.rightAxis.drawLabelsEnabled = true
        
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
        
        // Set the background color
        // barGraphView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        // Animate the chart
        barGraphView.animate(xAxisDuration: 0.0, yAxisDuration: 1.5)
    }
    
    // Set Bar Graph for the past month
    func setBarGraphMonth(values: [Double])
    {
        // Depending on the size of the given array, generate a different X Axis
        let barChartFormatter:BarChartFormatterMonth = BarChartFormatterMonth()
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
        
        // Remove the limit line from the previous graph
        barGraphView.rightAxis.removeAllLimitLines();
        
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
        
        // Set the color scheme
        var colors = ChartColorTemplates.liberty()
        let randNum = Int(arc4random_uniform(10) + 1)
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
        default:
            colors = ChartColorTemplates.colorful()
            break
        }
        
        chartDataSet.colors = colors
        
        chartDataSet.axisDependency = .right
        let chartData = BarChartData(dataSet: chartDataSet)
        barGraphView.data = chartData
        
        // Legend font size
        barGraphView.legend.font = UIFont.systemFont(ofSize: 13)
        barGraphView.legend.formSize = 8
        
        // Defaults
        chartData.setDrawValues(true)
        barGraphView.rightAxis.drawLabelsEnabled = true
        
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true
        {
            chartDataSet.label = "You must spend to see data"
            chartData.setDrawValues(false)
            barGraphView.rightAxis.drawLabelsEnabled = false
        }
        else if BudgetVariables.isAllZeros(array: values) == true
        {
            chartDataSet.label = "No spendings this month"
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
        chartData.setValueFont(UIFont.systemFont(ofSize: 0))
        
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
        
        // Set the background color
        // barGraphView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        // Animate the chart
        barGraphView.animate(xAxisDuration: 0.0, yAxisDuration: 1.5)
    }
    
    // This function runs when time interval button is pressed
    @IBAction func timeIntervalButtonPressed(_ sender: Any)
    {
        // Grab the past 31 days
        var days = BudgetVariables.pastInterval(interval: "Month")
        
        // Toggle the navigation title between past week and month, and the timeIntervalButton
        if self.navigationItem.title == "Week of " + days[24] + " – " + days[30]
        {
            var amountSpentPerMonth = BudgetVariables.amountSpentInThePast(interval: "Month")
            
            if (BudgetVariables.currentIndex == 0)
            {
                for i in 0...30
                {
                    let randomNum = (Double(arc4random()) / 0xFFFFFFFF) * (100 - 5) + 5
                    amountSpentPerMonth[i] = Double(randomNum)
                }
            }
            
            self.navigationItem.title = "Month of " + days[0] + " – " + days[30]
            
            // Toggle button text
            timeIntervalButton.title = "Weekly"
            barGraphView.notifyDataSetChanged()
            setBarGraphMonth(values: amountSpentPerMonth)
        }
        else
        {
            var amountSpentPerWeek = BudgetVariables.amountSpentInThePast(interval: "Week")

            if (BudgetVariables.currentIndex == 0)
            {
                amountSpentPerWeek = [20, 4.2, 6.89, 9.99, 60.80, 58.10, 35]
            }
            
            self.navigationItem.title = "Week of " + days[24] + " – " + days[30]
            
            // Toggle button text
            timeIntervalButton.title = "Monthly"
            barGraphView.notifyDataSetChanged()
            setBarGraphWeek(values: amountSpentPerWeek)
        }
    }
}
