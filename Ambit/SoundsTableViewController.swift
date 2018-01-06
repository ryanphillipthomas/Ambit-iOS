//
//  SoundsTableViewController.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 1/31/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import AudioPlayer

class SoundsTableViewController: UITableViewController {
    
    var thunderstorm: AudioPlayer?
    var party: AudioPlayer?
    var thunderstorm_fireplace: AudioPlayer?
    var tickle: AudioPlayer?
    var bell: AudioPlayer?
    
    var currentSound: AudioPlayer?
    var isAlarmSounds: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
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
        
        do {
            thunderstorm = try AudioPlayer(fileName: "thunderstorm.mp3")
            party = try AudioPlayer(fileName: "party.mp3")
            thunderstorm_fireplace = try AudioPlayer(fileName: "thunderstorm_fireplace.mp3")
            tickle = try AudioPlayer(fileName: "tickle.mp3")
            bell = try AudioPlayer(fileName: "bell.mp3")

        }
        catch _ {
            // Error handling
            print("Sound initialization failed")
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: false)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        currentSound?.fadeOut()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stop playing with a fade out
        currentSound?.stop()
        
        let row = indexPath.row
        switch row {
        case 0:
            currentSound = bell
            if (isAlarmSounds) {
                UserDefaults.standard.set("Bell", forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
            } else {
                UserDefaults.standard.set("Bell", forKey: AmbitConstants.CurrentSleepSoundName) //setObject
            }
        case 1:
            currentSound = party
            if (isAlarmSounds) {
                UserDefaults.standard.set("Party", forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
            } else {
                UserDefaults.standard.set("Party", forKey: AmbitConstants.CurrentSleepSoundName) //setObject
            }
        case 2:
            currentSound = tickle
            if (isAlarmSounds) {
                UserDefaults.standard.set("Tickle", forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
            } else {
                UserDefaults.standard.set("Tickle", forKey: AmbitConstants.CurrentSleepSoundName) //setObject
            }
        case 3:
            currentSound = thunderstorm
            if (isAlarmSounds) {
                UserDefaults.standard.set("Thunderstorm", forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
            } else {
                UserDefaults.standard.set("Thunderstorm", forKey: AmbitConstants.CurrentSleepSoundName) //setObject
            }
        case 4:
            currentSound = thunderstorm_fireplace
            if (isAlarmSounds) {
                UserDefaults.standard.set("Thunderstorm Fireplace", forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
            } else {
                UserDefaults.standard.set("Thunderstorm Fireplace", forKey: AmbitConstants.CurrentSleepSoundName) //setObject
            }
        default:
            break
        }
        
        currentSound?.currentTime = 0
        currentSound?.play()
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
