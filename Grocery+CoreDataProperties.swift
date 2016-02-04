//
//  Grocery+CoreDataProperties.swift
//  
//
//  Created by Chuck on 2/4/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Grocery {

    @NSManaged var gCreateDate: NSDate?
    @NSManaged var gDescription: String?
    @NSManaged var gFinishDate: NSDate?
    @NSManaged var gNumberOfTotalItems: NSNumber?
    @NSManaged var gShopname: String?
    @NSManaged var gTotalPrice: NSNumber?
    @NSManaged var items: NSSet?

}
