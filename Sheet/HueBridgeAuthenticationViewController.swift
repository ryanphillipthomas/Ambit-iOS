//
//  HueBridgeAuthenticationViewController.swift
//  Sheet
//
//  Created by Ryan Phillip Thomas on 1/30/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

protocol HueBridgeAuthenticationViewControllerDelegate: class {
    func pushLinkSuccess()
    func pushlinkFailed(error:PHError)
}


class HueBridgeAuthenticationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
