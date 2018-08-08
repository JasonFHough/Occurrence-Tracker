//
//  DetailedOccurrenceEntryTableViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/20/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailedOccurrenceEntryTableViewController: UITableViewController {

    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private struct TrackedDataStruct {
        var key: Any!
        var value: Any!
    }
    private var listOfStringDataStructs: [TrackedDataStruct] = [TrackedDataStruct]()
    private var listOfBooleanDataStructs: [TrackedDataStruct] = [TrackedDataStruct]()
    private var tableViewOrder: [TableViewSectionTypes] = [TableViewSectionTypes]()
    
    var selectedOccurrence: Occurrence!
    var selectedEntry: OccurrenceEntry!
    
    private enum TableViewSectionTypes {
        case trackedStrings
        case trackedBooleans
        case trackedLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = selectedEntry.enteredDataDateAsString()
        
        convertTrackedDataDictionaryToArray()
        constructTableViewSectionOrder()
    }

    private func constructTableViewSectionOrder() {
        if !listOfStringDataStructs.isEmpty {
            tableViewOrder.append(.trackedStrings)
        }
        if !listOfBooleanDataStructs.isEmpty {
            tableViewOrder.append(.trackedBooleans)
        }
        if selectedOccurrence.doesTrackLocation {
            tableViewOrder.append(.trackedLocation)
        }
    }
    
    private func convertTrackedDataDictionaryToArray() {
        if let stringData = selectedEntry.trackedStringData {
            // String Data
            for (key, value) in stringData {
                listOfStringDataStructs.append(TrackedDataStruct(key: key, value: value))
            }
        }
        
        if let booleanData = selectedEntry.trackedBooleanData {
            // Boolean Data
            for (key, value) in booleanData {
                listOfBooleanDataStructs.append(TrackedDataStruct(key: key, value: value))
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewOrder.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch tableViewOrder[section] {
        case .trackedStrings:
            return "Tracked String Data"
        case .trackedBooleans:
            return "Tracked Boolean Data"
        case .trackedLocation:
            return "Tracked Location"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewOrder[section] {
        case .trackedStrings:     // String Data
            return listOfStringDataStructs.isEmpty ? 1 : listOfStringDataStructs.count
        case .trackedBooleans:     // Boolean Data
            return listOfBooleanDataStructs.isEmpty ? 1 : listOfBooleanDataStructs.count
        case .trackedLocation:     // Location Data
            return selectedOccurrence.doesTrackLocation ? 1 : 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewOrder[indexPath.section] {
        case .trackedStrings:     // String Data Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "trackedDataCell", for: indexPath) as! EntryTrackedDataTableViewCell
            
            if listOfStringDataStructs.isEmpty {
                cell.nameLabel.text = ""
                cell.valueLabel.text = "No Data"
            } else {
                cell.nameLabel.text = listOfStringDataStructs[indexPath.row].key as? String
                cell.valueLabel.text = listOfStringDataStructs[indexPath.row].value as? String
            }
            
            return cell
        case .trackedBooleans:     // Boolean Data Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "trackedDataCell", for: indexPath) as! EntryTrackedDataTableViewCell
            
            if listOfBooleanDataStructs.isEmpty {
                cell.nameLabel.text = ""
                cell.valueLabel.text = "No Data"
            } else {
                cell.nameLabel.text = listOfBooleanDataStructs[indexPath.row].key as? String
                cell.valueLabel.text = listOfBooleanDataStructs[indexPath.row].value as! Bool ? "True" : "False"
            }
            
            return cell
        case .trackedLocation:     // Location Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "trackedLocationCell", for: indexPath) as! EntryLocationTableViewCell
            
            let trackedLocation = selectedEntry.trackedLocation
            if let location = trackedLocation, selectedOccurrence.doesTrackLocation {
                // Set the address text label
//                let geoCoder = CLGeocoder()
//                geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
//                    cell.locationAddressLabel.text = self.selectedEntry.getFormattedAddress(withPlacemarks: placemarks, error: error)
//                }
                cell.locationAddressLabel.text = selectedEntry.formattedAddress
                
                // Pinpoint the location on the map
                cell.mapView.addAnnotation(MKPlacemark.init(coordinate: location.coordinate))
                
                // Setup the map view
                let viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 600, 400)
                cell.mapView.setRegion(viewRegion, animated: true)
            }
            
            return cell
        }
    }

}
