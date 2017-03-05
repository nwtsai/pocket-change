//
//  SpendViewController.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/20/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import CoreLocation

class SpendViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate
{
    // sharedDelegate
    var sharedDelegate: AppDelegate!
    
    // Location manager for finding the current location
    let locationManager = CLLocationManager()
    
    // IB Outlets
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var inputAmount: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    
    // Buttons get initially enabled or disabled based on conditions
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // So we don't need to type this out again
        let shDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate = shDelegate
        
        // Find the current location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // Set Navbar Color
        let color = UIColor.white
        self.navigationController?.navigationBar.tintColor = color
        self.navigationItem.title = BudgetVariables.budgetArray[BudgetVariables.currentIndex].name
        
        // Set textField delegates to themselves
        inputAmount.delegate = self
        descriptionText.delegate = self
        
        // Set placeholder text for each textfield
        inputAmount.placeholder = "$0.00"
        descriptionText.placeholder = "What's it for?"
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SpendViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Syncs labels with global variables
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Save context and get data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Refresh the total balance label, in the case that another view modified the balance vaariable
        totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
        
        // Reset the text fields and disable the buttons
        inputAmount.text = ""
        descriptionText.text = ""
        spendButton.isEnabled = false
        addButton.isEnabled = false
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // This function limits the maximum character count for each textField and limits the decimal places input to 2
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var maxLength = 0
        
        if textField.placeholder == "$0.00"
        {
            maxLength = 10
        }
        else if textField.placeholder == "What's it for?"
        {
            maxLength = 22
        }
        
        let currentString = textField.text as NSString?
        let newString = currentString?.replacingCharacters(in: range, with: string)
        let isValidLength = newString!.characters.count <= maxLength
        
        if textField.placeholder == "$0.00"
        {
            // Max 2 decimal places for input using regex :D
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let regex = try! NSRegularExpression(pattern: "\\..{3,}", options: [])
            let matches = regex.matches(in: newText, options:[], range:NSMakeRange(0, newText.characters.count))
            guard matches.count == 0 else { return false }
            
            switch string
            {
            case "0","1","2","3","4","5","6","7","8","9":
                if isValidLength == true
                {
                    return true
                }
            case ".":
                let array = textField.text?.characters.map { String($0) }
                var decimalCount = 0
                for character in array!
                {
                    if character == "."
                    {
                        decimalCount += 1
                    }
                }
                if decimalCount == 1
                {
                    return false
                }
                else if isValidLength == true
                {
                    return true
                }
            default:
                let array = string.characters.map { String($0) }
                if array.count == 0
                {
                    return true
                }
                return false
            }
        }
        
