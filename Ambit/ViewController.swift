//
//  ViewController.swift
//  template
//
//  Created by Ryan Phillip Thomas on 12/9/16.
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import UIKit
import Spring
import CoreData
import UserNotifications
import EventKit

import AudioPlayer
import AVFoundation
import MediaPlayer
import AVKit
import StoreKit

class ViewController: UIViewController, ManagedObjectContextSettable {    
    @IBOutlet var timeLabel:SBTimeLabel!
    @IBOutlet var timeLeftLabel:UILabel!
    @IBOutlet var timeUpcomingLabel: UILabel!

    @IBOutlet var timePicker:UIDatePicker!
    @IBOutlet var settingsButton:UIButton!
    
    @IBOutlet weak var fullScreenBlackoutView: SpringView!
    @IBOutlet weak var timeLabelAnimationView: SpringView!
    @IBOutlet weak var settingsButtonAnimationView: SpringView!
    @IBOutlet weak var timePickerAnimationView: SpringView!
    @IBOutlet weak var nextAlarmAnimationView: SpringView!
    @IBOutlet weak var stopAnimationView: SpringView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var snoozeView: SpringView!
    
    @IBOutlet weak var containerView: UIView!
    weak var tableViewController:UITableViewController!
    weak var tableView: UITableView!

    var backroundAnimation = CAGradientLayer()
    var managedObjectContext: NSManagedObjectContext!
    
    var currentSound: AudioPlayer?
    var currentSleepSound: AudioPlayer?

    var audioPlayer : AVAudioPlayer!
    
    var isPlayingOverride : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.updateText()
        timeLabel.start()
        timeLabel.delegate = self
        
        HueConnectionManager.sharedManager.delegate = self
        backroundAnimation = GradientHandler.addGradientLayer()
        GradientViewHelper.addGradientColorsToView(view: self.view, gradientLayer: backroundAnimation)
        
        timeLabelAnimationView.isHidden = true
        nextAlarmAnimationView.isHidden = true
        stopAnimationView.isHidden = true
        snoozeView.isHidden = true
//        dimView.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleStatusBar(notification:)), name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: nil)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didSnooze(gesture:)))
//        snoozeView.addGestureRecognizer(tap)
//        snoozeView.isUserInteractionEnabled = true

        timePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .minute, value: 1, to: Date())
        timePicker.minimumDate = date
        
