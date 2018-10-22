//
//  RemindersViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 10/21/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit

class RemindersViewController: UIViewController {
    var parentMainViewController: ViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didSelectSkip(_ sender: Any) {
        self.dismiss(animated: true) {
            self.parentMainViewController.startAlarm()
        }
    }
}
