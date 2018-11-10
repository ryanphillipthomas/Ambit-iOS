//
//  AlarmScheduleManager.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 2/5/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import UserNotifications

protocol AlarmScheduleManagerDelegate: class {
    
}

class AlarmScheduleManager: NSObject {
    static let sharedManager = AlarmScheduleManager()
    
    func clearAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests() //might cause repeats to not work
    }
    
    func clearAllAlarms() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        clearAllPendingAlarms()
        
        Alarm.currentAlarmID = nil
        //delete alarm objects
    }
    
    func clearAllPendingAlarms() {
        let center = UNUserNotificationCenter.current()
        var removeIDs = [String]()

        center.getPendingNotificationRequests { (categories) in
            for notif in categories {
                if notif.content.categoryIdentifier == "ALARMNOTIFICATION" {
                    removeIDs.append(notif.identifier)
                }
            }
            
            center.removePendingNotificationRequests(withIdentifiers: removeIDs)
        }
    }
    
    func clearAllBedtimeAlarms() {
        let center = UNUserNotificationCenter.current()
        var removeIDs = [String]()
        
        center.getPendingNotificationRequests { (categories) in
            for notif in categories {
                if notif.content.categoryIdentifier == "BEDTIMENOTIFICATION" {
                    removeIDs.append(notif.identifier)
                }
            }
            
            center.removePendingNotificationRequests(withIdentifiers: removeIDs)
        }
    }
    
    func scheduleBedtimeNotification(fireDate : Date, interval : TimeInterval) {
        let id = UUID.init().uuidString
        let content = UNMutableNotificationContent()
        //content.title = ""
        content.body = "Bed Time! Go to sleep now to get some good rest."
        content.userInfo = ["content-available":"1"]
        content.categoryIdentifier = "BEDTIMENOTIFICATION"
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: AmbitConstants.CurrentBedtimeSoundName))
        
//        content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
        
        let calendar = Calendar(identifier: .gregorian)
        let dateInTimeInterval = Date.init(timeInterval: interval, since: fireDate)
        let components = calendar.dateComponents(in: .current, from: dateInTimeInterval)
        let newComponents = DateComponents(calendar: calendar, hour: components.hour, minute: components.minute, second: components.second)

        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: true)
        let request = UNNotificationRequest.init(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let theError = error {
                print("Uh oh! We had an error: \(error)")
            } else {
                print(request)
            }
        }

    }
    
    func scheduleAlarmNotification(alarm : Alarm? = nil, overrideDate : Date? = nil, interval : TimeInterval) {
        //dev todo cleanup
        let id = UUID.init().uuidString
        let content = UNMutableNotificationContent()
        
        //dev todo add ability to see the amount of alarms displayed already
//        content.title = ""
        content.body = "Time to wakeup!"
        
        let userSoundFile = UserDefaults.standard.string(forKey: AmbitConstants.CurrentAlarmSoundName)
        let soundFile = StringHelper.soundFileForName(string: userSoundFile!)
        if let file = soundFile {
            //do not add support for itunes music here
            content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: file))
        }
        content.userInfo = ["content-available":"1"]
        content.categoryIdentifier = "ALARMNOTIFICATION"
    //    content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
        
        // Add Image to Notification
//        if let path = Bundle.main.path(forResource: "500", ofType: "jpg") {
//            let url = URL(fileURLWithPath: path)
//            
//            do {
//                let attachment = try UNNotificationAttachment(identifier: "500", url: url, options: nil)
//                content.attachments = [attachment]
//            } catch {
//                print("The attachment was not loaded.")
//            }
//        }
 
        var fireDate = alarm?.fireDate
        if (overrideDate != nil) { fireDate = overrideDate! }
        let calendar = Calendar(identifier: .gregorian)
        let dateInTimeInterval = Date.init(timeInterval: interval, since: fireDate!)
        let components = calendar.dateComponents(in: .current, from: dateInTimeInterval)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: components.second)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let request = UNNotificationRequest.init(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.add(request) { (error) in
            if let theError = error {
                print("Uh oh! We had an error: \(error)")
            } else {
                print(request)
            }
        }
    }
}