        // For any other text field, return true if the length is valid
        if isValidLength == true
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // This function gets called when the Spend button is pressed
    @IBAction func spendButtonPressed(_ sender: Any)
    {
        // Get current date, append to history Array
        let date = BudgetVariables.todaysDate(format: "MM/dd/YYYY")
        
        // Trim input first
        let trimmedInput = (inputAmount.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input amount is a number, round the input to two decimal places before doing further calculations
        if let input = (Double(trimmedInput!))?.roundTo(places: 2)
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance -= input
            totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.append("– $" + String(format: "%.2f", input))
            
            // Trim description text before appending
            let description = (descriptionText.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.append(description! + "    " + date)
            
            // Log the amount withdrawn for today's spendings for this specific budget
            BudgetVariables.logTodaysSpendings(num: input)
            
            // Log the total amount spent for this budget
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountSpent += input
            
            // Log the latitude and longitude of the current transaction if the current location is available
            let currentPosition = self.locationManager.location?.coordinate
            if currentPosition != nil
            {
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].markerLatitude.append((currentPosition?.latitude)!)
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].markerLongitude.append((currentPosition?.longitude)!)
            }
                
            // If the current position is nil, set the arrays with placeholders of (360,360)
            else
            {
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].markerLatitude.append(360)
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].markerLongitude.append(360)
            }
                        
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input < 0
            {
                spendButton.isEnabled = false
            }
        }
        else
        {
            // Our amountEnteredChanged should take into account all non-Number cases and
            totalBalance.text = "If this message is seen check func amountEnteredChanged"
        }
        
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
    }
    
    // This function gets called when the Add button is pressed
    @IBAction func addButtonPressed(_ sender: Any)
    {
        // Get current date, append to history Array
        let date = BudgetVariables.todaysDate(format: "MM/dd/YYYY")
    
        // Trim the input Amount
        let trimmedInput = (inputAmount.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
        if let input = (Double(trimmedInput!))?.roundTo(places: 2)
        {
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance += input
            totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].historyArray.append("+ $" + String(format: "%.2f", input))
            
            // Trim description text before appending
            let description = (descriptionText.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].descriptionArray.append(description! + "    " + date)
            
            // Log this into the history and description arrays, and then update the totalAmountAdded and totalBudgetAmount
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalAmountAdded += input
            BudgetVariables.budgetArray[BudgetVariables.currentIndex].totalBudgetAmount += input
            
            // Log the latitude and longitude of the current transaction if the current location is available
            let currentPosition = self.locationManager.location?.coordinate
            if currentPosition != nil
            {
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].markerLatitude.append((currentPosition?.latitude)!)
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].markerLongitude.append((currentPosition?.longitude)!)
            }
                
            // If the current position is nil, set the arrays with placeholders of (360,360)
            else
            {
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].markerLatitude.append(360)
                BudgetVariables.budgetArray[BudgetVariables.currentIndex].markerLongitude.append(360)
            }
            
            if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance + input > 1000000
            {
                addButton.isEnabled = false
            }
        }
    
        // Save data to coredata
        self.sharedDelegate.saveContext()
    
        // Get data
        BudgetVariables.getData()
    }
    
    // This function dynamically configures button availability depending on input
    @IBAction func amountEnteredChanged(_ sender: AnyObject)
    {
        // Trim input first
        let trimmedInput = (inputAmount.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // If the input is empty or a period, show current balance and disable buttons
        if trimmedInput == "" || trimmedInput == "."
        {
            totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
            spendButton.isEnabled = false
            addButton.isEnabled = false
        }
            
        // Otherwise, if the input is a positive number, enable or disable buttons based on input value
        else if let input = (Double(trimmedInput!))?.roundTo(places: 2)
        {
            // Print error statement if input exceeeds 1 million
            if input > 1000000
            {
                totalBalance.text = "Must be under $1M"
                spendButton.isEnabled = false
                addButton.isEnabled = false
            }
            else
            {
                totalBalance.text = BudgetVariables.numFormat(myNum: BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance)
                
                // If the input is $0, disable both buttons
                if input == 0
                {
                    spendButton.isEnabled = false
                    addButton.isEnabled = false
                }
                else
                {
                    // If the input can be spent and still result in a valid balance, enable the spend button
                    if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance - input < 0
                    {
                        spendButton.isEnabled = false
                    }
                    else
                    {
                        spendButton.isEnabled = true
                    }
                    
                    // If the input can be added and still result in a valid balance, enable the add button
                    if BudgetVariables.budgetArray[BudgetVariables.currentIndex].balance + input > 1000000
                    {
                        addButton.isEnabled = false
                    }
                    else
                    {
                        addButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    // When the History button gets pressed segue to the BarGraphViewController file
    @IBAction func historyButtonPressed(_ sender: Any)
    {
        // Save context and get data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        
        // Show the view controller with history and the map
        performSegue(withIdentifier: "showHistoryAndMap", sender: nil)
    }
    
    // When the Graphs icon gets pressed segue to the graphs view
    @IBAction func graphsButtonPressed(_ sender: Any)
    {
        // Save context and get data
        self.sharedDelegate.saveContext()
        BudgetVariables.getData()
        performSegue(withIdentifier: "showGraphs", sender: nil)
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // If we are going to the bar graph view, set button text to be empty
        if segue.identifier == "showGraphs"
        {
            
        }
            
        // If we are going to the history and map view, set button text to be the name of the budget
        else if (segue.identifier == "showHistoryAndMap")
        {
            
        }
        
        // Define the back button's text for the next view        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}