//        dimView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.dimViewFadeGesture(gesture:))))

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateRunningAlarmUI()
    }
    
    override func viewDidLayoutSubviews() {
        backroundAnimation.frame = self.view.bounds
    }
    
    @IBAction func pickerValueChanged(_ sender: Any) {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .minute, value: 1, to: Date())
        timePicker.minimumDate = date
    }
    
    func isPlayingSound() -> Bool {
        if isPlayingOverride { return true }
        
        guard let currentSound = self.currentSound else { return false }
        return currentSound.isPlaying
    }
    
    func playSleepSound() {
        
        if isPlayingSound() { return }
        
        //get sound file name and load it up
        do {
            let userSoundFile = UserDefaults.standard.string(forKey: AmbitConstants.CurrentSleepSoundName)
            let soundFile = StringHelper.soundFileForName(string: userSoundFile!)
            if let file = soundFile {
                currentSound = try AudioPlayer(fileName: file)
            } else {
                let customMediaSoundURL = UserDefaults.standard.url(forKey: AmbitConstants.CurrentCustomMediaSleepSoundURL)
                currentSound = try AudioPlayer(contentsOf: customMediaSoundURL as! URL)
            }
        }
        catch _ {
            // Error handling
            print("Sound initialization failed")
        }
        let volumeLevel = UserDefaults.standard.float(forKey: AmbitConstants.CurrentVolumeLevelName)
        currentSound?.volume = volumeLevel
        currentSound?.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   @IBAction func dimViewFadeGesture(gesture: UIPanGestureRecognizer) {
        print("Pan Dim The View")
        
        var lastPosition : CGPoint = CGPoint(x: 0, y: 0)
        var nowPosition : CGPoint = CGPoint(x: 0, y: 0)
        var alpha : CGFloat = 0.0
        var new_alpha : CGFloat = 0.0
        
        nowPosition = gesture.translation(in: self.view)
        alpha = self.dimView.alpha
        
        if (nowPosition.y > lastPosition.y) {
            new_alpha = min(alpha + 0.02,1.0)
            if new_alpha == 1 {new_alpha = 0.99}
            print("\(new_alpha)")
            self.dimView.alpha = new_alpha
        }
        else if (nowPosition.y < lastPosition.y) {
            new_alpha = max(alpha - 0.02,0)
            if new_alpha == 0 {new_alpha = 0.01}
            print("\(new_alpha)")
            self.dimView.alpha = new_alpha
        }
        else {
            print("Neither")
        }

        lastPosition = nowPosition
    }
    
    @objc func fadeToBlack() {
        //fade out lights
        self.blackOut()
       
        //show the stop button
        self.animateInStopButton()
        
        //timeLabel to white
        UIView.transition(with: self.timeLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
            self.timeUpcomingLabel.textColor = UIColor.white
            self.timeLabel.textColor = UIColor.white
        }) { (finished) in

            //timeLabel to grey
            UIView.transition(with: self.timeLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                self.timeUpcomingLabel.textColor = UIColor.darkGray
                self.timeLabel.textColor = UIColor.darkGray
            }, completion: nil)
        }

        blackoutFullscreenView()
    }
    
    func blackoutFullscreenView() {
        //fullScreenBlackoutView to black
        UIView.animate(withDuration: 3.0, animations: {
            self.fullScreenBlackoutView.backgroundColor = UIColor.black
        }) { (finished) in
            
            //remove back animation view
            self.removeAnimation()
        }
    }
    
    func removeAnimation() {
        self.view.layer.sublayers?.remove(at: 0)
    }
    
    @objc func fadeToClear() {
        //fade to clear
        self.view.layer.insertSublayer(backroundAnimation, at: 0)
        
        UIView.transition(with: self.timeLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.timeUpcomingLabel.textColor = UIColor.black
            self.timeLabel.textColor = UIColor.black
        }, completion: nil)

        UIView.animate(withDuration: 1.0) {
            self.fullScreenBlackoutView.backgroundColor = UIColor.clear
        }
        
        //fullScreenBlackoutView to black
        UIView.animate(withDuration: 1.0, animations: {
            self.fullScreenBlackoutView.backgroundColor = UIColor.clear
        }) { (finished) in
            self.lightsOn()
        }
    }
    
    func updateRunningAlarmUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let alarm = Alarm.fetchCurrentAlarm(moc: managedObjectContext)

        guard let scheduleAlarm = alarm else {
            timeLeftLabel.text = ""
            timeUpcomingLabel.text = ""
            return
        }
        let currentDate = Date()
        var hour_min_string = ""
        if currentDate > scheduleAlarm.fireDate {
            hour_min_string = StringHelper.pastTimeString(for: scheduleAlarm.fireDate)
        } else {
            hour_min_string = StringHelper.futureTimeString(for: scheduleAlarm.fireDate)
        }
        
        NSLog("fire date: \(hour_min_string)")

        timeUpcomingLabel.text = hour_min_string
        
        let next_alarm_string = StringHelper.nextAlarmString(alarmDate: scheduleAlarm.fireDate)
        timeLeftLabel.text = next_alarm_string
        
        //show snooze button and view
        if appDelegate.isPlayingSound() {
            animateOutTimeDisplayLayers()
            animateInSnoozeButton() //show the snooze button
            self.perform(#selector(self.fadeToClear), with: nil, afterDelay: 0.4) //fade in the color backround in 0.4 secs
            
            //stop sleep sounds if playing
            currentSound?.stop()
        }
    }
    
    func animateInTimeOnlyDisplayLayers() {
        timeLabelAnimationView.isHidden = false
        timeLabelAnimationView.animation = "fadeInDown"
        timeLabelAnimationView.curve = "linear"
        timeLabelAnimationView.duration = 2.0
        timeLabelAnimationView.animate()
    }
    
    
    func animateInTimeDisplayLayers() {
        timeLabelAnimationView.isHidden = false
        nextAlarmAnimationView.isHidden = false

        nextAlarmAnimationView.animation = "fadeInDown"
        nextAlarmAnimationView.curve = "linear"
        nextAlarmAnimationView.duration = 2.0
        nextAlarmAnimationView.animate()
        
        timeLabelAnimationView.animation = "fadeInDown"
        timeLabelAnimationView.curve = "linear"
        timeLabelAnimationView.duration = 2.0
        timeLabelAnimationView.animate()
    }
    
    func animateInSnoozeButton () {
        if snoozeView.isHidden == true {
            snoozeView.isHidden = false
            snoozeView.animation = "zoomIn"
            snoozeView.curve = "easeIn"
            snoozeView.duration = 1.0
            snoozeView.animate()
        }
    }
    
    func animateOutSnoozeButton () {
        snoozeView.isHidden = true

        snoozeView.animation = "zoomOut"
        snoozeView.curve = "easeIn"
        snoozeView.duration = 1.0
        snoozeView.animate()
    }
    
    func animateInStopButton () {
        if stopAnimationView.isHidden == true {
            stopAnimationView.isHidden = false
    //        dimView.isHidden = false

            stopAnimationView.animation = "fadeInUp"
            stopAnimationView.curve = "linear"
            stopAnimationView.duration = 2.0
            stopAnimationView.animate()
        }
    }
    
    func animateOutTimeDisplayLayers() {
        nextAlarmAnimationView.animation = "fadeOutDown"
        nextAlarmAnimationView.curve = "linear"
        nextAlarmAnimationView.duration = 2.0
        nextAlarmAnimationView.animate()
        
        timeLabelAnimationView.animation = "fadeOutDown"
        timeLabelAnimationView.curve = "linear"
        timeLabelAnimationView.duration = 2.0
        timeLabelAnimationView.animate()
        
        timeLabelAnimationView.isHidden = true
        nextAlarmAnimationView.isHidden = true
//        dimView.isHidden = true
    }
    
    func animateOutStopButton() {
        
        stopAnimationView.animation = "fadeOutUp"
        stopAnimationView.curve = "linear"
        stopAnimationView.duration = 2.0
        stopAnimationView.animate()
        
        stopAnimationView.isHidden = true
    }
    
    func animateInTimePickerLayers() {
        timePickerAnimationView.isHidden = false
        settingsButtonAnimationView.isHidden = false
        
        timePickerAnimationView.animation = "fadeInDown"
        timePickerAnimationView.curve = "linear"
        timePickerAnimationView.duration = 2.0
        timePickerAnimationView.animate()
        
        settingsButtonAnimationView.animation = "fadeInUp"
        settingsButtonAnimationView.curve = "linear"
        settingsButtonAnimationView.duration = 2.0
        settingsButtonAnimationView.animate()
    }
    
    func animateOutTimePickerLayers() {
        timePickerAnimationView.animation = "fadeOut"
        timePickerAnimationView.curve = "linear"
        timePickerAnimationView.duration = 1.0
        timePickerAnimationView.animate()
        
        settingsButtonAnimationView.animation = "fadeOut"
        settingsButtonAnimationView.curve = "linear"
        settingsButtonAnimationView.duration = 1.0
        settingsButtonAnimationView.animate()
        
        timePickerAnimationView.isHidden = true
        settingsButtonAnimationView.isHidden = true
    }
    
    func configurePickerView() {
//        timePicker.date = UIDatePickerMode.Time // 4- use time only
//        let currentDate = NSDate()  //5 -  get the current date
//        myDatePicker.minimumDate = currentDate  //6- set the current date/time as a minimum
//        myDatePicker.date = currentDate //7 - defa
    }
    
    
    //Donate Alarm Activity
    var historicalAlarmUserActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: "com.ryanphillipthomas.ambit.my-activity-type")
        userActivity.requiredUserInfoKeys = ["alarmTime"]
        userActivity.isEligibleForSearch = true
        userActivity.title = "Alarm"
        userActivity.userInfo = ["key":"value"]
        if #available(iOS 12.0, *) {
            userActivity.isEligibleForPrediction = true
        } else {
            // Fallback on earlier versions
        }
        return userActivity
    }
    
