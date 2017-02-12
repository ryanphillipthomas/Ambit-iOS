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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var context:NSManagedObjectContext!
    var currentSound: AudioPlayer?
    
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
                self.registerCategory()
            }
        }
        
        return true
    }
    
    func isPlayingSound() -> Bool {
        guard let currentSound = self.currentSound else { return false }
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //get sound file name and load it up
        do {
            currentSound = try AudioPlayer(fileName: "bell.mp3")
        }
        catch _ {
            // Error handling
            print("Sound initialization failed")
        }
        
        let application = UIApplication.shared
        if application.applicationState != .active { // Only address notifications received when not active
            print("willPresent - inactive")
            //Application is active Update UX for Snooze View
            //playCurrentSoundAtStart()
            completionHandler([.badge, .alert, .sound])
        } else {
            print("willPresent - active")
            
            //play sound
            playCurrentSound()
        }
        completionHandler([])
    }
    
    func playCurrentSound() {
        currentSound?.numberOfLoops = 5
        currentSound?.currentTime = 0
        currentSound?.fadeIn()
        currentSound?.volume = 100.0
        currentSound?.play()
    }
    
    func stopCurrentSound() {
        currentSound?.fadeOut()
        currentSound?.stop()
        
        AlarmScheduleManager.sharedManager.clearAllAlarms()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("didReceive")
        completionHandler()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
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

