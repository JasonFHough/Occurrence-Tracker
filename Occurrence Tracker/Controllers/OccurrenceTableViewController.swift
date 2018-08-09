//
//  OccurrenceTableViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 6/10/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import CoreData

class OccurrenceTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<Occurrence>!
    var detailedOccurrenceDelegate: DetailedOccurrenceDelegate!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Updates number of entries when user taps the back button from DetailedOccurrenceViewController
    override func didMove(toParentViewController parent: UIViewController?) {
        if let nav = parent as? UINavigationController, let _ = nav.topViewController as? OccurrenceTableViewController {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if fetchedResultsController == nil {
            // Assign fetch result controller
            let fetchRequest: NSFetchRequest<Occurrence> = Occurrence.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
            if let context = container?.viewContext {
                fetchedResultsController = NSFetchedResultsController<Occurrence>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController.delegate = self
            }
            
            // Retrieve all the data from the database
            fetchedResultsController.retrieveData()
        } else {
            // Save any new changes to the occurrence
            fetchedResultsController.saveData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if let objects = fetchedResultsController.fetchedObjects, !objects.isEmpty {
            let occurrence = fetchedResultsController.object(at: indexPath) as Occurrence
            cell.textLabel?.text = occurrence.name
            if let count = occurrence.entry?.count {
                cell.detailTextLabel?.text = "\(count) Entries"
            }
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
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "OccurrenceTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OccurrenceTableViewCell else { fatalError("The dequeued cell is not an instance of OccurrenceTableViewCell.") }
        
        configureCell(cell, at: indexPath)
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let occurrence = fetchedResultsController.object(at: indexPath)
            fetchedResultsController.managedObjectContext.delete(occurrence)
            
            fetchedResultsController.saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) { }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AddOccurrence":
            let destinationNavigationController = segue.destination as! UINavigationController
            let containerView = destinationNavigationController.topViewController as! NewOccurrenceViewController
            
            containerView.newOccurrenceDelegate = self
            
        case "OccurrenceDetail":
            // Get the VC we are seguing to
            guard let detailedOccurrenceVC = segue.destination as? DetailedOccurrenceViewController else { fatalError("Could not assign detailedOccurrenceDelegate") }
            
            detailedOccurrenceDelegate = detailedOccurrenceVC
            
            // Get the tapped on cell
            guard let selectedOccurrenceCell = sender as? OccurrenceTableViewCell else { fatalError("Unexpected sender: \(String(describing: sender))") }
            
            // Get the tapped on cell's indexPath
            guard let indexPath = tableView.indexPath(for: selectedOccurrenceCell) else { fatalError("The selected cell is not being displayed by the table") }
            
            let selectedOccurrence = fetchedResultsController.object(at: indexPath)
            
            detailedOccurrenceDelegate.passOccurrenceDataToDetailViewController(occurrenceObject: selectedOccurrence, sourceVC: self, sourceCell: selectedOccurrenceCell)
            
        default:
            fatalError("Unable to assign any delegate prior to navigation")
        }
    }
}

extension OccurrenceTableViewController: NewOccurrenceDelegate {
    func createNewOccurrenceUsingCollectedData(name: String, identifier: String, doesTrackLocation: Bool, trackedStringDataNames: [String], trackedBooleanDataNames: [String]) {
        let context = self.fetchedResultsController.managedObjectContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Occurrence", in: context) else { fatalError("Could not assign EntityDescription") }
        
        let occurrence = Occurrence(entity: entity, insertInto: context)
        occurrence.name = name
        occurrence.identifier = identifier
        occurrence.doesTrackLocation = doesTrackLocation
        occurrence.trackedStringDataNames = trackedStringDataNames
        occurrence.trackedBooleanDataNames = trackedBooleanDataNames
        occurrence.entry = []
        
        fetchedResultsController.saveData()
    }
}
