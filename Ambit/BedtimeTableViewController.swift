//
//  BedtimeTableViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 11/4/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit

class BedtimeTableViewController: UITableViewController {
    weak var settingsPageViewController: SettingsPageViewController!
    @IBOutlet weak var timePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        
        if (!UIAccessibility.isReduceTransparencyEnabled) {
            tableView.backgroundColor = UIColor.clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            tableView.backgroundView = blurEffectView
            
            //if inside a popover
            if let popover = navigationController?.popoverPresentationController {
                popover.backgroundColor = UIColor.clear
            }
            
            //if you want translucent vibrant table view separator lines
            tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        }
        
        self.tableView.tableFooterView = UIView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func schedule(forDate date: Date) {
        AlarmScheduleManager.sharedManager.clearAllBedtimeAlarms()
        AlarmScheduleManager.sharedManager.scheduleBedtimeNotification(fireDate: date, interval: 0)
        
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        
        UserDefaults.standard.set(df.string(from: date), forKey: AmbitConstants.CurrentBedTimeDate) //setObject
    }
    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        schedule(forDate: timePicker.date)
        setPageViewControllerForIndex(0)
    }
    
    func setPageViewControllerForIndex(_ index: Int) {
        let direction: UIPageViewController.NavigationDirection = .reverse
        let viewController = settingsPageViewController.orderedViewControllers[index]
        let isAnimated = (viewController != settingsPageViewController.viewControllers?.first)
        settingsPageViewController.setViewControllers([viewController], direction: direction, animated: isAnimated, completion: nil)
    }

}
