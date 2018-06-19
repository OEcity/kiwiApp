//
//  CoreDataManager.swift
//  MIIRF_V2
//
//  Created by Tom Odler on 06.16.18.
//  Copyright © 2018 Tom Odler. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    static var sharedManager = CoreDataManager()
    var context : NSManagedObjectContext?
    
    override init() {
        super.init()
        self.context = self.persistentContainer.viewContext
        
    }
    
    func createFlight() -> Flight{
        let flight = NSEntityDescription.insertNewObject(forEntityName: "Flight", into: context!) as! Flight
        self.saveContext()
        return flight
    }
    
    func createTransfer() -> Transfer{
        let transfer = NSEntityDescription.insertNewObject(forEntityName: "Transfer", into: context!) as! Transfer
        self.saveContext()
        return transfer
    }

    
    func deleteOldFlights(){
        let fetchRequest : NSFetchRequest<Flight> = Flight.fetchRequest()
        
        guard let context = context else {
            return
        }
        
        guard let flights = try? context.fetch(fetchRequest) else {
            return
        }
        
        for flight in flights {
            context.delete(flight)
        }
        self.saveContext()
    }
    
    func getAllActualFlights() -> [Flight]?{
        let fetchRequest : NSFetchRequest<Flight> = Flight.fetchRequest()
        
        guard let context = context else {
            return nil
        }
        
        guard let flights = try? context.fetch(fetchRequest) else {
            return nil
        }
        
        return flights
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "kiwiApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
