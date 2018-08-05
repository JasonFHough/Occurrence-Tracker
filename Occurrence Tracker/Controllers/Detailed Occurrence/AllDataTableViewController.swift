//
//  AllDataTableViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/19/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import CoreData

class AllDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<OccurrenceEntry>!
    
    var chartVC: DetailedOccurrenceChartViewController?
    var detailedOccurrenceVC: DetailedOccurrenceViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        } else {
            tableView.backgroundView = nil
            tableView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            tableView.separatorStyle = .singleLine
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
