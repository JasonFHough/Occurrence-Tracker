//
//  NSFetchedResultsControllerDelegateExtension.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 8/5/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import Foundation
import CoreData

@objc extension NSFetchedResultsController {
    
    func retrieveData() {
        do {
            try self.performFetch()
        } catch let e as NSError {
            print("Error fetching data. Error: \(e)")
        }
    }
    
    func saveData() {
        do {
            try self.managedObjectContext.save()
        } catch let e as NSError {
            print("Error saving data. Error: \(e)")
        }
    }
    
}
