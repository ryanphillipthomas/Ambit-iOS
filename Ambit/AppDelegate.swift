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

    var timer1: Timer?
    var timer2: Timer?
    var timer3: Timer?

    var backgroundUpdateTask: UIBackgroundTaskIdentifier = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        let mainContext = createMainContext(modelStoreName: "Model", bundles: nil)
        context = mainContext
        
        HueConnectionManager.sharedManager.startUp()
        
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
        
//        play()
        
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
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
            self.keepAlive()
        })
    }
    
    func isPlayingSound() -> Bool {
        guard let currentSound = self.currentSound else { return false }
        return currentSound.isPlaying
    }
    
    func isPlayingBackroundSound() -> Bool {
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
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
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
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
            return print("error")
        }
        
        //get sound file name and load it up
        do {
            currentSound = try AudioPlayer(fileName: "bell.mp3")
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
        timer2 = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(vibrate), userInfo: nil, repeats: true)
        
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
        //gently increase volume
        if audioPlayerVolume < 0.8 {
            audioPlayerVolume = audioPlayerVolume + 0.0125
            (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(audioPlayerVolume, animated: true)
        }
    }
    
    func vibrate() {
        //vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    func playCurrentSound() {
        currentSound?.numberOfLoops = 10
        currentSound?.currentTime = 0
        currentSound?.fadeIn()
        currentSound?.volume = 100.0
        currentSound?.play()
    }
    
    func stopCurrentSound() {
        currentSound?.fadeOut()
        currentSound?.stop()
        timer1?.invalidate()
        timer2?.invalidate()
        
        endBackgroundUpdateTask()
        
        AlarmScheduleManager.sharedManager.clearAllAlarms()
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

