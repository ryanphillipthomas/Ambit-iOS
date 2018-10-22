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

protocol AlarmOptionsTableViewControllerDelegate: class {
    func updateNextViewContorller(_ identifier: String?)
    func presentIntroductionVideo()
    func presentAppReviewController()
}

class AlarmOptionsTableViewController: UITableViewController {
    
    
    weak var delegate: AlarmOptionsTableViewControllerDelegate?
    weak var settingsPageViewController: SettingsPageViewController!

    @IBOutlet weak var currentBackroundOptionLabel: UILabel!
    @IBOutlet weak var snoozeTimeDetailLabel: UILabel!
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
        
        func snoozeTimeString(temp: Double) -> String {
            let tempVar = String(format: "%g min", temp / 60)
            return tempVar
        }
        
        let snoozeTime = UserDefaults.standard.double(forKey: AmbitConstants.DefaultSnoozeLength)
        snoozeTimeDetailLabel.text = snoozeTimeString(temp: snoozeTime)
        
        currentBackroundOptionLabel.text = UserDefaults.standard.string(forKey: AmbitConstants.BackroundType)
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
        return 15
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.backround.rawValue)
        case 1:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.snooze.rawValue)
        case 2:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.alarmSounds.rawValue)
        case 3:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.sleepSounds.rawValue)
        case 4:
            //volume cell
            return
        case 5:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.prefrences.rawValue)
        case 6:
            dismiss(animated: true, completion: {
                HueConnectionManager.sharedManager.searchForBridgeLocal()
            })
        case 7:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.lightOptions.rawValue)
        case 8:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.healthNav.rawValue)
        case 9:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.weatherNav.rawValue)

        case 10:
            self.delegate?.presentIntroductionVideo()

        case 11:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.help.rawValue)

        case 12:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.credits.rawValue)

        case 13:
            self.delegate?.presentAppReviewController()
            
        case 14:
            self.delegate?.updateNextViewContorller(PageViewControllerStoryBoardID.lightsTable.rawValue)
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
