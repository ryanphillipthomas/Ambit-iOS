//
//  ViewController.swift
//  template
//
//  Created by Ryan Phillip Thomas on 12/9/16.
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var timeLabel:SBTimeLabel!
    @IBOutlet weak var timeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.start()
        timeLabel.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeLabel.updateText()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: SBTimeLabelDelegate {
    func didUpdateText(_ label: SBTimeLabel) {
        NSLog("clock: \(timeLabel.text)")
    }
}

