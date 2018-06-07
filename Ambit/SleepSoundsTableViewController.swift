//
//  SoundsTableViewController.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 1/31/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import AudioPlayer
import MediaPlayer

class SleepSoundsTableViewController: UITableViewController {
    
    var thunderstorm: AudioPlayer?
    var thunderstorm_fireplace: AudioPlayer?
    var currentSound: AudioPlayer?
    var selectedMediaItemSound: AudioPlayer?

    var selectedMediaItem: MPMediaItem?
    var mediaPicker: MPMediaPickerController?

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
        
        do {
            thunderstorm = try AudioPlayer(fileName: "thunderstorm.mp3")
            thunderstorm_fireplace = try AudioPlayer(fileName: "thunderstorm_fireplace.mp3")
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
    
    func presentMediaPicker() {
        mediaPicker = MPMediaPickerController(mediaTypes: .music)
        if let picker = mediaPicker {
            picker.allowsPickingMultipleItems = false
            picker.showsCloudItems = false
            picker.showsItemsWithProtectedAssets = false
            picker.prompt = "Please Pick a Song"
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    func playFromMediaSelection(){
        do {
            let mediaUrl = selectedMediaItem?.value(forProperty: MPMediaItemPropertyAssetURL)
            let mediaTitle = selectedMediaItem?.value(forProperty: MPMediaItemPropertyTitle)
            if let url = mediaUrl as? URL {
                selectedMediaItemSound = try AudioPlayer(contentsOf: url)
                currentSound = selectedMediaItemSound
                UserDefaults.standard.set(url, forKey: AmbitConstants.CurrentCustomMediaSleepSoundURL) //setObject
                UserDefaults.standard.set(mediaTitle, forKey: AmbitConstants.CurrentCustomMediaSleepSoundName) //setObject
                UserDefaults.standard.set(mediaTitle, forKey: AmbitConstants.CurrentSleepSoundName) //setObject
                currentSound?.currentTime = 0
                currentSound?.play()
            }
        }
        catch _ {
            // Error handling
            print("Sound initialization failed")
        }
    }
    
    @IBAction func didSelectDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar), object: true)
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stop playing with a fade out
        currentSound?.stop()
        
        let row = indexPath.row
        switch row {
        case 0:
            /// itunes
            presentMediaPicker()
            return
        case 1:
            currentSound = thunderstorm
            UserDefaults.standard.set("Thunderstorm", forKey: AmbitConstants.CurrentSleepSoundName) //setObject
        case 2:
            currentSound = thunderstorm_fireplace
            UserDefaults.standard.set("Thunderstorm Fireplace", forKey: AmbitConstants.CurrentSleepSoundName) //setObject
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            var customMediaSoundName = UserDefaults.standard.string(forKey: AmbitConstants.CurrentCustomMediaSleepSoundName)
            if customMediaSoundName == nil {
                customMediaSoundName = "Select A Song"
            }
            
            let detailCell = tableView.dequeueReusableCell(withIdentifier: "itunesIdentifier", for: indexPath) as! PreferencesDetailTableViewCell
            detailCell.title?.text = "Your iTunes Song"
            detailCell.detail?.text = customMediaSoundName
            detailCell.selectionStyle = .none // to prevent cells from being "highlighted"
            return detailCell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "Thunderstorm"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "Thunderstorm Fireplace"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            return cell
        default:
            break
        }
        
        //default shouldnt hit...
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

extension SleepSoundsTableViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let items = mediaItemCollection.items
        selectedMediaItem = items[0]
        mediaPicker.dismiss(animated: true) {
            self.playFromMediaSelection()
            self.tableView.reloadData()
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}
