//
//  SoundsTableViewController.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 1/31/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

class PreferencesTableViewController: UITableViewController {
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
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    
    override func viewWillDisappear(_ animated: Bool) {
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

        let row = indexPath.row
        switch row {
        case 0:
            UserDefaults.standard.set(true, forKey: AmbitConstants.VibrateWithAlarmSetting) //setObject
        case 1:
            UserDefaults.standard.set(true, forKey: AmbitConstants.ProgressiveAlarmVolumeSetting) //setObject
        case 2:
            UserDefaults.standard.set(true, forKey: AmbitConstants.AlarmSoundsLightingSetting) //setObject
        case 3:
            UserDefaults.standard.set(true, forKey: AmbitConstants.SleepSoundsLightingSetting) //setObject
        case 4:
            UserDefaults.standard.set(true, forKey: AmbitConstants.RecorderActiveSetting) //setObject
        case 5:
            UserDefaults.standard.set(true, forKey: AmbitConstants.RemindersActiveSetting)
        case 6:
            UserDefaults.standard.set(true, forKey: AmbitConstants.DeepSleepActiveSetting)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none

        let row = indexPath.row
        switch row {
        case 0:
            UserDefaults.standard.set(false, forKey: AmbitConstants.VibrateWithAlarmSetting) //setObject
        case 1:
            UserDefaults.standard.set(false, forKey: AmbitConstants.ProgressiveAlarmVolumeSetting) //setObject
        case 2:
            UserDefaults.standard.set(false, forKey: AmbitConstants.AlarmSoundsLightingSetting) //setObject
        case 3:
            UserDefaults.standard.set(false, forKey: AmbitConstants.SleepSoundsLightingSetting) //setObject
        case 4:
            UserDefaults.standard.set(false, forKey: AmbitConstants.RecorderActiveSetting) //setObject
        case 5:
            UserDefaults.standard.set(false, forKey: AmbitConstants.RemindersActiveSetting)
        case 6:
            UserDefaults.standard.set(false, forKey: AmbitConstants.DeepSleepActiveSetting)
        default:
            break
        }
    }
    
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
        
        let row = indexPath.row
        switch row {
        case 0:
            let selectedSetting = UserDefaults.standard.bool(forKey: AmbitConstants.VibrateWithAlarmSetting)
            cell.title?.text = "Vibrate With Alarm"
            cell.setSelected(selectedSetting, animated: false) //setObject
        case 1:
            let selectedSetting = UserDefaults.standard.bool(forKey: AmbitConstants.ProgressiveAlarmVolumeSetting)
            cell.title?.text = "Progressive Volume"
            cell.setSelected(selectedSetting, animated: false) //setObject
        case 2:
            let selectedSetting = UserDefaults.standard.bool(forKey: AmbitConstants.AlarmSoundsLightingSetting)
            cell.title?.text = "Alarm Sounds Lights"
            cell.setSelected(selectedSetting, animated: false) //setObject
        case 3:
            let selectedSetting = UserDefaults.standard.bool(forKey: AmbitConstants.SleepSoundsLightingSetting)
            cell.title?.text = "Sleep Sounds Lights"
            cell.setSelected(selectedSetting, animated: false) //setObject
        case 4:
            let selectedSetting = UserDefaults.standard.bool(forKey: AmbitConstants.RecorderActiveSetting)
            cell.title?.text = "Microphone Detection"
            cell.setSelected(selectedSetting, animated: false) //setObject
        case 5:
            let selectedSetting = UserDefaults.standard.bool(forKey: AmbitConstants.RemindersActiveSetting)
            cell.title?.text = "Display Reminders"
            cell.setSelected(selectedSetting, animated: false) //setObject
        case 6:
            let selectedSetting = UserDefaults.standard.bool(forKey: AmbitConstants.DeepSleepActiveSetting)
            cell.title?.text = "Enable Deep Sleep"
            cell.setSelected(selectedSetting, animated: false) //setObject
        default:
            break
        }
        
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none // to prevent cells from being "highlighted"
        
        return cell
    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
