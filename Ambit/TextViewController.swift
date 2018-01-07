//
//  TextViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 1/7/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import Foundation

class TextViewController: UIViewController {
    @IBOutlet weak var textView: UITextView?
    override func viewDidLoad() {
        //
    }
    
    @IBAction func didSelectDoneActionButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: false)
        })
    }
}
