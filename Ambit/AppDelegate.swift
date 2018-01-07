//
//  AppDelegate.swift
//  template
//
//  Created by Ryan Phillip Thomas on 12/9/16.
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import UIKit
import RTCoreData
import CoreData
import UserNotifications
import AudioPlayer
import AVFoundation
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var context:NSManagedObjectContext!
    var currentSound: AudioPlayer?
    var audioPlayer : AVAudioPlayer!
    var audioPlayerVolume : Float!
    
    var isPlayingOverride : Bool = false

    var timer1: Timer?
    var timer2: Timer?
    var timer3: Timer?
    var timer4: Timer?


    var backgroundUpdateTask: UIBackgroundTaskIdentifier = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        let mainContext = createMainContext(modelStoreName: "Model", bundles: nil)
        context = mainContext
        
        HueConnectionManager.sharedManager.startUp()
        
        AppearanceHelper.addTransparentNavigationBar()
        
        RootHelper.setMOCController(window: window, moc: self.context)
        
        // Set up and activate your session early here!
        WatchSessionManager.sharedManager.startSession()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                //self.registerCategory()
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
            print("error")
            return true
        }
        
//        play()
        
        //initalize app defaults
        let defaults = [AmbitConstants.CurrentAlarmSoundName : "Party",
                        AmbitConstants.CurrentSleepSoundName : "Thunderstorm",
                        AmbitConstants.CurrentVolumeLevelName : 100.0,
                        AmbitConstants.CurrentHueBridgeName : "Select Bridge",
                        AmbitConstants.CurrentLightSceneName : "Select Scene",
                        AmbitConstants.VibrateWithAlarmSetting : false,
                        AmbitConstants.ProgressiveAlarmVolumeSetting : false,
                        AmbitConstants.DefaultSnoozeLength : 60*15, //15 min
                        AmbitConstants.DefaultSleepSoundsLength : 60*30, //30min
                        AmbitConstants.AlarmSoundsLightingSetting : true,
                        AmbitConstants.SleepSoundsLightingSetting : true,
                        AmbitConstants.AlarmSoundsLightingSettingSceneName : "Select Scene",
                        AmbitConstants.SleepSoundsLightingSettingSceneName : "Select Scene",
                        AmbitConstants.CurrentCustomMediaAlarmSoundName : "Select A Song",
                        AmbitConstants.CurrentCustomMediaSleepSoundName : "Select A Song"] as [String : Any]

        UserDefaults.standard.register(defaults: defaults)
        
        return true
    }
    
    func appBackrounding() {
        keepAlive()
    }
    
    func appForegrounding() {
        if (self.backgroundUpdateTask != UIBackgroundTaskInvalid) {
            self.endBackgroundUpdateTask()
        }
    }
    
    func keepAlive() {
        timer4?.invalidate() //cleanup
        timer4 = Timer.scheduledTimer(timeInterval: 540, target: self, selector: #selector(keepAlive), userInfo: nil, repeats: true) //setup refresh in 9 min
       print("**DID SETUP NEW TIMER AND BACKROUND TASK**")
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            print("**DID COMPLETE NEW TIMER AND BACKROUND TASK**")
            self.endBackgroundUpdateTask()
            self.keepAlive()
        })
        
    }
    
    func isPlayingSound() -> Bool {
        if isPlayingOverride { return true }
        
        guard let currentSound = self.currentSound else { return false }
        return currentSound.isPlaying
    }
    
    func isPlayingBackroundSound() -> Bool {
        if isPlayingOverride { return true }

        guard let currentSound = self.audioPlayer else { return false }
        return currentSound.isPlaying
    }
    
    func registerCategory() -> Void {
        
        let snooze = UNNotificationAction(identifier: "snooze", title: "Snooze", options: [])
        let stop = UNNotificationAction(identifier: "stop", title: "Stop", options: [])
        let category : UNNotificationCategory = UNNotificationCategory.init(identifier: "ALARMNOTIFICATION", actions: [snooze, stop], intentIdentifiers: [], options: [])
        
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("didReceive")
    }
    
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("didReceiveNotificationResponse")
       
        AlarmScheduleManager.sharedManager.clearAllNotifications()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        AlarmScheduleManager.sharedManager.clearAllNotifications()
        
        let application = UIApplication.shared
        if application.applicationState != .active { // Only address notifications received when not active
            print("willPresent - inactive")
            //Application is active Update UX for Snooze View
            //playCurrentSoundAtStart()
            completionHandler([.badge, .alert, .sound])
        } else {
            print("willPresent - active")
            
            //play sound
            play()
            
        }
        completionHandler([])
    }
    
    func play() {
        
        if isPlayingSound() { return }
        
        //get sound file name and load it up
        do {
            let userSoundFile = UserDefaults.standard.string(forKey: AmbitConstants.CurrentAlarmSoundName)
            let soundFile = StringHelper.soundFileForName(string: userSoundFile!)
            if let file = soundFile {
                currentSound = try AudioPlayer(fileName: file)
            } else {
                let customMediaSoundURL = UserDefaults.standard.url(forKey: AmbitConstants.CurrentCustomMediaAlarmSoundURL)
                currentSound = try AudioPlayer(contentsOf: customMediaSoundURL as! URL)
            }
        }
        catch _ {
            // Error handling
            print("Sound initialization failed")
        }
        
        //initalize volume
        audioPlayerVolume = 0.1
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(audioPlayerVolume, animated: false)

        //setup timer
        timer1 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(increaseCurrentSound), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(vibrate), userInfo: nil, repeats: true)
        
        //start playing sound
        playCurrentSound()        
    }
    
    func checkFireDate() {
        let alarm = Alarm.fetchCurrentAlarm(moc: self.context)
        guard let scheduleAlarm = alarm else {return}
        //let timeRemaining = StringHelper.timeLeftUntilAlarm(alarmDate: scheduleAlarm.fireDate)
        let currentDate = Date()
        if currentDate > scheduleAlarm.fireDate {
            //Play alarm and show snooze view
            play()
        }
    }
    
    func increaseCurrentSound() {
        let shouldIncrease = UserDefaults.standard.bool(forKey: AmbitConstants.ProgressiveAlarmVolumeSetting)
        let volumeLevel = UserDefaults.standard.float(forKey: AmbitConstants.CurrentVolumeLevelName)

        if shouldIncrease {
            //gently increase volume
            if audioPlayerVolume < volumeLevel {
                audioPlayerVolume = audioPlayerVolume + 1.0000
                (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(audioPlayerVolume, animated: true)
            }
        } else {
            audioPlayerVolume = volumeLevel
            (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(audioPlayerVolume, animated: true)
        }
    }
    
    func vibrate() {
        
        let shouldVibrate = UserDefaults.standard.bool(forKey: AmbitConstants.VibrateWithAlarmSetting)

        //get the phone to vibrate
        if shouldVibrate {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
    
    func playCurrentSound() {
        currentSound?.numberOfLoops = 10
        currentSound?.currentTime = 0
        currentSound?.fadeIn()
        currentSound?.volume = 100.0
        currentSound?.play()
        
        isPlayingOverride = true
        
        //stop recording
        RecorderManager.sharedManager.stopRecording()
    }
    
    func stopCurrentSound() {
        currentSound?.fadeOut()
        currentSound?.stop()
        
        isPlayingOverride = false

        timer1?.invalidate()
        timer2?.invalidate()
        timer3?.invalidate()
        timer4?.invalidate()
        
        endBackgroundUpdateTask()
        
        AlarmScheduleManager.sharedManager.clearAllAlarms()
        
        //stop recording
        RecorderManager.sharedManager.stopRecording()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("didReceive")
        completionHandler()
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        timer3 = Timer.scheduledTimer(timeInterval: 0.30, target: self, selector: #selector(checkFireDate), userInfo: nil, repeats: true)
        appBackrounding()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        timer3?.invalidate()
        timer4?.invalidate()
        
        appForegrounding()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Void) {
        //
        print("Test")
    }
}

