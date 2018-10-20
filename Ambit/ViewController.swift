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
    @IBOutlet var nextAlarmLabel: UILabel!

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
    @IBOutlet weak var createAlarmAnimationView: SpringView!

    
    @IBOutlet weak var containerView: UIView!
    weak var tableViewController:UITableViewController!
    weak var tableView: UITableView!

    var externalWindow: UIWindow!
    var backroundAnimation = CAGradientLayer()
    var managedObjectContext: NSManagedObjectContext!
    var currentSound: AudioPlayer?
    var currentSleepSound: AudioPlayer?
    var audioPlayer : AVAudioPlayer!
    var isPlayingOverride : Bool = false
    
    let applicationMusicPlayer = MPMusicPlayerController.applicationMusicPlayer

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
        createAlarmAnimationView.isHidden = true
        snoozeView.isHidden = true
        settingsButtonAnimationView.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleStatusBar(notification:)), name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar), object: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleStatusBar(notification:)), name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar), object: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleScreenDidConnectNotification(aNotification:)), name: UIScreen.didConnectNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleScreenDidDisconnectNotification(aNotification:)), name: UIScreen.didDisconnectNotification, object: nil)

        showCurrentClock(_sender: UIButton())
        
        // Initialize an external screen if one is present
        let screens = UIScreen.screens
        if screens.count > 1 {
            //An external screen is available. Get the first screen available
            self.initializeExternalScreen(externalScreen: screens[1] as UIScreen)
        }
    }
    
    // Initialize an external screen
    func initializeExternalScreen(externalScreen: UIScreen) {
        
        // Create a new window sized to the external screen's bounds
        self.externalWindow = UIWindow(frame: externalScreen.bounds)
        
        // Assign the screen object to the screen property of the new window
        self.externalWindow.screen = externalScreen;
        
        // Configure the View
        timeLabel.textColor = UIColor.white
        self.externalWindow.addSubview(timeLabel)
        
        // Make the window visible
        self.externalWindow.makeKeyAndVisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateRunningAlarmUI()
    }
    
    override func viewDidLayoutSubviews() {
        backroundAnimation.frame = self.view.bounds
    }
    
