//
//  Occurrence+CoreDataProperties.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 8/2/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//
//

import Foundation
import CoreData


extension Occurrence {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Occurrence> {
        return NSFetchRequest<Occurrence>(entityName: "Occurrence")
    }

    @NSManaged public var doesTrackLocation: Bool
    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var trackedBooleanDataNames: [String]?
    @NSManaged public var trackedStringDataNames: [String]?
    @NSManaged public var entry: NSSet?

}

// MARK: Generated accessors for entry
extension Occurrence {

    @objc(addEntryObject:)
    @NSManaged public func addToEntry(_ value: OccurrenceEntry)

    @objc(removeEntryObject:)
    @NSManaged public func removeFromEntry(_ value: OccurrenceEntry)

    @objc(addEntry:)
    @NSManaged public func addToEntry(_ values: NSSet)

    @objc(removeEntry:)
    @NSManaged public func removeFromEntry(_ values: NSSet)

}
