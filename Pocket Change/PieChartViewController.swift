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

class PieChartViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    // Clean code
    var sharedDelegate: AppDelegate!

    // IB Outlets
    @IBOutlet var pieChartView: PieChartView!
    @IBOutlet weak var chartLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pickerTextField: UITextField!
    
    // ColorPicker
    var ColorPicker = UIPickerView()
    
    // Spring
    var color0 =
    [
        BudgetVariables.hexStringToUIColor(hex: "AF7575"),
        BudgetVariables.hexStringToUIColor(hex: "EFD8A1"),
        BudgetVariables.hexStringToUIColor(hex: "BCD693"),
        BudgetVariables.hexStringToUIColor(hex: "AFD7DB"),
        BudgetVariables.hexStringToUIColor(hex: "3D9CA8")
    ]
    
    // Marie Antoinette
    var color1 =
    [
        BudgetVariables.hexStringToUIColor(hex: "C44C51"),
        BudgetVariables.hexStringToUIColor(hex: "FFB6B8"),
        BudgetVariables.hexStringToUIColor(hex: "FFEFB6"),
        BudgetVariables.hexStringToUIColor(hex: "A2B5BF"),
        BudgetVariables.hexStringToUIColor(hex: "5F8CA3")
    ]
    
    // Flat Rainbow
    var color2 =
    [
        BudgetVariables.hexStringToUIColor(hex: "F15A5A"),
        BudgetVariables.hexStringToUIColor(hex: "F0C419"),
        BudgetVariables.hexStringToUIColor(hex: "4EBA6F"),
        BudgetVariables.hexStringToUIColor(hex: "2D95BF"),
        BudgetVariables.hexStringToUIColor(hex: "955BA5")
    ]

    // Autumn Berries
    var color3 =
    [
        BudgetVariables.hexStringToUIColor(hex: "588C7E"),
        BudgetVariables.hexStringToUIColor(hex: "F2E394"),
        BudgetVariables.hexStringToUIColor(hex: "F2AE72"),
        BudgetVariables.hexStringToUIColor(hex: "D96459"),
        BudgetVariables.hexStringToUIColor(hex: "8C4646")
    ]

    // Cultural Element
    var color4 =
    [
        BudgetVariables.hexStringToUIColor(hex: "0067A6"),
        BudgetVariables.hexStringToUIColor(hex: "00ABD8"),
        BudgetVariables.hexStringToUIColor(hex: "008972"),
        BudgetVariables.hexStringToUIColor(hex: "EFC028"),
        BudgetVariables.hexStringToUIColor(hex: "F2572D")
    ]
    
    // Pear Lemon Fizz
    var color5 =
    [
        BudgetVariables.hexStringToUIColor(hex: "588F27"),
        BudgetVariables.hexStringToUIColor(hex: "04BFBF"),
        BudgetVariables.hexStringToUIColor(hex: "CAFCD8"),
        BudgetVariables.hexStringToUIColor(hex: "A9CF54"),
        BudgetVariables.hexStringToUIColor(hex: "F7E967")
    ]
    
    // Friendly Flat Design
    var color6 =
    [
        BudgetVariables.hexStringToUIColor(hex: "FF716A"),
        BudgetVariables.hexStringToUIColor(hex: "FF9441"),
        BudgetVariables.hexStringToUIColor(hex: "FFED5E"),
        BudgetVariables.hexStringToUIColor(hex: "6593FF"),
        BudgetVariables.hexStringToUIColor(hex: "AC71FF")
    ]

    // Miami Sunset
    var color7 =
    [
        BudgetVariables.hexStringToUIColor(hex: "FFAA5C"),
        BudgetVariables.hexStringToUIColor(hex: "DA727E"),
        BudgetVariables.hexStringToUIColor(hex: "AC6C82"),
        BudgetVariables.hexStringToUIColor(hex: "685C79"),
        BudgetVariables.hexStringToUIColor(hex: "455C7B")
    ]
    
    // Nam
    var color8 =
    [
        BudgetVariables.hexStringToUIColor(hex: "425957"),
        BudgetVariables.hexStringToUIColor(hex: "81AC8B"),
        BudgetVariables.hexStringToUIColor(hex: "F2E5A2"),
        BudgetVariables.hexStringToUIColor(hex: "F89883"),
        BudgetVariables.hexStringToUIColor(hex: "D96666")
    ]
    
    // Ramo
    var color9 =
    [
        BudgetVariables.hexStringToUIColor(hex: "E15B64"),
        BudgetVariables.hexStringToUIColor(hex: "F27F62"),
        BudgetVariables.hexStringToUIColor(hex: "FBB36B"),
        BudgetVariables.hexStringToUIColor(hex: "ABBC85"),
        BudgetVariables.hexStringToUIColor(hex: "849B89")
    ]

    // Expo
    var color10 =
    [
        BudgetVariables.hexStringToUIColor(hex: "CF2257"),
        BudgetVariables.hexStringToUIColor(hex: "FD6041"),
        BudgetVariables.hexStringToUIColor(hex: "FEAA3A"),
        BudgetVariables.hexStringToUIColor(hex: "2DA4A8"),
        BudgetVariables.hexStringToUIColor(hex: "435772")
    ]
    
    // Firenze
    var color11 =
    [
        BudgetVariables.hexStringToUIColor(hex: "468966"),
        BudgetVariables.hexStringToUIColor(hex: "FFF0A5"),
        BudgetVariables.hexStringToUIColor(hex: "FFB03B"),
        BudgetVariables.hexStringToUIColor(hex: "B64926"),
        BudgetVariables.hexStringToUIColor(hex: "8E2800")
    ]
    
    // Aviator
    var color12 =
    [
        BudgetVariables.hexStringToUIColor(hex: "6A7059"),
        BudgetVariables.hexStringToUIColor(hex: "FDEEA7"),
        BudgetVariables.hexStringToUIColor(hex: "9BCC93"),
        BudgetVariables.hexStringToUIColor(hex: "1A9481"),
        BudgetVariables.hexStringToUIColor(hex: "003D5C")
    ]
    
    // Color Array
    var ColorArray = [[UIColor]]()
    var ColorArrayLabels = ["Spring", "Marie", "Rainbow", "Berries", "Element", "Fizz", "Flat", "Miami", "Nam", "Ramo", "Expo", "Firenze", "Aviator"]
    var CurrentColorIndex = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        // Set back button color
        let color = UIColor.white
        self.navigationController?.navigationBar.tintColor = color
        
        // Initializing picker view
        ColorPicker.delegate = self
        ColorPicker.dataSource = self
        
        // Customize the textfield
        pickerTextField.delegate = self
        pickerTextField.inputView = ColorPicker
        pickerTextField.tintColor = UIColor.clear
        pickerTextField.layer.borderColor = UIColor.white.cgColor
        pickerTextField.layer.borderWidth = 1.0
        pickerTextField.layer.cornerRadius = 4.5
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PieChartViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Initialize the color array
        ColorArray = [color0, color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12]
    }
    
    // Load the graph before view appears. We do this here because data may change
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Sync data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Set the no data text message
        if BudgetVariables.budgetArray.isEmpty == true
        {
            pieChartView.noDataText = "You must have at least one budget."
        }
        else if BudgetVariables.isAllHistoryEmpty() == true
        {
            pieChartView.noDataText = "You must have at least one transaction."
        }
        
        // Set the chart label text
        updateChartLabel()
        
        // Update the pie graph
        updatePieGraph()
        
        // Set textfield label for color, and initialize the picker to start at a certain value
        pickerTextField.text = ColorArrayLabels[CurrentColorIndex]
        ColorPicker.selectRow(CurrentColorIndex, inComponent: 0, animated: true)
    }
    
    // Update the Pie Graph data
    func updatePieGraph()
    {
        var map = [String:Double]()
        
        // The segmented controller determines what data gets passed to the pie chart
        if segmentedControl.selectedSegmentIndex == 0
        {
            map = BudgetVariables.nameToNetAmtSpentMap()
        }
        else
        {
            map = BudgetVariables.nameToTransactionCount()
        }
        
        // Grab correct values to populate the Pie Chart
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
        
        if budgetNames.isEmpty == false && amountSpent.isEmpty == false
        {
            if BudgetVariables.isAllZeros(array: amountSpent) == false
            {
                setPieGraphForAmountSpent(names: budgetNames, values: amountSpent)
            }
        }
    }

    // Set Pie Graph for amount spent
    func setPieGraphForAmountSpent(names: [String], values: [Double])
    {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<names.count
        {
            // Set corresponding data
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
                
        var pieChartLabel = ""
        if segmentedControl.selectedSegmentIndex == 0
        {
            pieChartLabel = "Amount Spent Per Budget"
        }
        else
        {
            pieChartLabel = "Transactions Per Budget"
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: pieChartLabel)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var customEntries: [LegendEntry] = []
        var colors = ColorArray[CurrentColorIndex]
        
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
        
        let format = NumberFormatter()
        
        // Format the labels to be of currency format if the segment selected is for dollars
        if segmentedControl.selectedSegmentIndex == 0
        {
            format.numberStyle = .currency
        }
        else
        {
            format.numberStyle = .none
        }
        
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        // Legend font size
        pieChartView.legend.font = UIFont.systemFont(ofSize: 18)
        pieChartView.legend.formSize = 11
        
        // Set description text
        pieChartView.chartDescription?.text = ""
        
        // Set Font Size and Color
        pieChartData.setValueFont(UIFont.systemFont(ofSize: 18))
        pieChartData.setValueTextColor(UIColor.black)
        
        // Calculate average
        let average = BudgetVariables.calculateAverage(nums: values).roundTo(places: 2)
        var averageString = String(average)
        if segmentedControl.selectedSegmentIndex == 0
        {
            averageString = BudgetVariables.numFormat(myNum: average)
        }
        
        // Style the center text and display the average
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let myAttributes: [String:Any] =
        [
            NSForegroundColorAttributeName: UIColor.gray,
            NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 27)!,
            NSParagraphStyleAttributeName: paragraph
        ]
        pieChartView.centerAttributedText = NSAttributedString(string: "Average:\n" + averageString, attributes: myAttributes)
        
        // Animate the pie chart
        pieChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }
    
    // Update the label of the pie chart
    func updateChartLabel()
    {
        if segmentedControl.selectedSegmentIndex == 0
        {
            chartLabel.text = "Amount Spent"
        }
        else
        {
            chartLabel.text = "Transactions"
        }
    }
    
    // If the index of the segmented controller changes
    @IBAction func indexChanged(_ sender: Any)
    {
        updateChartLabel()
        updatePieGraph()
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
    
    // When a row is selected, update color index and update the pie chart
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        pickerTextField.text = ColorArrayLabels[row]
        CurrentColorIndex = row
        
        // Save and get data to coredata
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Update the graph once a new color is chosen
        updatePieGraph()
    }
    
    // There is only one component for the pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // A user cannot edit the text that is in the UITextField. Only the pickerView can modify the text in the UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return false
    }
    
    // A view that dims the background while the user selects a color
    let blackView = UIView()
    
    // When a user presses the text field picker, dim the background with an animation
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if let window = UIApplication.shared.keyWindow
        {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.45)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            UIView.animate(withDuration: 0.6, animations:
                {
                    self.blackView.alpha = 1
            })
        }
    }
    
    // When a user taps the black view, animate and fade the view back to normal
    func handleDismiss()
    {
        UIView.animate(withDuration: 0.6)
        {
            self.blackView.alpha = 0
        }
        dismissKeyboard()
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        pickerTextField.endEditing(true)
    }
}
