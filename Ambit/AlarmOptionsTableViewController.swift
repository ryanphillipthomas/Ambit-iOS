//
//  AlarmOptionsTableViewController.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 1/31/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

//MARK: step 1 Add Protocol here
protocol AlarmOptionsTableViewControllerDelegate: class {
    func performSegueFromOptions(_ identifier: NSString?)
    func presentIntroductionVideo()
    func presentAppReviewController()
}

class AlarmOptionsTableViewController: UITableViewController {
    
    //MARK: step 2 Create a delegate property here, don't forget to make it weak!
    weak var delegate: AlarmOptionsTableViewControllerDelegate?
    
    @IBOutlet weak var alarmSoundsDetailLabel: UILabel!
    @IBOutlet weak var sleepSoundsDetailLabel: UILabel!
    @IBOutlet weak var hueBridgeDetailLabel: UILabel!
    @IBOutlet weak var lightScenesDetailLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var lightGroupCountLabel: UILabel!
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let selectedValue = Float(sender.value)
        UserDefaults.standard.set(selectedValue, forKey: AmbitConstants.CurrentVolumeLevelName) //setObject
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = true;
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
        
        alarmSoundsDetailLabel.text = UserDefaults.standard.string(forKey: AmbitConstants.CurrentAlarmSoundName)
        sleepSoundsDetailLabel.text = UserDefaults.standard.string(forKey: AmbitConstants.CurrentSleepSoundName)
        hueBridgeDetailLabel.text = UserDefaults.standard.string(forKey: AmbitConstants.CurrentHueBridgeName)
        lightScenesDetailLabel.text = UserDefaults.standard.string(forKey: AmbitConstants.CurrentLightSceneName)
        slider.value = UserDefaults.standard.float(forKey: AmbitConstants.CurrentVolumeLevelName)
        
        //set ligts count
        let activeLights = UserDefaults.standard.mutableArrayValue(forKey: AmbitConstants.ActiveLightGroupingSettings)
        if activeLights.count > 0 {
            lightGroupCountLabel.text = "\(activeLights.count) lights selected"
        } else {
            lightGroupCountLabel.text = "Update lights"
        }
        
        //set app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumberLabel.text = "v \(version)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        return 11
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            dismiss(animated: true, completion: {
                self.delegate?.performSegueFromOptions("alarmSounds")
            })
        case 1:
            dismiss(animated: true, completion: {
                self.delegate?.performSegueFromOptions("sleepSounds")
            })
        case 2:
            //volume cell
            return
        case 3:
            dismiss(animated: true, completion: {
                self.delegate?.performSegueFromOptions("preferencesSegue")
            })
        case 4:
            dismiss(animated: true, completion: {
                HueConnectionManager.sharedManager.searchForBridgeLocal()
            })
        case 5:
            dismiss(animated: true, completion: {
                self.delegate?.performSegueFromOptions("lightOptions")
            })
        case 6:
            dismiss(animated: true, completion: {
                //
                self.delegate?.presentIntroductionVideo()
            })
        case 7:
            dismiss(animated: true, completion: {
                self.delegate?.performSegueFromOptions("helpSegue")
                return
            })
        case 8:
            dismiss(animated: true, completion: {
                self.delegate?.performSegueFromOptions("textViewSegue")
                return
            })
        case 9:
            dismiss(animated: true, completion: {
                self.delegate?.presentAppReviewController()
                return
            })
        case 10:
            dismiss(animated: true, completion: {
                self.delegate?.performSegueFromOptions("showLights")
                return
            })
        default:
            break
        }
    }
    
    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar), object: true)
        })
    }

}
