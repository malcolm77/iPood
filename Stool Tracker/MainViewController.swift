//
//  ViewController.swift
//  Stool Tracker
//
//  Created by Malcolm Chalmers on 10/5/18.
//  Copyright © 2018 Malcolm Chalmers. All rights reserved.
//

import UIKit
import CoreData
import os

// var selectedDateString: String = ""
var selectedDate: Date? = nil
var newDate: Date? = nil
let myLog = OSLog(subsystem: "com.malcolmchalmers.ipood", category: "DefaultLog")

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    
    @IBOutlet weak var poopTable: UITableView!
    @IBOutlet var myView: UIView!

    var sittingsDatesArr = [Date]()
    let dateFormatter = DateFormatter()
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        shareData()
    }
    
    func refresh(){
        // refresh data in the array
        getData()
        
        // display new count
//       print ("REFRESH: array refreshed, new count is :" + String(sittingsDatesArr.count))
        
        // refresh table view
        poopTable.reloadData()        
    }
    
    //MARK: tableView functions
    
    // return number of row in array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sittingsDatesArr.count
    }
    
    // display table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        
        // set date format to date only for left side of cell
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let day = dateFormatter.string(from: sittingsDatesArr[indexPath.row])

        // set date format to time only for right side of cell
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let time = dateFormatter.string(from: sittingsDatesArr[indexPath.row])
        
        // set cell information
        cell.textLabel?.text = day
        cell.detailTextLabel?.text = time
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //handle cell delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
  
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .long
            
            let date = sittingsDatesArr[indexPath.row]
//            print ("TABLEVIEW-EDIT: selected date: " + dateFormatter.string(from: date))
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sittings")
            
            request.predicate = NSPredicate(format:"date = %@", date as CVarArg)
            

            let result = try? context.fetch(request)
            let resultData = result as! [NSManagedObject]

            for object in resultData {
                
                context.delete(object)
            }

            do {
                try context.save()
                print("TABLEVIEW-EDIT: saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {

            }
            
            //refresh
            refresh()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDate = sittingsDatesArr[indexPath.row]
        performSegue(withIdentifier: "gotodatepicker", sender: self)
    }
    
    // Handle button press
    @IBAction func buttonPress(_ sender: UIButton) {
        writeData(sitDate: Date()) //write new sitting to core data
        refresh()
    }
    
    //MARK: Main / View Functions
    
    // fill array before tableView is loaded
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Data functions
    
    func saveChanges() {
        // setup CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try context.save()
            os_log("WRITEDATA: -----SAVED-----", log: myLog, type: .info)
        }
        catch {
            os_log ("XXXXX THERE WAS AN ERROR XXXXXXX", log: myLog, type: .error)
        }
    }
    
    // write new entry, note whole array (its already saved?)
    func writeData(sitDate: Date) {
        // setup CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newSitting = NSEntityDescription.insertNewObject(forEntityName: "Sittings", into: context)
        
        newSitting.setValue(sitDate, forKey: "date")
        
        do {
            try context.save()
            os_log ("WRITEDATA: -----SAVED-----", log: myLog, type: .info)
        }
        catch {
            os_log("XXXXX THERE WAS AN ERROR XXXXXXX", log: myLog, type: .error) // ("XXXXX THERE WAS AN ERROR XXXXXXX")
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
                os_log("GETDATA: database is empty", log: myLog, type: .info)
            }
        }
        catch {
            os_log("XXXXX THERE WAS AN ERROR XXXXXXX", log: myLog, type: .error)
        }
    }
    
    func shareData() {
        var shareString = String()
        var objectsToShare: [Any] = []
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        objectsToShare.append("My iPood dates:")
        
        if (sittingsDatesArr.count > 0) {
            for item in sittingsDatesArr {
                shareString = shareString + dateFormatter.string(from: item)
                objectsToShare.append(dateFormatter.string(from: item))
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        //Excluded Activities
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        
        activityVC.popoverPresentationController?.sourceView = myView
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        // update something with the new value in selectedDate
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
//        if let returnedDate = newDate {
//            print("unwindToThisViewController:" + dateFormatter.string(from: returnedDate))
//        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sittings")
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let sitDate = result.value(forKey: "date") as? Date {
                        
                        if sitDate == selectedDate {
                            
                            result.setValue (newDate, forKey: "date")
                            
                            do {
                                try context.save()
                            }
                            catch {
                                os_log("error getting data", log: myLog, type: .error)
                            }
                        }
                    }
                }
            }
        }
        catch  {
            os_log("error getting data", log: myLog, type: .error)
        }
    
        // refresh the table view
        refresh()
    }
    
    @IBAction func trashBarButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all entries?", preferredStyle: .alert)

        
        alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            os_log("YES pressed", log: myLog, type: .info)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sittings")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                os_log("errror deleting all data", log: myLog, type: .error)
            }
            
            self.refresh()
        }))
        
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            os_log("NO pressed", log: myLog, type: .info)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
} //end of class

extension UIViewController {
    
    // configure what swipe gesture goes where.
    @objc func swipeAction(swipe:UISwipeGestureRecognizer) {

        switch swipe.direction.rawValue {
        case 1:
            performSegue(withIdentifier: "SwipeLeft", sender: self)
        case 2:
            performSegue(withIdentifier: "SwipeRight", sender: self)
        default:
            break
        }
    }
}
