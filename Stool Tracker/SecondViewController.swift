//
//  SecondViewController.swift
//  Stool Tracker
//
//  Created by Malcolm Chalmers on 10/5/18.
//  Copyright © 2018 Malcolm Chalmers. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    var myDate = Date()
    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var newDatePicker: UIDatePicker!
    
    var df = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let newDate = selectedDateString
//        testLabel.text = newDate
        
//        df.dateStyle = .short
//        df.timeStyle = .medium
//
//        df.dateFormat = "MM/dd/yy, h:mm:ss aa"                          // 7/6/06, 1:55:00 AM
//        if let myDate = df.date(from: selectedDateString) {
//            newDatePicker.setDate(myDate, animated: false) }
//        else {
//            print("--------error-------")
//        }
        
        if let newDate = selectedDate {
            newDatePicker.setDate(newDate, animated: false)
        }
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let mainVC = segue.destination as! MainViewController
//        mainVC.newDate = newDatePicker.date
//        mainVC.selectedDate = newDatePicker.date
        newDate = newDatePicker.date
    }


}
