//
//  ViewController.swift
//  Stool Tracker
//
//  Created by Malcolm Chalmers on 10/5/18.
//  Copyright © 2018 Malcolm Chalmers. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var poopTable: UITableView!
    
    var sittingsDatesArr = [Date]()
    let dateFormatter = DateFormatter()
    
    @objc func refresh(){
    //    data = [firstArray, ["4","5"]]
        
        //clear table
        
        getData()
        print("refreshed")
        poopTable.reloadData()
        self.refresher.endRefreshing()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sittingsDatesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//        let day = dateFormatter.string(from: sittingsDatesArr[indexPath.row])
//        let calendar = Calendar.current
//        let hours = calendar.component(.hour, from: sittingsDatesArr[indexPath.row])
//        let minutes = calendar.component(.minute, from: sittingsDatesArr[indexPath.row])
//        let time = String(hours) + ":" + String(minutes)
        //print (day + " at " + time)
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let day = dateFormatter.string(from: sittingsDatesArr[indexPath.row])

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let time = dateFormatter.string(from: sittingsDatesArr[indexPath.row])
        
        cell.textLabel?.text = day
        cell.detailTextLabel?.text = time
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func writeData(sitDate: Date) {
        // setup CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newSitting = NSEntityDescription.insertNewObject(forEntityName: "Sittings", into: context)
        
        newSitting.setValue(sitDate, forKey: "date")
        
        do {
            try context.save()
            print ("-----SAVED-----")
        }
        catch {
            print ("XXXXX THERE WAS AN ERROR XXXXXXX")
        }
    }
    
    @IBAction func buttonPress(_ sender: UIButton) {
        
//        let date = Date()
        writeData(sitDate: Date()) //write new sitting to core data

        sittingsDatesArr.removeAll() // erase everything in array
        
        //getData() //reload the array from core data
        
        // refresh the table view
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "pull to refresh")
        
        refresher.addTarget(self, action: #selector(MainViewController.refresh), for: UIControlEvents.valueChanged)
        //poopTable.addSubview(refresher)
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup swipe gesture
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //
    func getData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //get data from CoreData
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sittings")
        
        request.returnsObjectsAsFaults = false
        
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
                print ("database is empty")
            }
        }
        catch {
            print ("error")
        }
    }
}

extension UIViewController {
    
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
