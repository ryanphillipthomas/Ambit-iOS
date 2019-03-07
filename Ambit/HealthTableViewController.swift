//
//  HealthTableViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 10/21/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI

class HealthTableViewController: UITableViewController {
    weak var settingsPageViewController: SettingsPageViewController!
    var isSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tableView.allowsMultipleSelection = true
        
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
        
        self.tableView.allowsSelection = true;
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedSetting = UserDefaults.standard.bool(forKey: AmbitConstants.HealthActiveSetting)
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
        cell.title?.text = "Use Apple Health"
        cell.setSelected(selectedSetting, animated: false) //setObject
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none // to prevent cells from being "highlighted"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        let row = indexPath.row
        switch row {
        case 0:
            UserDefaults.standard.set(true, forKey: AmbitConstants.HealthActiveSetting) //setObject
            
            if HKHealthStore.isHealthDataAvailable() {
                // Add code to use HealthKit here.
                let healthStore = HKHealthStore()
                let allTypes = Set([HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
                                    HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                    HKObjectType.quantityType(forIdentifier: .heartRate)!])
//                let hasHeartRate = healthStore.authorizationStatus(for: [HKObjectType.quantityType(forIdentifier: .heartRate)])
                
                healthStore.requestAuthorization(toShare: allTypes as? Set<HKSampleType>, read: allTypes as? Set<HKObjectType>) { (success, error) in
                    if !success {
                        // Handle the error here.
                        
                    }
                }
            }
            
            
        default:
            break
        }
    }
    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        setPageViewControllerForIndex(0)
    }
    
    func setPageViewControllerForIndex(_ index: Int) {
        let direction: UIPageViewController.NavigationDirection = .reverse
        let viewController = settingsPageViewController.orderedViewControllers[index]
        let isAnimated = (viewController != settingsPageViewController.viewControllers?.first)
        settingsPageViewController.setViewControllers([viewController], direction: direction, animated: isAnimated, completion: nil)
    }
}
