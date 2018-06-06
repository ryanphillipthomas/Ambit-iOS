//
//  LightsTableViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 1/7/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit
//ActiveLightGroupingSettings
class LightsTableViewController: UITableViewController {
    var selections : NSMutableArray = []
    var lights : NSArray = []
    
    func allLights() -> NSArray {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let lightsData = NSMutableDictionary()
        let lightsArray = NSMutableArray()
        if let lights = cache?.lights {
            lightsData.addEntries(from: lights)
            for light in lightsData.allValues {
                let newLight = light as! PHLight
                lightsArray.add(newLight)
            }
        }
        
        //Sort lights by name
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortedResults: NSArray = lightsArray.sortedArray(using: [descriptor]) as NSArray
        
        return sortedResults
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initalize lights
        lights = allLights()
        for light in lights {
            if let light = light as? PHLight {
                // check settings....
                let doesAllow = LightsHelper.lightGroupingAllowsLight(string: light.uniqueId)
                if !doesAllow {
                    selections.add(false)
                } else {
                    selections.add(true)
                }
            }
        }
        
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsSelection = true;

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        LightsHelper.saveLightSettings(selections: selections, lights: lights)
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: false)
        })
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
        
        return lights.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let light = lights[indexPath.row] as! PHLight
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
        cell.title?.text = light.name
        
        let row = indexPath.row
        let selected = selections[row] as! Bool
        
        cell.accessoryType = selected ? .checkmark : .none
        cell.selectionStyle = .none // to prevent cells from being "highlighted"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        let row = indexPath.row
        selections.removeObject(at: row)
        selections.insert(true, at: row)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        
        let row = indexPath.row
        selections.removeObject(at: row)
        selections.insert(false, at: row)
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
