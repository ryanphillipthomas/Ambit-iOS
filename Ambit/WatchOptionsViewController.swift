//
//  WatchOptionsViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 2/19/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

class WatchOptionsViewController: UIViewController {
    fileprivate let food = ["🍦", "🍮", "🍤","🍉", "🍨", "🍏", "🍌", "🍰", "🍚", "🍓", "🍪", "🍕"]

    override func viewDidLoad() {
        super.viewDidLoad()

//        
//        self.view.backgroundColor = UIColor.clear
//        
//        let blurEffect = UIBlurEffect(style: .dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = self.view.frame
//        
//        self.navigationController?.navigationBar.addSubview(blurEffectView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didSelectDoneActionButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: false)
        })
    }
    
    
    
    @IBAction func didSelectActionButton(_ sender: Any) {
        vibrateWatch()
    }
    
    func vibrateWatch() {
        let randomItem = food[Int(arc4random_uniform(UInt32(food.count)))]
        do {
            try WatchSessionManager.sharedManager.updateApplicationContext(["food" : randomItem as AnyObject])
            
            AlertHelper.showAlert(title: "Did Send Ping", controller: self)
        } catch {
            AlertHelper.showAlert(title: "Error Could Not Send Ping", controller: self)
        }
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
