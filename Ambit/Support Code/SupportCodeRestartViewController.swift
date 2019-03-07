//
//  SupportCodeRestartViewController.swift
//  SupportCode
//
//
//  SupportCode.h
//  SupportCode
//
//  Created by Ryan Thomas on 11/20/17.
//  Copyright © 2017 Wheels Up. All rights reserved.

import UIKit

class SupportCodeRestartViewController: UIViewController {
    var enteredCode : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let label = UILabel()
        label.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width - 40, height: view.frame.height)
        label.numberOfLines = 0
        label.textAlignment = .center;
        label.center = view.center
        
        if enteredCode.count > 0 {
            label.text = "\(enteredCode) was entered successfully.\n\n Please restart the application for the changes to take in effect."
        } else {
            label.text = "The current support code was removed successfully, please restart the application for the changes to take in effect."
        }
        
        view.addSubview(label)
        view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
