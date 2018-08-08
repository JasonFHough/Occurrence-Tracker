//
//  AllDataTableViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/19/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class AllDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<OccurrenceEntry>!
    
    var chartVC: DetailedOccurrenceChartViewController?
    var detailedOccurrenceVC: DetailedOccurrenceViewController!
    
    var exportBarButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exportBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportButtonAction))
        self.navigationItem.rightBarButtonItems = [self.editButtonItem, exportBarButton!]
        
        // Assign fetch result controller
        let fetchRequest: NSFetchRequest<OccurrenceEntry> = OccurrenceEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "enteredDate", ascending: false)]
        if let context = container?.viewContext {
            fetchedResultsController = NSFetchedResultsController<OccurrenceEntry>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K == %@", "occurrence.identifier", detailedOccurrenceVC.selectedOccurrence.identifier! as CVarArg)
            fetchedResultsController.delegate = self
        }
        
        // Retrieve all the data from the database
        fetchedResultsController.retrieveData()
        
        // Display No Data text if removed last entry
        checkIfNoEntriesAreEntered()
        
        // Disable selection of cells if no extra data is tracked
        checkIfOccurrenceTracksAnyData()
    }

    private func checkIfOccurrenceTracksAnyData() {
        guard let occurrence = detailedOccurrenceVC.selectedOccurrence else { fatalError("Selected Occurrence was not passed.") }
        guard let stringNames = occurrence.trackedStringDataNames else { fatalError("TrackedStringDataNames is nil.") }
        guard let booleanNames = occurrence.trackedBooleanDataNames else { fatalError("TrackedBooleanDataNames is nil.") }
        
        if stringNames.isEmpty && booleanNames.isEmpty && !occurrence.doesTrackLocation {
            tableView.allowsSelection = false
        } else {
            tableView.allowsSelection = true
        }
    }
    
    private func checkIfNoEntriesAreEntered() {
        if let objects = fetchedResultsController.fetchedObjects, objects.isEmpty {
            let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            label.text = "No Data"
            label.textColor = UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.0)
            label.textAlignment = .center
            label.font = label.font.withSize(26)
            tableView.backgroundView = label
            tableView.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.95, alpha:1.0)
            tableView.separatorStyle = .none
            
            exportBarButton!.isEnabled = false
        } else {
            tableView.backgroundView = nil
            tableView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            tableView.separatorStyle = .singleLine
            
            exportBarButton!.isEnabled = true
        }
    }
    
    func getDataAsFormattedString() -> String {
        guard let occurrenceName = detailedOccurrenceVC.selectedOccurrence.name else { fatalError("Could not get Occurrence Name.") }
        var textForCSV: String = "\(occurrenceName),"
        var stringDataOrder: [String] = [String]()
        var booleanDataOrder: [String] = [String]()

        // String Names
        if let stringNames = detailedOccurrenceVC.selectedOccurrence.trackedStringDataNames {
            for name in stringNames {
                textForCSV.append("\(name),")
                stringDataOrder.append("\(name)")
            }
        }

        // Boolean Names
        if let booleanNames = detailedOccurrenceVC.selectedOccurrence.trackedBooleanDataNames {
            for name in booleanNames {
                textForCSV.append("\(name),")
                booleanDataOrder.append("\(name)")
            }
        }

        // Location
        textForCSV.append("Tracked Location Address\n")

        // Entry Data
        if let entries = detailedOccurrenceVC.selectedOccurrence.entry {
            for entry in entries {
                guard let entry = entry as? OccurrenceEntry else { continue }
                guard let date = entry.enteredDataDateAsString() else { fatalError("Could not get the entered date.") }
                var newEntryLine: String = "\(date.makeCSVFileFormatSafe),"
                
                // String Data
                for nameKey in stringDataOrder {
                    if let value = entry.trackedStringData?[nameKey] {
                        newEntryLine.append("\(value.makeCSVFileFormatSafe),")
                    }
                }

                // Boolean Data
                for nameKey in booleanDataOrder {
                    if let value = entry.trackedBooleanData?[nameKey] {
                        let boolAsString: String = "\(value)"
                        newEntryLine.append("\(boolAsString.makeCSVFileFormatSafe),")
                    }
                }
                
                // Location Address
                if let formattedAddress = entry.formattedAddress {
                    newEntryLine.append("\(formattedAddress.makeCSVFileFormatSafe)")
                } else {
                    // Remove the last comma
                    newEntryLine.remove(at: newEntryLine.index(before: newEntryLine.endIndex))
                }
                
                newEntryLine.append("\n")
                
                textForCSV.append(newEntryLine)
            }
        }
        
        return textForCSV
    }
    
    @objc func exportButtonAction() {
        guard let occurrenceName = detailedOccurrenceVC.selectedOccurrence.name else { fatalError("Could not get Occurrence Name.") }
        
        let fileName = "\(occurrenceName) Exported Data.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        let formattedDataString: String = getDataAsFormattedString()
        
        if let path = path {
            do {
                try formattedDataString.write(to: path, atomically: true, encoding: String.Encoding.utf8)
                
                let activityViewController = UIActivityViewController(activityItems: [path], applicationActivities: [])
                activityViewController.excludedActivityTypes = [
                    .assignToContact,
                    .saveToCameraRoll,
                    .postToFlickr,
                    .postToVimeo,
                    .postToTencentWeibo,
                    .postToTwitter,
                    .postToFacebook,
                    .openInIBooks,
                ]
                present(activityViewController, animated: true, completion: nil)
                
            } catch let e as NSError {
                print("Failed to create file. Error: \(e)")
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).enteredDataDateAsString()
        
        guard let occurrence = detailedOccurrenceVC.selectedOccurrence else { fatalError("Selected Occurrence was not passed.") }
        guard let stringNames = occurrence.trackedStringDataNames else { fatalError("TrackedStringDataNames is nil.") }
        guard let booleanNames = occurrence.trackedBooleanDataNames else { fatalError("TrackedBooleanDataNames is nil.") }
        
        if stringNames.isEmpty && booleanNames.isEmpty && !occurrence.doesTrackLocation {
            cell.accessoryType = .none
        }
    }
    
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.navigationItem.rightBarButtonItem?.isEnabled = fetchedResultsController.fetchedObjects?.isEmpty ?? false ? false : true
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)

        configureCell(cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = fetchedResultsController.object(at: indexPath)
            fetchedResultsController.managedObjectContext.delete(entry)
            
            fetchedResultsController.saveData()
            
            // Reload the chart's data
            chartVC?.changeChartView()
            
            // Display No Data text if removed last entry
            checkIfNoEntriesAreEntered()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailedEntryVC = segue.destination as? DetailedOccurrenceEntryTableViewController {
            // Get the tapped on cell
            guard let selectedEntryCell = sender as? UITableViewCell else { fatalError("Unexpected sender: \(String(describing: sender))") }
            
            // Get the tapped on cell's indexPath
            guard let indexPath = tableView.indexPath(for: selectedEntryCell) else { fatalError("The selected cell is not being displayed by the table") }
            
            detailedEntryVC.selectedEntry = fetchedResultsController.object(at: indexPath)
            detailedEntryVC.selectedOccurrence = detailedOccurrenceVC.selectedOccurrence
        }
    }

}
