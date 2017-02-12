//
//  EventManager.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 2/11/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import EventKit

protocol EventManagerDelegate: class {
    func requestAccessToCalendar()
    func loadCalendars()
    func needPermissionToCalendar()
}

class EventManager: NSObject {
    static let sharedManager = EventManager()
//    var calendar: EKCalendar! disabled for now seach for all
    var events: [EKEvent]?
    weak var delegate:EventManagerDelegate?
    
    func loadAllFutureEvents(completionHandler:@escaping([EKEvent]?) -> Void){
        
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = Date()
        let endDate = Date.init(timeIntervalSinceNow: 60*60*24*30)
        
        let eventStore = EKEventStore()
        
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        // Use the configured NSPredicate to find and return events in the store that match
        self.events = eventStore.events(matching: eventsPredicate).sorted(){
            (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
        
        completionHandler(self.events)
    }
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            self.delegate?.requestAccessToCalendar()

        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            self.delegate?.loadCalendars()

        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            self.delegate?.needPermissionToCalendar()
        }
    }
}
