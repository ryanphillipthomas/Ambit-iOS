//
//  BackroundTableViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 10/20/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit

class BackroundTableViewController: UITableViewController {

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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "Color Animation"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "Image"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "Solid Color"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
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
            UserDefaults.standard.set(BackroundType.animation.rawValue, forKey: AmbitConstants.BackroundType) //setObject
        case 1:
            UserDefaults.standard.set(BackroundType.image.rawValue, forKey: AmbitConstants.BackroundType) //setObject
        case 2:
            UserDefaults.standard.set(BackroundType.color.rawValue, forKey: AmbitConstants.BackroundType) //setObject
        default:
            break
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar), object: true)
        })
    }

}
