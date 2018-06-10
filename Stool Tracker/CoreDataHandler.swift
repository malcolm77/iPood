//
//  CoreDataHandler.swift
//  Stool Tracker
//
//  Created by Malcolm Chalmers on 10/6/18.
//  Copyright © 2018 Malcolm Chalmers. All rights reserved.
//

import UIKit
import CoreData
import os

class CoreDataHandler {
    let myLog = OSLog(subsystem: "application", category: "DefaultLog")
    
    // Just a test function
    func logMessage(message: StaticString) {
        os_log(message, log: myLog, type: .error)
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // data from CoreData
    func getData() {
        // erase everything in array
        sittingsDatesArr.removeAll()
        
        let context = getContext()
        //get data from CoreData
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sittings")
        
        request.returnsObjectsAsFaults = false
        
        // loop through result (of fetch request) and append them to the array
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    // print ("results")
                    if let sittingDate = result.value(forKey: "date") as? Date {
                        //add data to array
                        sittingsDatesArr.append(sittingDate)
                    }
                }
            }
            else {
                os_log("GETDATA: database is empty", log: myLog, type: .info)
            }
        }
        catch {
            os_log("XXXXX THERE WAS AN ERROR XXXXXXX", log: myLog, type: .error)
        }
    }
    
    func writeData(sitDate: Date) {
        let context = getContext()
        let newSitting = NSEntityDescription.insertNewObject(forEntityName: "Sittings", into: context)
        
        newSitting.setValue(sitDate, forKey: "date")
        
        do {
            try context.save()
            os_log ("WRITEDATA: -----SAVED-----", log: myLog, type: .info)
        }
        catch {
            os_log("XXXXX THERE WAS AN ERROR XXXXXXX", log: myLog, type: .error)
        }
    }
}
