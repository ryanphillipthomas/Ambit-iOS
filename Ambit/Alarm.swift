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
    
    public static func insertIntoContext(moc: NSManagedObjectContext, alarmDictionary: NSDictionary) -> Alarm? {
        guard let id = alarmDictionary["id"] as? String,
            let fireDate = alarmDictionary["fireDate"] as? Date,
            let name = alarmDictionary["name"] as? String
            else {
                return nil
        }
        let predicate = NSPredicate(format: "id == %@", id)
        let alarm = Alarm.findOrCreateInContext(moc: moc, matchingPredicate: predicate) { (alarm) in
            alarm.id = id
            alarm.name = name
            alarm.fireDate = fireDate
        }
        return alarm
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
