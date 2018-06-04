//
//  Model.swift
//  Stool Tracker
//
//  Created by Malcolm Chalmers on 28/5/18.
//  Copyright © 2018 Malcolm Chalmers. All rights reserved.
//

// *******************************
// NOT USED - DIDNT seem to work
// *******************************


import UIKit
import CoreData

class Model {

    var sittingsDatesArr = [Date]()
    var dateFormatter = DateFormatter()
    
    // write new entry, note whole array (its already saved?)
    func writeData(sitDate: Date) {
        // setup CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newSitting = NSEntityDescription.insertNewObject(forEntityName: "Sittings", into: context)
        
        newSitting.setValue(sitDate, forKey: "date")
        
        do {
            try context.save()
            print ("WRITEDATA: -----SAVED-----")
        }
        catch {
            print ("XXXXX THERE WAS AN ERROR XXXXXXX")
        }
    }
    
    
    // data from CoreData
    func getData() {
        // erase everything in array
        sittingsDatesArr.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
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
                print ("GETDATA: database is empty")
            }
        }
        catch {
            print ("error")
        }
    }

}
