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

var selectedDate: Date? = nil
var newDate: Date? = nil
let myLog = OSLog(subsystem: "com.malcolmchalmers.ipood", category: "DefaultLog")
var sittingsDatesArr = [Date]()

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var poopTable: UITableView!
    @IBOutlet var myView: UIView!

    let df = DateFormatter()
    let coreData = CoreDataHandler()
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        shareData()
    }
    
    //MARK: Helper Functions
    
    func refresh(){
        // refresh data in the array
        coreData.getData()
        
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
        df.dateStyle = .medium
        df.timeStyle = .none
        let day = df.string(from: sittingsDatesArr[indexPath.row])

        // set date format to time only for right side of cell
        df.dateStyle = .none
        df.timeStyle = .short
        let time = df.string(from: sittingsDatesArr[indexPath.row])
        
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
  
            df.dateStyle = .long
            df.timeStyle = .long
            
            let date = sittingsDatesArr[indexPath.row]
            let context = coreData.getContext()
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
            
            refresh()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDate = sittingsDatesArr[indexPath.row]
        performSegue(withIdentifier: "gotodatepicker", sender: self)
    }
    
    // Handle button press
    @IBAction func buttonPress(_ sender: UIButton) {
        coreData.writeData(sitDate: Date()) //write new sitting to core data
        refresh()
    }
    
//    func buttonPress(_ sender: UIButton) {
//        coreData.writeData(sitDate: Date()) //write new sitting to core data
//        refresh()
//    }
    
    //MARK: Main / View Functions
    
    // fill array before tableView is loaded
    override func viewWillAppear(_ animated: Bool) {
        coreData.getData()
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
        let context = coreData.getContext()
        do {
            try context.save()
            os_log("WRITEDATA: -----SAVED-----", log: myLog, type: .info)
        }
        catch {
            os_log ("XXXXX THERE WAS AN ERROR XXXXXXX", log: myLog, type: .error)
        }
    }
    
    func shareData() {
        var shareString = String()
        var objectsToShare: [Any] = []
        
        df.dateStyle = .medium
        df.timeStyle = .medium
        
        objectsToShare.append("My iPood dates:")
        
        if (sittingsDatesArr.count > 0) {
            for item in sittingsDatesArr {
                shareString = shareString + df.string(from: item)
                objectsToShare.append(df.string(from: item))
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        //Excluded Activities
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        
        activityVC.popoverPresentationController?.sourceView = myView
        self.present(activityVC, animated: true, completion: nil)

    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        
        // Update entry with new date from second view controller
        df.dateStyle = .long
        df.timeStyle = .long
        
        if let firstDate = selectedDate, let secondDate = newDate {
            coreData.updateEntry(oldDate:firstDate, newDate:secondDate)
        } else {
            return
        }
    
        refresh()
    }
    
    func deleteAll(alert: UIAlertAction) {
        if coreData.deleteAllData() {
            os_log("All good", log: myLog, type: .info)
        } else {
            os_log("error deleting data", log: myLog, type: .error)
        }
        
        refresh()
    }
    
    @IBAction func trashBarButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all entries?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: deleteAll ))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
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
