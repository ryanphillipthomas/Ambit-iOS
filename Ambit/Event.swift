//
//  Event.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 2/11/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

import UIKit
import CoreData
import RTCoreData
import CoreLocation
import Foundation
import EventKit

public class Event: ManagedObject {
    
    // MARK: Properties
    @NSManaged public private(set) var id:String
    @NSManaged public private(set) var startTime:Date
    @NSManaged public private(set) var endTime:Date
    @NSManaged public private(set) var title:String
    @NSManaged public private(set) var location:String

    public static func insertIntoContext(moc: NSManagedObjectContext, eventDictionary: NSDictionary) -> Event? {
        guard let id = eventDictionary["id"] as? String,
            let startTime = eventDictionary["startTime"] as? Date,
            let title = eventDictionary["title"] as? String,
            let location = eventDictionary["location"] as? String,
            let endTime = eventDictionary["endTime"] as? Date
            else {
                return nil
        }
        let predicate = NSPredicate(format: "id == %@", id)
        let event = Event.findOrCreateInContext(moc: moc, matchingPredicate: predicate) { (event) in
            event.id = id
            event.startTime = startTime
            event.endTime = endTime
            event.title = title
            event.location = location
        }
        
        return event
    }
    
    public static func allUpcoming(moc: NSManagedObjectContext, completionHandler:@escaping([Event]?) -> Void){
        EventManager.sharedManager.loadAllFutureEvents { (events) in
            guard let eventsData = events else { return completionHandler(nil)}
            var eventsArray:[Event] = []
            for event in eventsData {
                let eventDictionary:NSDictionary = ["id": event.eventIdentifier,
                                                    "startTime": event.startDate,
                                                    "title":event.title,
                                                    "location":event.location ?? "No location set",
                                                    "endTime": event.endDate]
                
                if let event = Event.insertIntoContext(moc: moc, eventDictionary: eventDictionary) {
                    eventsArray.append(event)
                }
            }
            
            _ = moc.saveOrRollback()
            completionHandler(eventsArray)
        }
    }
}

extension Event: ManagedObjectType {
    public static var entityName: String {
        return "Event"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "startTime", ascending: true)]
    }
}
