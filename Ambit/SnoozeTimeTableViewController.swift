//
//  SnoozeTimeTableViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 10/20/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit

class SnoozeTimeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
    }
    
    func snoozeTimeString(temp: Double) -> String {
        let tempVar = String(format: "%g min", temp / 60)
        return tempVar
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let snoozeLength = UserDefaults.standard.double(forKey: AmbitConstants.DefaultSnoozeLength)
        let snoozeLengthString = snoozeTimeString(temp: snoozeLength)
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "1 minute"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "1 min" {
                cell.accessoryType = .checkmark
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "2 min"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "2 min" {
                cell.accessoryType = .checkmark
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "3 minutes"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "3 min" {
                cell.accessoryType = .checkmark
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "5 minutes"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "5 min" {
                cell.accessoryType = .checkmark
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "7 minutes"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "7 min" {
                cell.accessoryType = .checkmark
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "9 minutes"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "9 min" {
                cell.accessoryType = .checkmark
            }
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "10 minutes"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "10 min" {
                cell.accessoryType = .checkmark
            }
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "15 minutes"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "15 min" {
                cell.accessoryType = .checkmark
            }
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "20 minutes"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            cell.accessoryType = .none
            
            if snoozeLengthString == "20 min" {
                cell.accessoryType = .checkmark
            }
            return cell
        default:
            break
        }
        
        //default
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 0:
            UserDefaults.standard.set(60*1, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        case 1:
            UserDefaults.standard.set(60*2, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        case 2:
            UserDefaults.standard.set(60*3, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        case 3:
            UserDefaults.standard.set(60*5, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        case 4:
            UserDefaults.standard.set(60*7, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        case 5:
            UserDefaults.standard.set(60*9, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        case 6:
            UserDefaults.standard.set(60*10, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        case 7:
            UserDefaults.standard.set(60*15, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        case 8:
            UserDefaults.standard.set(60*20, forKey: AmbitConstants.DefaultSnoozeLength) //setObject
        default:
            break
        }
        self.tableView.reloadData()
    }
    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar), object: true)
        })
    }
}
