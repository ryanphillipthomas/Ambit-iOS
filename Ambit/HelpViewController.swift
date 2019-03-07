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
    weak var settingsPageViewController: SettingsPageViewController!

    override func viewDidLoad() {
        let url = URL(string: "https://neybox.com/pillow-sleep-tracker-en-old/pillow-privacy-policy-en")
        if let urlString = url {
            let request = URLRequest(url: urlString)
            webView?.loadRequest(request)
        }
    }
    
    func setPageViewControllerForIndex(_ index: Int) {
        let direction: UIPageViewController.NavigationDirection = .reverse
        let viewController = settingsPageViewController.orderedViewControllers[index]
        let isAnimated = (viewController != settingsPageViewController.viewControllers?.first)
        settingsPageViewController.setViewControllers([viewController], direction: direction, animated: isAnimated, completion: nil)
    }
    
    @IBAction func didSelectDoneActionButton(_ sender: Any) {
        setPageViewControllerForIndex(0)
    }
}