//    override func updateUserActivityState(_ activity: NSUserActivity) {
//        return nil
//    }
    

    
    @IBAction func stopAlarm(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopCurrentSound()
        
        self.fadeToClear()
        self.animateOutTimeDisplayLayers()
        self.animateOutStopButton()
        self.animateInTimePickerLayers()
        self.animateOutSnoozeButton()
        
        //stop sleep sounds if playing
        currentSound?.stop()
    }
    
    @IBAction func didSnooze(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopCurrentSound()
        
        //start fading black frame
        self.perform(#selector(self.fadeToBlack), with: nil, afterDelay: 3.0)
        
        //generate date in 1 min
        let now = Date()
        let dateInFifteenMinutes = now.addingTimeInterval(60*1)
        addAlarmFromTimePicker(date:dateInFifteenMinutes)
        
        animateOutSnoozeButton()
        animateInTimeDisplayLayers()
    }
    
    @IBAction func toggleSettings(_ sender: Any) {
        performSegue(withIdentifier: "alarmOptions", sender: nil)
    }
    
    @IBAction func toggleUpcoming(_ sender: Any) {
        performSegue(withIdentifier: "upcomingEvents", sender: nil)
    }
    
    @IBAction func toggleWatch(_ sender: Any) {
        performSegue(withIdentifier: "watchOptions", sender: nil)
    }

    @IBAction func toggleLights(_ sender: Any) {
        performSegue(withIdentifier: "lightOptions", sender: nil)
    }


    func addAlarmFromTimePicker(date:Date? = nil) {
        //create new alarm attributes
        let id = UUID().uuidString
        var fireDate = timePicker.date
        fireDate = Date.init(timeInterval: 0, since: fireDate) //alarms go off at the top of the hour

        if (date != nil) { fireDate = date! }
        let alarmDictionary:[String : Any] = ["id": id,
                                              "fireDate": fireDate,
                                              "name": "unnamed",
                                              "enabled" : true,
                                              "mediaID" : "",
                                              "mediaLabel" : "tickle.mp3",
                                              "snoozeEnabled" : true]
        
        //create the alarm
        _ = Alarm.insertIntoContext(moc: managedObjectContext, alarmDictionary: alarmDictionary as NSDictionary)
        
        //get the alarm and provide it to our sceduler
        let alarm = Alarm.fetchCurrentAlarm(moc: managedObjectContext)
        guard let scheduleAlarm = alarm else {return}
        print(scheduleAlarm.fireDate)
        
        RecorderManager.sharedManager.startRecording()

//        //get the apple watch to vibrate
        scheduleLocalNotifications(scheduleAlarm: scheduleAlarm)
    }
    
    func scheduleLocalNotifications(scheduleAlarm : Alarm) {
        //get the apple watch to vibrate
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 0)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 5)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 10)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 15)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 20)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 25)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 30)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 35)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 40)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 45)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 50)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 55)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 60)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 65)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 70)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 75)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 80)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 85)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 90)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 95)
//        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 100)
    }
    
    @IBAction func showCurrentClock(_sender: Any){
        //update label with alarm
        updateRunningAlarmUI()
        
        //animaite out time picker
        self.animateOutTimePickerLayers()
        
        //animaite out time picker
        animateInTimeOnlyDisplayLayers()
        
        animateInStopButton()
    }
    
    @IBAction func exitCurrentClock(_sender: Any){
        //??
    }
    
    
    @IBAction func startClock(_ sender: Any) {

        //create new alarm from time picker
        addAlarmFromTimePicker()
        
        //animaite out time picker
        self.animateOutTimePickerLayers()
        
        //animaite out time picker
        animateInTimeDisplayLayers()

        //update label with alarm
        updateRunningAlarmUI()
        
        //start fading black frame
        self.perform(#selector(self.fadeToBlack), with: nil, afterDelay: 3.0)
        
        //start playing sleep sounds
        playSleepSound()
    }
    
    fileprivate func blackOut() {
        
        let shouldSleepLights = UserDefaults.standard.bool(forKey: AmbitConstants.SleepSoundsLightingSetting)
        if shouldSleepLights {
            let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
            let bridgeSendAPI = PHBridgeSendAPI()
            
            if let lights = cache?.lights {
                let lightsData = NSMutableDictionary()
                lightsData.addEntries(from: lights)
                
                for light in lightsData.allValues {
                    let newLight = light as! PHLight
                    let lightState = PHLightState()
                    
                    lightState.brightness = 0
                    lightState.setOn(false)
                    
                    let doesAllow = LightsHelper.lightGroupingAllowsLight(string: newLight.uniqueId)
                    if doesAllow {
                        bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                            
                        })
                    }
                }
            }
        }
    }
    
    fileprivate func lightsOn() {
        let shouldAlarmLights = UserDefaults.standard.bool(forKey: AmbitConstants.AlarmSoundsLightingSetting)
        
        //dev todo figure out a better way to check if we are not in time only mode....
        let isInAlarmClockMode = timeLeftLabel.text?.length
        
        if shouldAlarmLights && (isInAlarmClockMode != 0) {
            let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
            let bridgeSendAPI = PHBridgeSendAPI()
            
            if let lights = cache?.lights {
                let lightsData = NSMutableDictionary()
                lightsData.addEntries(from: lights)
                
                for light in lightsData.allValues {
                    let newLight = light as! PHLight
                    let lightState = PHLightState()
                    
                    lightState.brightness = 100
                    lightState.setOn(true)
                    
                        let doesAllow = LightsHelper.lightGroupingAllowsLight(string: newLight.uniqueId)
                        if doesAllow {
                        bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                            
                        })
                    }
                }
            }
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bridgeSelection", let nav = segue.destination as? UINavigationController, let bridgesTableViewController =  nav.viewControllers.first as? HueBridgeSelectionTableViewController, let bridgesFound = sender as? [AnyHashable : Any] {
            let bridgesData = NSMutableDictionary()
            bridgesData.addEntries(from: bridgesFound)
            bridgesTableViewController.bridgesFound = bridgesData
            bridgesTableViewController.delegate = HueConnectionManager.sharedManager
        } else if segue.identifier == "bridgeAuthentication", let nav = segue.destination as? UINavigationController, let authViewController =  nav.viewControllers.first as? HueBridgeAuthenticationViewController {
            authViewController.delegate = HueConnectionManager.sharedManager
            authViewController.startPushLinking()
        } else if segue.identifier == "alarmOptions", let nav = segue.destination as? UINavigationController, let alarmOptions = nav.viewControllers.first as? AlarmOptionsTableViewController {
            alarmOptions.delegate = self
        } else if segue.identifier == "upcomingEvents", let nav = segue.destination as? UINavigationController, let upcomingEvents = nav.viewControllers.first as? EventOptionsViewController {
            upcomingEvents.managedObjectContext = managedObjectContext
        } else if segue.identifier == "watchOptions", let nav = segue.destination as? UINavigationController, let watchOptions = nav.viewControllers.first as? WatchOptionsViewController {
            //
        } else if segue.identifier == "lightOptions", let nav = segue.destination as? UINavigationController, let lightOptions = nav.viewControllers.first as? LightsOptionsViewController {
            //
        } else if segue.identifier == "containerSegue", let textViewController = segue.destination as? QuoteViewController {
            //
        } else if segue.identifier == "alarmSounds", let nav = segue.destination as? UINavigationController, let lightOptions = nav.viewControllers.first as? AlarmSoundsTableViewController {
            //
        } else if segue.identifier == "sleepSounds", let nav = segue.destination as? UINavigationController, let lightOptions = nav.viewControllers.first as? SleepSoundsTableViewController {
            //
        }
    }
    
    // MARK - Status Bar
    var statusBarHidden : Bool = false
    @objc func toggleStatusBar(notification : NSNotification) {
        if let isHidden = notification.object as? Bool {
            animateStatusBars(isHidden: isHidden)
        }
    }
    
    func animateStatusBars(isHidden : Bool) {
        self.statusBarHidden = isHidden
        UIView.animate(withDuration: 0.70) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return self.statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    ///Asks user for app review
    func displayAppReviewViewController() {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
    }
}

