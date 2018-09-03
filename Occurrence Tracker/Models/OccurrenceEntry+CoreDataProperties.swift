//
//  OccurrenceEntry+CoreDataProperties.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 8/7/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

extension OccurrenceEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OccurrenceEntry> {
        return NSFetchRequest<OccurrenceEntry>(entityName: "OccurrenceEntry")
    }

    @NSManaged public var enteredDate: Date?
    @NSManaged public var identifier: String?
    @NSManaged public var trackedBooleanData: [String:Bool]?
    @NSManaged public var trackedLocation: CLLocation?
    @NSManaged public var trackedStringData: [String:String]?
    @NSManaged public var formattedAddress: String?
    @NSManaged public var occurrence: NSSet?

}

// MARK: Generated accessors for occurrence
extension OccurrenceEntry {

    @objc(addOccurrenceObject:)
    @NSManaged public func addToOccurrence(_ value: Occurrence)

    @objc(removeOccurrenceObject:)
    @NSManaged public func removeFromOccurrence(_ value: Occurrence)

    @objc(addOccurrence:)
    @NSManaged public func addToOccurrence(_ values: NSSet)

    @objc(removeOccurrence:)
    @NSManaged public func removeFromOccurrence(_ values: NSSet)

}
