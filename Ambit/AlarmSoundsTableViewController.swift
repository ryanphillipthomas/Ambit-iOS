//
//  SoundsTableViewController.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 1/31/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import AudioPlayer
import StoreKit
import MediaPlayer

class AlarmSoundsTableViewController: UITableViewController {
    
    var party: AudioPlayer?
    var tickle: AudioPlayer?
    var bell: AudioPlayer?
    var selectedMediaItemSound: AudioPlayer?
    let applicationMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    var currentSound: AudioPlayer?

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
            party = try AudioPlayer(fileName: "party.mp3")
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar), object: true)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        currentSound?.fadeOut()
        applicationMusicPlayer.stop()
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
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stop playing with a fade out
        currentSound?.stop()
        applicationMusicPlayer.stop()
        
        let row = indexPath.row
        switch row {
        case 0:
            //itunes
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback, mode: .default, policy: .default, options: .allowAirPlay)
                
                checkMusicStatus()
            }
            catch {
                print("Setting category to AVAudioSessionCategoryPlayback failed.")
            }
            
            presentMediaPicker()
            return
        case 1:
            currentSound = bell
            UserDefaults.standard.set("Bell", forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
        case 2:
            currentSound = party
            UserDefaults.standard.set("Party", forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
        case 3:
            currentSound = tickle
            UserDefaults.standard.set("Tickle", forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
        default:
            break
        }
        
        currentSound?.currentTime = 0
        currentSound?.play()
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func checkMusicStatus() {
        
        switch SKCloudServiceController.authorizationStatus() {
            
        case .authorized:
            
            print("The user's already authorized - we don't need to do anything more here, so we'll exit early.")
            return
            
        case .denied:
            
            print("The user has selected 'Don't Allow' in the past - so we're going to show them a different dialog to push them through to their Settings page and change their mind, and exit the function early.")
            
            // Show an alert to guide users into the Settings
            
            return
            
        case .notDetermined:
            
            print("The user hasn't decided yet - so we'll break out of the switch and ask them.")
            break
            
        case .restricted:
            
            print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")
            return
            
        }
        
        appleMusicRequestPermission()
    }
    
    // Request permission from the user to access the Apple Music library
    func appleMusicRequestPermission() {
        
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            
            switch status {
                
            case .authorized:
                
                print("All good - the user tapped 'OK', so you're clear to move forward and start playing.")
                
            case .denied:
                
                print("The user tapped 'Don't allow'. Read on about that below...")
                
            case .notDetermined:
                
                print("The user hasn't decided or it's not clear whether they've confirmed or denied.")
                
            case .restricted:
                
                print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")
                
            }
            
        }
        
    }
    
    func playFromMusicPlayerSelection(_ ids: [String]) {
        applicationMusicPlayer.setQueue(with: ids)
        applicationMusicPlayer.play()
    }
    
    func playFromMediaSelection(){
        do {
            let mediaID = selectedMediaItem?.playbackStoreID
            let mediaUrl = selectedMediaItem?.value(forProperty: MPMediaItemPropertyAssetURL)
            let mediaTitle = selectedMediaItem?.value(forProperty: MPMediaItemPropertyTitle)
            if let url = mediaUrl as? URL {
                selectedMediaItemSound = try AudioPlayer(contentsOf: url)
                currentSound = selectedMediaItemSound
                UserDefaults.standard.set(url, forKey: AmbitConstants.CurrentCustomMediaAlarmSoundURL) //setObject
                UserDefaults.standard.set(mediaTitle, forKey: AmbitConstants.CurrentCustomMediaAlarmSoundName) //setObject
                UserDefaults.standard.set(mediaTitle, forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
                currentSound?.currentTime = 0
                currentSound?.play()
            } else if (selectedMediaItem?.hasProtectedAsset)!, let mediaID = mediaID {
                //asset is protected
                //Must be played only via MPMusicPlayer
                currentSound = selectedMediaItemSound
                UserDefaults.standard.set(mediaID, forKey: AmbitConstants.CurrentCustomMediaAlarmSoundID) //setObject
                UserDefaults.standard.set(nil, forKey: AmbitConstants.CurrentCustomMediaAlarmSoundURL) //setObject
                UserDefaults.standard.set(mediaTitle, forKey: AmbitConstants.CurrentCustomMediaAlarmSoundName) //setObject
                UserDefaults.standard.set(mediaTitle, forKey: AmbitConstants.CurrentAlarmSoundName) //setObject
                playFromMusicPlayerSelection([mediaID])
            }
        }
        catch _ {
            // Error handling
            print("Sound initialization failed")
        }
    }
    
    func presentMediaPicker() {
        mediaPicker = MPMediaPickerController(mediaTypes: .music)
        if let picker = mediaPicker {
            picker.allowsPickingMultipleItems = false
            picker.showsCloudItems = false
            picker.showsItemsWithProtectedAssets = true
            picker.prompt = "Please Pick a Song"
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        switch row {
        case 0:
            var customMediaSoundName = UserDefaults.standard.string(forKey: AmbitConstants.CurrentCustomMediaAlarmSoundName)
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
            cell.title?.text = "Bell"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "Party"
            cell.selectionStyle = .none // to prevent cells from being "highlighted"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! PreferencesTableViewCell
            cell.title?.text = "Tickle"
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
}


extension AlarmSoundsTableViewController: MPMediaPickerControllerDelegate {
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
