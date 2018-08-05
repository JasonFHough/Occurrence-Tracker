//
//  OccurrenceEntry+CoreDataProperties.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 8/2/18.
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
    @NSManaged public var trackedBooleanData: [String:Bool]?
    @NSManaged public var trackedLocation: CLLocation?
    @NSManaged public var trackedStringData: [String:String]?
    @NSManaged public var identifier: String?
    @NSManaged public var occurrence: Occurrence?

}
