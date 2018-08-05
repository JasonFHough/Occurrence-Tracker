//
//  LogOccurrenceEntryTableViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/20/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LogOccurrenceEntryTableViewController: UITableViewController, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<OccurrenceEntry>!
    
    private var locationManager = CLLocationManager()
    
    var detailedOccurrenceVC: DetailedOccurrenceViewController!
    var selectedOccurrence: Occurrence!
    private var tableViewOrder: [TableViewSectionTypes] = [TableViewSectionTypes]()
    
    private var listOfAllStringDataElementsInTableView: [String : UITextField] = [String : UITextField]()
    private var listOfAllBoolDataElementsInTableView: [String : UISwitch] = [String : UISwitch]()
    
    private enum TableViewSectionTypes {
        case trackedStrings
        case trackedBooleans
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign fetch result controller
        let fetchRequest: NSFetchRequest<OccurrenceEntry> = OccurrenceEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "enteredDate", ascending: false)]
        if let context = container?.viewContext {
            fetchedResultsController = NSFetchedResultsController<OccurrenceEntry>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        if CLLocationManager.locationServicesEnabled() && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        constructTableViewSectionOrder()
        
        if tableViewOrder.isEmpty {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            saveButtonActions(nil)
        }
    }
    
    private func constructTableViewSectionOrder() {
        if let names = selectedOccurrence.trackedStringDataNames, !names.isEmpty {
            tableViewOrder.append(.trackedStrings)
        }
        if let names = selectedOccurrence.trackedBooleanDataNames, !names.isEmpty {
            tableViewOrder.append(.trackedBooleans)
        }
    }
    
    private func getCurrentLocationCoordinates() -> CLLocation? {
        if CLLocationManager.locationServicesEnabled() && selectedOccurrence.doesTrackLocation {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                return locationManager.location!
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func applyAllDataToSelectedOccurrence() {
        let currentDate: Date = Date()
        var newStringData: [String : String] = [String : String]()
        var newBooleanData: [String : Bool] = [String : Bool]()
        for (key, textField) in listOfAllStringDataElementsInTableView {
            newStringData[key] = textField.text
        }
        for (key, toggle) in listOfAllBoolDataElementsInTableView {
            newBooleanData[key] = toggle.isOn
        }
        
        let location = getCurrentLocationCoordinates()
        
        let context = self.fetchedResultsController.managedObjectContext
        guard let entity = NSEntityDescription.entity(forEntityName: "OccurrenceEntry", in: context) else { fatalError("Could not assign EntityDescription") }
        
        let entry = OccurrenceEntry(entity: entity, insertInto: context)
        entry.enteredDate = currentDate
        entry.identifier = UUID().uuidString
        entry.trackedStringData = newStringData
        entry.trackedBooleanData = newBooleanData
        entry.trackedLocation = location
        entry.occurrence = selectedOccurrence
        
        fetchedResultsController.saveData()
    }
    
    @IBAction func saveButtonActions(_ sender: UIBarButtonItem?) {
        applyAllDataToSelectedOccurrence()
        detailedOccurrenceVC.setMinAndMaxDate()
        detailedOccurrenceVC.chartVC?.changeChartView()
        Alert.showSuccessfulLoggedEntryAlert(on: self, popNavViewControllerOnCompletion: true)
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if let cell = cell as? LogOccurrenceStringEntryTableViewCell {
            cell.dataNameLabel.text = selectedOccurrence.trackedStringDataNames?[indexPath.row] ?? "Something went wrong"
            
            listOfAllStringDataElementsInTableView[cell.dataNameLabel.text!] = cell.dataTextField
        } else if let cell = cell as? LogOccurrenceBooleanEntryTableViewCell {
            cell.dataNameLabel.text = selectedOccurrence.trackedBooleanDataNames?[indexPath.row] ?? "Something went wrong"
            
            listOfAllBoolDataElementsInTableView[cell.dataNameLabel.text!] = cell.booleanSwitch
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, at: indexPath)
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailedOccurrenceVC = segue.destination as? DetailedOccurrenceViewController {
            detailedOccurrenceVC.dataTableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewOrder.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch tableViewOrder[section] {
        case .trackedStrings:
            return "String Data"
        case .trackedBooleans:
            return "Boolean Data"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewOrder[section] {
        case .trackedStrings:
            return selectedOccurrence.trackedStringDataNames?.count ?? 0
        case .trackedBooleans:
            return selectedOccurrence.trackedBooleanDataNames?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewOrder[indexPath.section] {
        case .trackedStrings:
            let cell = tableView.dequeueReusableCell(withIdentifier: "enterStringDataCell", for: indexPath) as! LogOccurrenceStringEntryTableViewCell
            
            configureCell(cell, at: indexPath)
            
            return cell
        case .trackedBooleans:
            let cell = tableView.dequeueReusableCell(withIdentifier: "enterBooleanDataCell", for: indexPath) as! LogOccurrenceBooleanEntryTableViewCell
            
            configureCell(cell, at: indexPath)
            
            return cell
        }
    }

}
