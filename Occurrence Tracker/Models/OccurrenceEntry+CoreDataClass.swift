//
//  OccurrenceEntry+CoreDataClass.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 8/1/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

public class OccurrenceEntry: NSManagedObject {
    func enteredDataDateAsString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let date = self.enteredDate {
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    func getFormattedAddress(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) -> String? {
        if let _ = error {
            return nil
        } else {
            if let placemarks = placemarks, let firstLocation = placemarks.first {
                var completedAddress: String = ""
                
                if let number = firstLocation.subThoroughfare {
                    completedAddress += "\(number) "
                }
                if let street = firstLocation.thoroughfare {
                    completedAddress += "\(street), "
                }
                if let city = firstLocation.locality {
                    completedAddress += "\(city), "
                }
                if let state = firstLocation.administrativeArea {
                    completedAddress += "\(state) "
                }
                if let zip = firstLocation.postalCode {
                    completedAddress += "\(zip), "
                }
                if let country = firstLocation.isoCountryCode {
                    completedAddress += "\(country)"
                }
                
                return completedAddress
            } else {
                return nil
            }
        }
    }
}
