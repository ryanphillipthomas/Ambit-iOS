//
//  Alarm.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 2/2/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import CoreData
import RTCoreData
import CoreLocation
import Foundation

public class Alarm: ManagedObject {

    // MARK: Properties
    @NSManaged public private(set) var id:String
    @NSManaged public private(set) var name:String
    @NSManaged public private(set) var fireDate:Date
    @NSManaged public private(set) var enabled:Bool
    @NSManaged public private(set) var snoozeEnabled:Bool
    @NSManaged public private(set) var mediaID:String
    @NSManaged public private(set) var mediaLabel:String

    public static func insertIntoContext(moc: NSManagedObjectContext, alarmDictionary: NSDictionary) -> Alarm? {
        guard let id = alarmDictionary["id"] as? String,
            let fireDate = alarmDictionary["fireDate"] as? Date,
            let name = alarmDictionary["name"] as? String,
            let mediaLabel = alarmDictionary["mediaLabel"] as? String,
            let mediaID = alarmDictionary["mediaID"] as? String,
            let enabled = alarmDictionary["enabled"] as? Bool,
            let snoozeEnabled = alarmDictionary["snoozeEnabled"] as? Bool
            else {
                return nil
        }
        let predicate = NSPredicate(format: "id == %@", id)
        let alarm = Alarm.findOrCreateInContext(moc: moc, matchingPredicate: predicate) { (alarm) in
            alarm.id = id
            alarm.name = name
            alarm.fireDate = fireDate
            alarm.mediaLabel = mediaLabel
            alarm.mediaID = mediaID
            alarm.enabled = enabled
            alarm.snoozeEnabled = snoozeEnabled
        }
        
        //allways set to current
        currentAlarmID = id
        
        return alarm
    }
    
    // MARK: currentAlarmID get / set
    static var currentAlarmID:String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.object(forKey: "currentAlarmID") as? String
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue, forKey: "currentAlarmID")
        }
    }
    
    public static func fetchCurrentAlarm(moc: NSManagedObjectContext) -> Alarm? {
        if let currentAlarmID = currentAlarmID {
            let predicate = NSPredicate(format: "id == %@", currentAlarmID)
            return Alarm.fetchInContext(context: moc, configurationBlock: { (request) in
                request.predicate = predicate
                request.fetchBatchSize = 1
            }).first
        }
        return nil
    }
}

extension Alarm: ManagedObjectType {
    public static var entityName: String {
        return "Alarm"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "fireDate", ascending: false)]
    }
}
