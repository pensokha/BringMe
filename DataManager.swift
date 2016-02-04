//
//  DataManager.swift
//  BringMe
//
//  Created by Chuck on 2/1/16.
//  Copyright © 2016 kaichu. All rights reserved.
//

import Foundation
import CoreData

class DataManager{
    let appDelegate: AppDelegate!
    let managedObjectContext: NSManagedObjectContext!
    private let pageSize = 10
    
    init(appDelegate: UIApplicationDelegate){
        self.appDelegate = appDelegate as! AppDelegate
        self.managedObjectContext = self.appDelegate.managedObjectContext
    }
    
    // Query grocery based on
        // 1. grocery
        // 2. page
        // default all grocery, page 1
        // offSet true, new page
    func queryGrocery(groceryName: String?="",page pageOffset: Int?=1, completion:(groceries:[Grocery], error:NSError?)->Void){
        var groceries = [Grocery]()

        let query = NSFetchRequest()
        let groceryEntityDescription = NSEntityDescription.entityForName("Grocery", inManagedObjectContext: managedObjectContext)
        query.entity = groceryEntityDescription
        query.sortDescriptors = [NSSortDescriptor(key: "gCreateDate", ascending: false)]
        query.fetchLimit = self.pageSize
        query.fetchOffset = (pageOffset!-1) * self.pageSize
        print(query.fetchOffset)
        if (groceryName ?? "").isNotEmpty{
            let queryPredict = NSPredicate(format: "gDescription == %@", groceryName!)
            query.predicate = queryPredict
        }
        
        var err: NSError?
        do{
            groceries = try managedObjectContext.executeFetchRequest(query) as! [Grocery]
        }catch let error as NSError{
            err = error
            print(error.localizedDescription)
            NSLog(error.localizedDescription)
        }
        completion(groceries: groceries, error: err)
    }
    
    func createGrocery() -> Grocery{
        let groceryEntityDescription = NSEntityDescription.entityForName("Grocery", inManagedObjectContext: managedObjectContext)
        let newGrocery = Grocery(entity: groceryEntityDescription!,insertIntoManagedObjectContext: managedObjectContext)
        newGrocery.gCreateDate = NSDate()
        newGrocery.gTotalPrice = 0.0
        newGrocery.gNumberOfTotalItems = 0
        
        return newGrocery
    }
    
    func removeGrocery(grocery: Grocery){
        managedObjectContext.deleteObject(grocery)
    }
    
    func addItemToGrocery(grocery: Grocery,name: String,amount: Int, price: Double,finished: Bool,image: String){
        let itemEntityDescription = NSEntityDescription.entityForName("Item", inManagedObjectContext: managedObjectContext)
        let newItem = Item(entity:itemEntityDescription!,insertIntoManagedObjectContext: managedObjectContext)
        newItem.name = name
        newItem.amount = amount
        newItem.price = price
        newItem.finished = finished
        newItem.image = image
        newItem.setValue(grocery, forKey: "grocery")
        
        self.saveContext()
    }
    
    func removeItem(item: Item){
        managedObjectContext.deleteObject(item)
        appDelegate.saveContext()
    }
    
    func saveContext(){
        appDelegate.saveContext()
    }
    
    
    
    
}