//
//  HelpViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 1/6/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import Foundation

class HelpViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView?
    
    override func viewDidLoad() {
        let url = URL(string: "https://support.apple.com/itunes")
        if let urlString = url {
            let request = URLRequest(url: urlString)
            webView?.loadRequest(request)
        }
    }
    
    @IBAction func didSelectDoneActionButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar), object: false)
        })
    }
}
