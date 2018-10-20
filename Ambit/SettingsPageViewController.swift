//
//  SettingsPageViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 10/20/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit

class SettingsPageViewController: UIPageViewController {
    var nextPageStoryboardID = String(describing: AlarmSoundsTableViewController.self)
    var currentPageIndex: Int!
    weak var pageViewControllerDelegate:SettingsPageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        currentPageIndex = 0
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.alarmOptionsNavigationController(),
                self.nextViewController()]
    }()
    
    private func alarmOptionsNavigationController() -> UINavigationController {
        let digitalStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let alarmOptionsNavigationController = digitalStoryboard.instantiateViewController(withIdentifier: "AlarmOptionsNavigationController") as! UINavigationController
        let alarmOptions = alarmOptionsNavigationController.viewControllers.first as? AlarmOptionsTableViewController
        alarmOptions?.delegate = self
        return alarmOptionsNavigationController
    }
    
    private func nextViewController() -> UIViewController {
        let digitalStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID)
        return nextViewController
    }
}

extension SettingsPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func setPageViewControllerForPage() {
        let direction: UIPageViewController.NavigationDirection = .forward
        orderedViewControllers = [self.alarmOptionsNavigationController(),
                                  self.nextViewController()]
        setViewControllers([orderedViewControllers[1]], direction: direction, animated: true, completion: nil)
    }
}

extension SettingsPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            currentPageIndex = index
            pageViewControllerDelegate?.settingsPageViewController(settingsPageViewController: self, didUpdatePageIndex: index)
        }
    }
}

protocol SettingsPageViewControllerDelegate: class {
    /**
     Called when the current index is updated.
     - parameter index: the index of the currently visible page.
     */
    func settingsPageViewController(settingsPageViewController: SettingsPageViewController,
                                                     didUpdatePageIndex index: Int)
    
}

extension SettingsPageViewController: AlarmOptionsTableViewControllerDelegate {
    func updateNextViewContorller(_ identifier: String?) {
        if let identifier = identifier {
            nextPageStoryboardID = identifier
            setPageViewControllerForPage()
        }
    }
    
    func presentIntroductionVideo() {
//        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
//        let player = AVPlayer(url: videoURL!)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        self.present(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }
//        return
    }
    
    func presentAppReviewController() {
//        displayAppReviewViewController()
    }
}
