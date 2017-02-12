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
    
    func clearAllAlarms() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        //delete alarm objects
    }
    
    func scheduleAlarmNotification(alarm : Alarm, interval : TimeInterval) {
        
        //dev todo cleanup
        let id = UUID.init().uuidString
        let content = UNMutableNotificationContent()
        //dev todo add ability to see the amount of alarms displayed already
//        content.title = ""
        content.body = "Time to wakeup!"
        content.sound = UNNotificationSound.init(named: "bell.mp3")
        content.categoryIdentifier = "ALARMNOTIFICATION"
        //content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
        
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

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: alarm.fireDate)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let request = UNNotificationRequest.init(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.removeAllDeliveredNotifications() //dev todo consider this on didFinishLaunching...
        center.removeAllPendingNotificationRequests()
        center.add(request) { (error) in
            if let theError = error {
                print("Uh oh! We had an error: \(error)")
            } else {
                print(request)
            }
        }
    }

}

