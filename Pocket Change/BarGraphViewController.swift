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

// The point of this is to add X axis labels of the past 31 days to the graph
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

// The point of this is to add X axis labels of the past 12 months to the graph
@objc(BarChartFormatterYear)
public class BarChartFormatterYear: NSObject, IAxisValueFormatter
{
    // Grab the past 12 months into an array
    var monthsInYear = BudgetVariables.pastXMonths(X: 12)
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return monthsInYear[Int(value)]
    }
}

// View Controller Class
class BarGraphViewController: UIViewController
{
    // Clean code
    var sharedDelegate: AppDelegate!

    // IB Outlets
    @IBOutlet var barGraphView: BarChartView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
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
        
        // Grab amount spent for each day in the past week into a double array
        var amountSpentPerWeek = BudgetVariables.amountSpentInThePast(interval: "Week")
        var amountSpentPerMonth = BudgetVariables.amountSpentInThePast(interval: "Month")
        var amountSpentOverAYear = BudgetVariables.amountSpentInThePast12Months()
        
        // Index 0 is our test case with random sample data
        if (BudgetVariables.currentIndex == 0)
        {
            amountSpentPerWeek = [20, 4.2, 6.89, 9.99, 60.80, 58.10, 35]
            var max = 25.0
            var min = 5.0
            for i in 0...30
            {
                let randomNum = (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
                amountSpentPerMonth[i] = Double(randomNum)
                if (i < 16)
                {
                    max += 5.0
                    min += 1.0
                }
                else
                {
                    max -= 2.0
                    min -= 1.0
                }
            }
            amountSpentOverAYear = [25.20, 40.50, 50.65, 24.54, 55.58, 95.69, 135.04, 56.87, 75.67, 100.07, 40.23, 24.64]
        }
        
        // If there are actually values to display, display the graph
        if (segmentedController.selectedSegmentIndex == 0)
        {
            setBarGraphWeek(values: amountSpentPerWeek)
        }
        else if (segmentedController.selectedSegmentIndex == 1)
        {
            setBarGraphMonth(values: amountSpentPerMonth)
        }
        else
        {
            setBarGraphYear(values: amountSpentOverAYear)
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
        let colors = ChartColorTemplates.liberty()
//        let randNum = Int(arc4random_uniform(10) + 1)
//        switch randNum
//        {
//        case 1:
//            // Radiant Gradient
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "DB832E"),
//                    BudgetVariables.hexStringToUIColor(hex: "C76326"),
//                    BudgetVariables.hexStringToUIColor(hex: "AD481F"),
//                    BudgetVariables.hexStringToUIColor(hex: "872E1A"),
//                    BudgetVariables.hexStringToUIColor(hex: "631C15")
//            ]
//        case 2:
//            // Blue Sky
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "ADD5F7"),
//                    BudgetVariables.hexStringToUIColor(hex: "7FB2F0"),
//                    BudgetVariables.hexStringToUIColor(hex: "4E7AC7"),
//                    BudgetVariables.hexStringToUIColor(hex: "35478C"),
//                    BudgetVariables.hexStringToUIColor(hex: "16193B")
//            ]
//        case 3:
//            // Purple Gradient
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "D49AFF"),
//                    BudgetVariables.hexStringToUIColor(hex: "AA7BCC"),
//                    BudgetVariables.hexStringToUIColor(hex: "B44CFF"),
//                    BudgetVariables.hexStringToUIColor(hex: "873ABF"),
//                    BudgetVariables.hexStringToUIColor(hex: "6A4D7F")
//            ]
//        case 4:
//            // Saras Greys
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "A3ADC2"),
//                    BudgetVariables.hexStringToUIColor(hex: "8F99AB"),
//                    BudgetVariables.hexStringToUIColor(hex: "474C55"),
//                    BudgetVariables.hexStringToUIColor(hex: "3D4148"),
//                    BudgetVariables.hexStringToUIColor(hex: "272A2F")
//            ]
//        case 5:
//            // Teal Gradient
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "94EEDD"),
//                    BudgetVariables.hexStringToUIColor(hex: "58F0DB"),
//                    BudgetVariables.hexStringToUIColor(hex: "1DADA7"),
//                    BudgetVariables.hexStringToUIColor(hex: "14898A"),
//                    BudgetVariables.hexStringToUIColor(hex: "0C4A4E")
//            ]
//        case 6:
//            // Green Gradient
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "B2FFBA"),
//                    BudgetVariables.hexStringToUIColor(hex: "AFED98"),
//                    BudgetVariables.hexStringToUIColor(hex: "A1E388"),
//                    BudgetVariables.hexStringToUIColor(hex: "588C56"),
//                    BudgetVariables.hexStringToUIColor(hex: "244021")
//            ]
//        case 7:
//            // Purple Blue Gradient
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "CFC4E0"),
//                    BudgetVariables.hexStringToUIColor(hex: "A69FCF"),
//                    BudgetVariables.hexStringToUIColor(hex: "8683C2"),
//                    BudgetVariables.hexStringToUIColor(hex: "7374B2"),
//                    BudgetVariables.hexStringToUIColor(hex: "64619C")
//            ]
//        case 8:
//            // Misty Sky
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "DCFAC0"),
//                    BudgetVariables.hexStringToUIColor(hex: "B1E1AE"),
//                    BudgetVariables.hexStringToUIColor(hex: "85C79C"),
//                    BudgetVariables.hexStringToUIColor(hex: "56AE8B"),
//                    BudgetVariables.hexStringToUIColor(hex: "00968B")
//            ]
//        case 9:
//            // Ocean
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "02A676"),
//                    BudgetVariables.hexStringToUIColor(hex: "008C72"),
//                    BudgetVariables.hexStringToUIColor(hex: "007369"),
//                    BudgetVariables.hexStringToUIColor(hex: "005A5B"),
//                    BudgetVariables.hexStringToUIColor(hex: "003840")
//            ]
//        case 10:
//            // Red -> Orange
//            colors =
//                [
//                    BudgetVariables.hexStringToUIColor(hex: "F2852A"),
//                    BudgetVariables.hexStringToUIColor(hex: "F8650C"),
//                    BudgetVariables.hexStringToUIColor(hex: "F75105"),
//                    BudgetVariables.hexStringToUIColor(hex: "CD1E01"),
//                    BudgetVariables.hexStringToUIColor(hex: "730202")
//            ]
//        default:
//            colors = ChartColorTemplates.liberty()
//            break
//        }
        
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
        
        // Force all 7 x axis labels to show up
        barGraphView.xAxis.setLabelCount(7, force: false)
        
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
        
        // Remove the limit line from the previous graph
        barGraphView.rightAxis.removeAllLimitLines();
        
        // Set the position of the x axis label
        barGraphView.rightAxis.axisMinimum = 0
        barGraphView.xAxis.labelPosition = .bottom
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Amount Spent Per Day")
        
        // Set the color scheme
        let colors = ChartColorTemplates.liberty()
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
        
        // Force each week to show up
        barGraphView.xAxis.setLabelCount(6, force: false)
        
        // Set description texts
        barGraphView.chartDescription?.text = ""
        
        // Set the background color
        // barGraphView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        // Animate the chart
        barGraphView.animate(xAxisDuration: 0.0, yAxisDuration: 1.5)
    }
    
    // Set Bar Graph for the past year
    func setBarGraphYear(values: [Double])
    {
        let barChartFormatter:BarChartFormatterYear = BarChartFormatterYear()
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
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Amount Spent Per Month")
        
        // Set the color scheme
        let colors = ChartColorTemplates.liberty()
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
            chartDataSet.label = "No spendings this year"
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
        barGraphView.xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        
        // Force all 12 x axis labels to show up
        barGraphView.xAxis.setLabelCount(12, force: false)
        
        // Set description texts
        barGraphView.chartDescription?.text = ""
        
        // Set the background color
        // barGraphView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        // Animate the chart
        barGraphView.animate(xAxisDuration: 0.0, yAxisDuration: 1.5)
    }
    
    // This functions runs when the user selects a new tab
    @IBAction func indexChanged(_ sender: UISegmentedControl)
    {
        // If the "Week" segment is selected
        if (segmentedController.selectedSegmentIndex == 0)
        {
            var amountSpentPerWeek = BudgetVariables.amountSpentInThePast(interval: "Week")
            
            if (BudgetVariables.currentIndex == 0)
            {
                amountSpentPerWeek = [20, 4.2, 6.89, 9.99, 60.80, 58.10, 35]
            }
            
            barGraphView.notifyDataSetChanged()
            setBarGraphWeek(values: amountSpentPerWeek)
        }
            
        // If the "Month" segment is selected
        else if (segmentedController.selectedSegmentIndex == 1)
        {
            var amountSpentPerMonth = BudgetVariables.amountSpentInThePast(interval: "Month")
            
            // Index 0 is our test case with random sample data
            if (BudgetVariables.currentIndex == 0)
            {
                var max = 25.0
                var min = 5.0
                for i in 0...30
                {
                    let randomNum = (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
                    amountSpentPerMonth[i] = Double(randomNum)
                    if (i < 16)
                    {
                        max += 5.0
                        min += 1.0
                    }
                    else
                    {
                        max -= 2.0
                        min -= 1.0
                    }
                }
            }
            
            barGraphView.notifyDataSetChanged()
            setBarGraphMonth(values: amountSpentPerMonth)
        }
            
        // If the "Year" segment is selected
        else if (segmentedController.selectedSegmentIndex == 2)
        {
            var amountSpentOverAYear = BudgetVariables.amountSpentInThePast12Months()
            
            if (BudgetVariables.currentIndex == 0)
            {
                amountSpentOverAYear = [25.20, 40.50, 50.65, 24.54, 55.58, 95.69, 135.04, 56.87, 75.67, 100.07, 40.23, 24.64]
            }
            
            barGraphView.notifyDataSetChanged()
            setBarGraphYear(values: amountSpentOverAYear)
        }
    }
}
