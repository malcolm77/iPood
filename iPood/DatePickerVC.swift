//
//  SecondViewController.swift
//  Stool Tracker
//
//  Created by Malcolm Chalmers on 10/5/18.
//  Copyright © 2018 Malcolm Chalmers. All rights reserved.
//

import UIKit

class DatePickerVC: UIViewController {
    
    var myDate = Date()
    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var newDatePicker: UIDatePicker!
    
    var df = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let newDate = selectedDate {
            newDatePicker.setDate(newDate, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        newDate = newDatePicker.date
    }


}
