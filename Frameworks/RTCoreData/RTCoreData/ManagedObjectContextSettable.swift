//
//  ManagedObjectContextSettable.swift
//
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import CoreData

public protocol ManagedObjectContextSettable: class {
    var managedObjectContext: NSManagedObjectContext!{get set}
}
