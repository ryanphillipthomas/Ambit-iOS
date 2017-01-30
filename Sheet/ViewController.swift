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
        HueConnectionManager.sharedManager.delegate = self
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
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bridgeSelection", let bridgesTableViewController = segue.destination as? HueBridgeSelectionTableViewController {
            let bridgesFound = sender as? [AnyHashable : Any]
            if let bridgesFound = bridgesFound {
                let bridgesData = NSMutableDictionary()
                bridgesData.addEntries(from: bridgesFound)
                bridgesTableViewController.bridgesFound = bridgesData
                bridgesTableViewController.delegate = HueConnectionManager.sharedManager
            }
        } else if segue.identifier == "bridgeAuthentication", let authViewController = segue.destination as? HueBridgeAuthenticationViewController {

        }
    }
}

extension ViewController: SBTimeLabelDelegate {
    func didUpdateText(_ label: SBTimeLabel) {
       // NSLog("clock: \(timeLabel.text)")
    }
}

extension ViewController : HueConnectionManagerDelegate {
    internal func didStartConnecting() {
        AlertHelper.showAlert(title: "Did Start Connecting", controller: self)
    }
    
    internal func didStartSearching() {
        AlertHelper.showAlert(title: "Did Start Searching", controller: self)
    }
    
    internal func didFindBridges(bridgesFound: [AnyHashable : Any]?) {
        AlertHelper.showAlert(title: "Did Find Bridges", controller: self)
        performSegue(withIdentifier: "bridgeSelection", sender: bridgesFound)
    }
    
    internal func didFailToFindBridges() {
        AlertHelper.showAlert(title: "Did Fail To Find Bridges", controller: self)
    }
    
    internal func showPushButtonAuthentication() {
        AlertHelper.showAlert(title: "Should Show Push Button", controller: self)
        performSegue(withIdentifier: "bridgeAuthentication", sender: nil)
    }
}