extension ViewController: SBTimeLabelDelegate {
    func didUpdateText(_ label: SBTimeLabel) {
        updateRunningAlarmUI()
    }
}

extension ViewController : HueConnectionManagerDelegate {
    internal func didStartConnecting() {
    }
    
    internal func didStartSearching() {
    }
    
    internal func didFindBridges(bridgesFound: [AnyHashable : Any]?) {
        performSegue(withIdentifier: "bridgeSelection", sender: bridgesFound)
    }
    
    internal func didFailToFindBridges() {
        AlertHelper.showAlert(title: "Failed To Find Bridges", controller: self)
    }
    
    internal func showPushButtonAuthentication() {
        performSegue(withIdentifier: "bridgeAuthentication", sender: nil)
    }
    
    //MARK - Date Picker
    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year, let hour = componenets.hour, let minute = componenets.minute, let second = componenets.second {
            print("\(day) \(month) \(year),  \(hour),  \(minute),  \(second)")
        }
    }
    
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension ViewController: AlarmOptionsTableViewControllerDelegate {
    func performSegueFromOptions(_ identifier: NSString?) {
        self.performSegue(withIdentifier: identifier! as String, sender: nil)
    }
    
    func presentIntroductionVideo() {
        let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        return
    }
    
    func presentAppReviewController() {
        displayAppReviewViewController()
    }
}