// Sets the minimum date for picker (disabled due to UI issue)
//    @IBAction func pickerValueChanged(_ sender: Any) {
//        let calendar = Calendar.current
//        let date = calendar.date(byAdding: .minute, value: 1, to: Date())
//        timePicker.minimumDate = date
//    }
    
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
                if let customMediaSoundURL = UserDefaults.standard.url(forKey: AmbitConstants.CurrentCustomMediaSleepSoundURL) {
                    currentSound = try AudioPlayer(contentsOf: customMediaSoundURL)
                } else if let mediaID = UserDefaults.standard.string(forKey: AmbitConstants.CurrentCustomMediaSleepSoundID) {
                    // attept to play protected media asset
                    applicationMusicPlayer.setQueue(with: [mediaID])
                }
            }
        }
        catch _ {
            // Error handling
            print("Sound initialization failed")
        }
        let volumeLevel = UserDefaults.standard.float(forKey: AmbitConstants.CurrentVolumeLevelName)
        currentSound?.volume = volumeLevel
        currentSound?.play()
        
        if currentSound == nil {
            applicationMusicPlayer.play()
        }
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
        let alarm = Alarm.fetchCurrentAlarm(moc: managedObjectContext)
        if (alarm != nil) {
            //fade out lights
            self.blackOut()
            
            //show the stop button
            self.animateInStopButton()
            
            //timeLabel to white
            UIView.transition(with: self.timeLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                self.timeLabel.textColor = UIColor.white
            }) { (finished) in
                
                //timeLabel to grey
                UIView.transition(with: self.timeLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                    self.timeLabel.textColor = UIColor.darkGray
                }, completion: nil)
            }
            
            //timeUpcomingLabel to white
            UIView.transition(with: self.timeUpcomingLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                self.timeUpcomingLabel.textColor = UIColor.white
            }) { (finished) in
                
                //timeUpcomingLabel to grey
                UIView.transition(with: self.timeUpcomingLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                    self.timeUpcomingLabel.textColor = UIColor.darkGray
                }, completion: nil)
            }
            
            //timeLeftLabel to white
            UIView.transition(with: self.timeLeftLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                self.timeLeftLabel.textColor = UIColor.white
            }) { (finished) in
                
                //timeLeftLabel to grey
                UIView.transition(with: self.timeLeftLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                    self.timeLeftLabel.textColor = UIColor.darkGray
                }, completion: nil)
            }
            
            //nextAlarmLabel to white
            UIView.transition(with: self.nextAlarmLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                self.nextAlarmLabel.textColor = UIColor.white
            }) { (finished) in
                
                //nextAlarmLabel to grey
                UIView.transition(with: self.nextAlarmLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                    self.nextAlarmLabel.textColor = UIColor.darkGray
                }, completion: nil)
            }
            
            blackoutFullscreenView()
        }
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
        
        //timeLabel
        UIView.transition(with: self.timeLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.timeLabel.textColor = UIColor.black
        }, completion: nil)
        
        //timeUpcomingLabel
        UIView.transition(with: self.timeUpcomingLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.timeUpcomingLabel.textColor = UIColor.black
        }, completion: nil)
        
        //timeLeftLabel
        UIView.transition(with: self.timeLeftLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.timeLeftLabel.textColor = UIColor.black
        }, completion: nil)
        
        //nextAlarmLabel
        UIView.transition(with: self.nextAlarmLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.nextAlarmLabel.textColor = UIColor.black
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
        if appDelegate.isPlayingAlarmSound() {
            animateOutTimeDisplayLayers()
            animateOutSettingsButton()
            animateInSnoozeButton() //show the snooze button
            self.perform(#selector(self.fadeToClear), with: nil, afterDelay: 0.4) //fade in the color backround in 0.4 secs
            
            //stop sleep sounds if playing
            currentSound?.stop()
        }
    }
    
    func animateInCreateAlarmDisplayLayers(){
        createAlarmAnimationView.isHidden = false
        createAlarmAnimationView.animation = "fadeInUp"
        createAlarmAnimationView.curve = "linear"
        createAlarmAnimationView.duration = 2.0
        createAlarmAnimationView.animate()
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
            stopAnimationView.animation = "fadeInDown"
            stopAnimationView.curve = "linear"
            stopAnimationView.duration = 2.0
            stopAnimationView.animate()
        }
    }
    
    func animateOutCreateAlarmDisplayLayers(){
        createAlarmAnimationView.animation = "fadeOutDown"
        createAlarmAnimationView.curve = "linear"
        createAlarmAnimationView.duration = 2.0
        createAlarmAnimationView.animate()
        createAlarmAnimationView.isHidden = true
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
    }
    
    func animateOutStopButton() {
        stopAnimationView.animation = "fadeOutUp"
        stopAnimationView.curve = "linear"
        stopAnimationView.duration = 2.0
        stopAnimationView.animate()
        stopAnimationView.isHidden = true
    }
    
    func animateInSettingsButton() {
        if settingsButtonAnimationView.isHidden {
            settingsButtonAnimationView.isHidden = false
            settingsButtonAnimationView.animation = "fadeInDown"
            settingsButtonAnimationView.curve = "linear"
            settingsButtonAnimationView.duration = 2.0
            settingsButtonAnimationView.animate()
        }
    }
    
    func animateOutSettingsButton() {
        settingsButtonAnimationView.animation = "fadeOut"
        settingsButtonAnimationView.curve = "linear"
        settingsButtonAnimationView.duration = 1.0
        settingsButtonAnimationView.animate()
        settingsButtonAnimationView.isHidden = true
    }
    
    func animateInTimePickerLayers() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar),object: false)
        timePickerAnimationView.isHidden = false
        timePickerAnimationView.animation = "fadeInDown"
        timePickerAnimationView.curve = "linear"
        timePickerAnimationView.duration = 2.0
        timePickerAnimationView.animate()
        
        //Defaults the time picker at the current date + 1 minute
        timePicker.date = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
    }
    
    func animateOutTimePickerLayers() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.ToggleStatusBar),object: true)
        timePickerAnimationView.animation = "fadeOut"
        timePickerAnimationView.curve = "linear"
        timePickerAnimationView.duration = 1.0
        timePickerAnimationView.animate()
        timePickerAnimationView.isHidden = true
    }
    
    @IBAction func newAlarm(_ sender: Any) {
        self.animateOutTimeDisplayLayers()
        self.animateOutCreateAlarmDisplayLayers()
        self.animateInTimePickerLayers()
        self.animateInStopButton()
    }
    
    
    
    @IBAction func stopAlarm(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopCurrentSound()
        
        self.fadeToClear()
        
        self.animateOutTimeDisplayLayers()
        self.animateOutStopButton()
        self.animateOutSnoozeButton()
        self.animateOutTimePickerLayers()

        self.animateInTimeOnlyDisplayLayers()
        self.animateInCreateAlarmDisplayLayers()
        self.animateInSettingsButton()

        //stop sleep sounds if playing
        currentSound?.stop()
        applicationMusicPlayer.stop()
    }
    
    @IBAction func didSnooze(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopCurrentSound()
        
        //start fading black frame
        self.perform(#selector(self.fadeToBlack), with: nil, afterDelay: 3.0)
        
        //generate date in 1 min
        let now = Date()
        let dateInFifteenMinutes = now.addingTimeInterval(60*15)
        addAlarmFromTimePicker(date:dateInFifteenMinutes)
        
        animateOutSnoozeButton()
        animateInTimeDisplayLayers()
        animateInSettingsButton()
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
        
        //start recording
        let shouldRecord = UserDefaults.standard.bool(forKey: AmbitConstants.RecorderActiveSetting)
        if shouldRecord {
            RecorderManager.sharedManager.startRecording()
        }
        
        //start deep sleep
        let mp = MMPDeepSleepPreventer()
        mp.startPreventSleep()

//        //get the apple watch to vibrate
        scheduleLocalNotifications(scheduleAlarm: scheduleAlarm)
    }
    
    func scheduleLocalNotifications(scheduleAlarm : Alarm) {
        //get the apple watch to vibrate
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 0)
    }
    
    
    @IBAction func showCurrentClock(_sender: Any){
        //update label with alarm
        updateRunningAlarmUI()
        
        //animaite out time picker
        self.animateOutTimePickerLayers()
        
        //animaite in time picker
        animateInTimeOnlyDisplayLayers()
        
        //animate in create alarm button
        animateInCreateAlarmDisplayLayers()
        
        //animate in settings button
        animateInSettingsButton()
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
        }
    }
    
    // MARK - Status Bar
    var statusBarHidden : Bool = true
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
    
    //External Display
    @objc func handleScreenDidConnectNotification(aNotification: NSNotification) {
        
        if let screen = aNotification.object as? UIScreen {
            self.initializeExternalScreen(externalScreen: screen)
        }
    }
    
    @objc func handleScreenDidDisconnectNotification(aNotification: NSNotification) {
        
        if self.externalWindow != nil {
            self.externalWindow.isHidden = true
            self.externalWindow = nil
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
        self.performSegue(withIdentifier: String(describing: BridgeLoadingViewController.self), sender: nil)
    }
    
    internal func didFindBridges(bridgesFound: [AnyHashable : Any]?) {
        self.performSegue(withIdentifier: "bridgeSelection", sender: bridgesFound)
    }
    
    internal func didFailToFindBridges() {
        AlertHelper.showAlert(title: "Failed To Find Bridges", controller: self)
    }
    
    internal func showPushButtonAuthentication() {
        self.performSegue(withIdentifier: "bridgeAuthentication", sender: nil)
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



