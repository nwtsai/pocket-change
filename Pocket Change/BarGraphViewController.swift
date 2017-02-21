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
class BarGraphViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    // Clean code
    var sharedDelegate: AppDelegate!

    // IB Outlets
    @IBOutlet var barGraphView: BarChartView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var pickerTextField: UITextField!
    
    // ColorPicker
    var ColorPicker = UIPickerView()

    // Blue
    var color0 = ChartColorTemplates.liberty()

    // Purple
    var color1 =
    [
        BudgetVariables.hexStringToUIColor(hex: "CFC4E0"),
        BudgetVariables.hexStringToUIColor(hex: "A69FCF"),
        BudgetVariables.hexStringToUIColor(hex: "8683C2"),
        BudgetVariables.hexStringToUIColor(hex: "7374B2"),
        BudgetVariables.hexStringToUIColor(hex: "64619C")
    ]
    
    // Grey
    var color2 =
    [
        BudgetVariables.hexStringToUIColor(hex: "A3ADC2"),
        BudgetVariables.hexStringToUIColor(hex: "8F99AB"),
        BudgetVariables.hexStringToUIColor(hex: "474C55"),
        BudgetVariables.hexStringToUIColor(hex: "3D4148"),
        BudgetVariables.hexStringToUIColor(hex: "272A2F")
    ]
    
    // Teal
    var color3 =
    [
        BudgetVariables.hexStringToUIColor(hex: "94EEDD"),
        BudgetVariables.hexStringToUIColor(hex: "58F0DB"),
        BudgetVariables.hexStringToUIColor(hex: "1DADA7"),
        BudgetVariables.hexStringToUIColor(hex: "14898A"),
        BudgetVariables.hexStringToUIColor(hex: "0C4A4E")
    ]
    
    // Fire
    var color4 =
    [
        BudgetVariables.hexStringToUIColor(hex: "F2852A"),
        BudgetVariables.hexStringToUIColor(hex: "F8650C"),
        BudgetVariables.hexStringToUIColor(hex: "F75105"),
        BudgetVariables.hexStringToUIColor(hex: "CD1E01"),
        BudgetVariables.hexStringToUIColor(hex: "730202")
    ]
    
    // Water
    var color5 =
    [
        BudgetVariables.hexStringToUIColor(hex: "1A8BB2"),
        BudgetVariables.hexStringToUIColor(hex: "127899"),
        BudgetVariables.hexStringToUIColor(hex: "13647F"),
        BudgetVariables.hexStringToUIColor(hex: "0E5066"),
        BudgetVariables.hexStringToUIColor(hex: "0B3C4C")
    ]
    
    // Earth
    var color6 =
    [
        BudgetVariables.hexStringToUIColor(hex: "02A676"),
        BudgetVariables.hexStringToUIColor(hex: "008C72"),
        BudgetVariables.hexStringToUIColor(hex: "007369"),
        BudgetVariables.hexStringToUIColor(hex: "005A5B"),
        BudgetVariables.hexStringToUIColor(hex: "003840")
    ]
    
    // Air
    var color7 =
    [
        BudgetVariables.hexStringToUIColor(hex: "ACD3D8"),
        BudgetVariables.hexStringToUIColor(hex: "9ABCE0"),
        BudgetVariables.hexStringToUIColor(hex: "7798BD"),
        BudgetVariables.hexStringToUIColor(hex: "4A678C"),
        BudgetVariables.hexStringToUIColor(hex: "2D4473")
    ]
    
    // Mist
    var color8 =
    [
        BudgetVariables.hexStringToUIColor(hex: "DCFAC0"),
        BudgetVariables.hexStringToUIColor(hex: "B1E1AE"),
        BudgetVariables.hexStringToUIColor(hex: "85C79C"),
        BudgetVariables.hexStringToUIColor(hex: "56AE8B"),
        BudgetVariables.hexStringToUIColor(hex: "00968B")
    ]
    
    // Orange
    var color9 =
    [
        BudgetVariables.hexStringToUIColor(hex: "DB832E"),
        BudgetVariables.hexStringToUIColor(hex: "C76326"),
        BudgetVariables.hexStringToUIColor(hex: "AD481F"),
        BudgetVariables.hexStringToUIColor(hex: "872E1A"),
        BudgetVariables.hexStringToUIColor(hex: "631C15")
    ]

    // Grape
    var color10 =
    [
        BudgetVariables.hexStringToUIColor(hex: "D49AFF"),
        BudgetVariables.hexStringToUIColor(hex: "AA7BCC"),
        BudgetVariables.hexStringToUIColor(hex: "B44CFF"),
        BudgetVariables.hexStringToUIColor(hex: "873ABF"),
        BudgetVariables.hexStringToUIColor(hex: "6A4D7F")
    ]

    // Color Array
    var ColorArray = [[UIColor]]()
    var ColorArrayLabels = ["Blue", "Purple", "Grey", "Teal", "Fire", "Water", "Earth", "Air", "Mist", "Orange", "Grape"]

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
        
        // Initializing picker view
        ColorPicker.delegate = self
        ColorPicker.dataSource = self
        
        // Customize the textfield
        pickerTextField.inputView = ColorPicker
        pickerTextField.tintColor = UIColor.clear
        pickerTextField.layer.borderColor = UIColor.white.cgColor
        pickerTextField.layer.borderWidth = 1.0
        pickerTextField.layer.cornerRadius = 4.0
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BarGraphViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Initialize the color array
        ColorArray = [color0, color1, color2, color3, color4, color5, color6, color7, color8, color9, color10]
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
            amountSpentOverAYear = [65.20, 134.50, 120.65, 168.8, 186.58, 295.69, 275.67, 256.87, 186.42, 240.23, 200.67, 140.98]
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
        
        // Set textfield label for color, and initialize the picker to start at a certain value
        let CurrentColorIndex = BudgetVariables.budgetArray[BudgetVariables.currentIndex].barGraphColor
        pickerTextField.text = ColorArrayLabels[CurrentColorIndex]
        ColorPicker.selectRow(CurrentColorIndex, inComponent: 0, animated: true)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        pickerTextField.endEditing(true)
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
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "$$ Spent Per Day")
        
        // Select the color scheme
        chartDataSet.colors = ColorArray[BudgetVariables.budgetArray[BudgetVariables.currentIndex].barGraphColor]
        
        chartDataSet.axisDependency = .right
        let chartData = BarChartData(dataSet: chartDataSet)
        barGraphView.data = chartData
        
        // Legend font size
        barGraphView.legend.font = UIFont.systemFont(ofSize: 13)
        barGraphView.legend.formSize = 8
        
        // Defaults
        chartData.setDrawValues(true)
        barGraphView.rightAxis.drawLabelsEnabled = true
        
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true || BudgetVariables.isAllZeros(array: values) == true
        {
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
        
        // Set a limit line to be the average amount spent in that week
        let average = BudgetVariables.calculateAverage(nums: values)
        
        // Remove the average line from the previous graph rendered
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
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "$$ Spent Per Day")
        
        // Select the color scheme
        let colorSelector = BudgetVariables.budgetArray[BudgetVariables.currentIndex].barGraphColor
        chartDataSet.colors = ColorArray[colorSelector]
        
        chartDataSet.axisDependency = .right
        let chartData = BarChartData(dataSet: chartDataSet)
        barGraphView.data = chartData
        
        // Legend font size
        barGraphView.legend.font = UIFont.systemFont(ofSize: 13)
        barGraphView.legend.formSize = 8
        
        // Defaults
        chartData.setDrawValues(true)
        barGraphView.rightAxis.drawLabelsEnabled = true
        
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true || BudgetVariables.isAllZeros(array: values) == true
        {
            chartDataSet.label = "You must spend to see data"
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
        
        // Set labels to be 5 day increments
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
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "$$ Spent Per Month")
        
        // Select the color scheme
        let colorSelector = BudgetVariables.budgetArray[BudgetVariables.currentIndex].barGraphColor
        chartDataSet.colors = ColorArray[colorSelector]
        
        chartDataSet.axisDependency = .right
        let chartData = BarChartData(dataSet: chartDataSet)
        barGraphView.data = chartData
        
        // Legend font size
        barGraphView.legend.font = UIFont.systemFont(ofSize: 13)
        barGraphView.legend.formSize = 8
        
        // Defaults
        chartData.setDrawValues(true)
        barGraphView.rightAxis.drawLabelsEnabled = true
        
        if BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.isEmpty == true || BudgetVariables.isAllZeros(array: values) == true
        {
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
    
    // Refresh the graph depending on the color or time interval chosen
    func updateGraph()
    {
        // If the "Week" segment is selected
        if (segmentedController.selectedSegmentIndex == 0)
        {
            var amountSpentPerWeek = BudgetVariables.amountSpentInThePast(interval: "Week")
            
            // Index 0 is our test case with random sample data
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
                var max = 15.0
                var min = 5.0
                for i in 0...30
                {
                    let randomNum = (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
                    amountSpentPerMonth[i] = Double(randomNum)
                    if (i < 11)
                    {
                        max += 2.0
                        min += 1.0
                    }
                    else if (i < 21)
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
            
            // Index 0 is our test case with random sample data
            if (BudgetVariables.currentIndex == 0)
            {
                amountSpentOverAYear = [65.20, 134.50, 120.65, 168.8, 186.58, 295.69, 275.67, 256.87, 186.42, 240.23, 200.67, 140.98]
            }
            
            barGraphView.notifyDataSetChanged()
            setBarGraphYear(values: amountSpentOverAYear)
        }
    }
    
    // This functions runs when the user selects a new tab
    @IBAction func indexChanged(_ sender: UISegmentedControl)
    {
        updateGraph()
    }
    
    // Conform to picker view protocol
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return ColorArrayLabels[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ColorArrayLabels.count
    }
    
    // When a row is selected, update color index and update the bar graph
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        pickerTextField.text = ColorArrayLabels[row]
        BudgetVariables.budgetArray[BudgetVariables.currentIndex].barGraphColor = row
        
        // Save and get data to coredata
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Update the graph once a new color is chosen
        updateGraph()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
}
