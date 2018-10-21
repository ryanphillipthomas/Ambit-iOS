//
//  SettingsPageViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 10/20/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import StoreKit

class SettingsPageViewController: UIPageViewController {
    var nextPageStoryboardID = "AlarmSoundsNavigationController"
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
        
        disableSwipeGesture()
    }
    
    func disableSwipeGesture() {
        for view in self.view.subviews {
            if view.isKind(of: UIScrollView.self) {
                let scrollView = view as! UIScrollView
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    func enableSwipeGesture() {
        for view in self.view.subviews {
            if view.isKind(of: UIScrollView.self) {
                let scrollView = view as! UIScrollView
                scrollView.isScrollEnabled = true
            }
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
        let pageViewControllerType = PageViewControllerStoryBoardID(rawValue: nextPageStoryboardID)
        switch pageViewControllerType {
        case .none:
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! AlarmSoundsTableViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.backround):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! BackroundTableViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.snooze):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! SnoozeTimeTableViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.sleepSounds):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! SleepSoundsTableViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.prefrences):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! PreferencesTableViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.lightOptions):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! LightsOptionsViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.help):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! HelpViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.credits):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! CreditsViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.lightsTable):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! LightsTableViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.alarmSounds):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! AlarmSoundsTableViewController
            rootView.settingsPageViewController = self
            return nextViewController
        case .some(.weatherNav):
            let nextViewController = digitalStoryboard.instantiateViewController(withIdentifier: nextPageStoryboardID) as! UINavigationController
            let rootView = nextViewController.viewControllers.first as! WeatherSettingsTableViewController
            rootView.settingsPageViewController = self
            return nextViewController
        }
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
    
    ///Asks user for app review
    func displayAppReviewViewController() {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
    }
}

extension SettingsPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            currentPageIndex = index
            pageViewControllerDelegate?.settingsPageViewController(settingsPageViewController: self, didUpdatePageIndex: index)
            if currentPageIndex == 0 {
                disableSwipeGesture()
            }
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
    func updateView()
    
}

extension SettingsPageViewController: AlarmOptionsTableViewControllerDelegate {
    func updateNextViewContorller(_ identifier: String?) {
        if let identifier = identifier {
            nextPageStoryboardID = identifier
            setPageViewControllerForPage()
            enableSwipeGesture()
        }
    }
    
    func presentIntroductionVideo() {
        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        return
    }
    
    func presentAppReviewController() {
        displayAppReviewViewController()
    }
    
    func updateBackroundOption() {
        pageViewControllerDelegate?.updateView()
    }
}
