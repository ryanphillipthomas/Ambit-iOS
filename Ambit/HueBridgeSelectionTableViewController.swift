//
//  HueBridgeSelectionTableViewController.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 1/30/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

protocol HueBridgeSelectionTableViewControllerDelegate: class {
    func bridgeSelectedWithIpAddress(ipAddress:String, bridgeId:String)
}

class HueBridgeSelectionTableViewController: UITableViewController {
    var bridgesFound:NSMutableDictionary?
    weak var delegate:HueBridgeSelectionTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Available SmartBridges"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        self.tableView.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        self.tableView.backgroundView = blurEffectView
        self.navigationController?.navigationBar.addSubview(blurEffectView)
        
        self.tableView.allowsSelection = true;

        let refreshButton = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(self.refresh))
         self.navigationItem.leftBarButtonItem = refreshButton
    }
    
    @objc func refresh() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        HueConnectionManager.sharedManager.searchForBridgeLocal()
    }
    
    @IBAction func done(sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
        if let bridgesFound = bridgesFound {
            return bridgesFound.count
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let bridgesFound = bridgesFound {
            // Sort bridges by bridge id
            let arraySorted = bridgesFound.allKeys.sorted() { ($0 as! Int) < ($1 as! Int) }
            
            // Get mac address and ip address of selected bridge
            let bridgeID = arraySorted[indexPath.row] as? String
            let ip = bridgesFound.object(forKey: bridgeID) as? String
            
            if let bridgeID = bridgeID, let ip = ip {
                cell.textLabel?.text = bridgeID
                cell.detailTextLabel?.text = ip
            }
        }
            
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let bridgesFound = bridgesFound {
            // Sort bridges by bridge id

            let arraySorted = bridgesFound.allKeys.sorted() { ($0 as! Int) < ($1 as! Int) }
            
            // Get mac address and ip address of selected bridge
            let bridgeID = arraySorted[indexPath.row] as? String
            let ip = bridgesFound.object(forKey: bridgeID) as? String
            
            // Inform delegate
            if let bridgeID = bridgeID, let ip = ip {
                dismiss(animated: true, completion: {
                    UserDefaults.standard.set(ip, forKey: AmbitConstants.CurrentHueBridgeName) //setObject
                    self.delegate?.bridgeSelectedWithIpAddress(ipAddress: ip, bridgeId: bridgeID)
                })
            }
        }
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
