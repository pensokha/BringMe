//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Chuck on 2/3/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var name: String?
    @NSManaged var price: NSNumber?
    @NSManaged var amount: NSNumber?
    @NSManaged var finished: NSNumber?
    @NSManaged var image: String?
}
