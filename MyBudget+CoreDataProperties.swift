//
//  MyBudget+CoreDataProperties.swift
//  Pocket Change
//
//  Created by Nathan Tsai on 12/20/16.
//  Copyright © 2016 Nathan Tsai. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MyBudget
{
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyBudget>
    {
        return NSFetchRequest<MyBudget>(entityName: "MyBudget");
    }

    @NSManaged public var name: String?
    @NSManaged public var balance: Double
    @NSManaged public var descriptionArray: [String]
    @NSManaged public var historyArray: [String]
    @NSManaged public var amountSpentPastWeek: [String: Double]
}
