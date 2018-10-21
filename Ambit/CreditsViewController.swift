//
//  CreditsViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 1/7/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import Foundation

class CreditsViewController: UIViewController {
    weak var settingsPageViewController: SettingsPageViewController!

    @IBOutlet weak var textView: UITextView?
    override func viewDidLoad() {
        //
    }
    
    @IBAction func didSelectDoneActionButton(_ sender: Any) {
        setPageViewControllerForIndex(0)
    }
    
    func setPageViewControllerForIndex(_ index: Int) {
        let direction: UIPageViewController.NavigationDirection = .reverse
        let viewController = settingsPageViewController.orderedViewControllers[index]
        let isAnimated = (viewController != settingsPageViewController.viewControllers?.first)
        settingsPageViewController.setViewControllers([viewController], direction: direction, animated: isAnimated, completion: nil)
    }
}
