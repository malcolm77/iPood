//
//  SecondViewController.swift
//  Stool Tracker
//
//  Created by Malcolm Chalmers on 10/5/18.
//  Copyright © 2018 Malcolm Chalmers. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    //var selectedDate = Date()
    
    @IBOutlet weak var testLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newDate = selectedDateString
        testLabel.text = newDate
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation


}
