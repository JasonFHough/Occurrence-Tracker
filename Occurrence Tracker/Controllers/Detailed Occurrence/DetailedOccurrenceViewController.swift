//
//  OccurrenceViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 6/12/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import ResearchKit
import CoreData

class DetailedOccurrenceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var selectedOccurrence: Occurrence!
    // The cell we tapped on
    private var sourceCell: OccurrenceTableViewCell!
    // The viewController we segued from
    private var sourceViewController: OccurrenceTableViewController!
    // The chart in this view's view controller
    var chartVC: DetailedOccurrenceChartViewController?
    var shownOnChartData: [OccurrenceEntry] = [OccurrenceEntry]()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    @IBOutlet weak var chartDatePicker: UIDatePicker!
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var chartUIView: UIView!
    
    // The GestureRecognizer used for dismissing the keyboard when changing titleNames
    private var titleTextFieldTap: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMinAndMaxDate()
        
        dataTableView.delegate = self
        dataTableView.dataSource = self
        titleTextField.delegate = self
        
        assignNavigationTitle()
        checkIfOccurrenceTracksAnyData()
    }
    
    private func checkIfOccurrenceTracksAnyData() {
        guard let occurrence = selectedOccurrence else { fatalError("Selected Occurrence was not passed to the DetailOccurrenceViewController.") }
        guard let stringNames = occurrence.trackedStringDataNames else { fatalError("TrackedStringDataNames is nil.") }
        guard let booleanNames = occurrence.trackedBooleanDataNames else { fatalError("TrackedBooleanDataNames is nil.") }
        if stringNames.isEmpty && booleanNames.isEmpty && !occurrence.doesTrackLocation {
            dataTableView.allowsSelection = false
        } else {
            dataTableView.allowsSelection = true
        }
    }
    
    func setMinAndMaxDate() {
        guard let occurrence = selectedOccurrence else { fatalError("Selected Occurrence was not passed to the DetailOccurrenceViewController.") }
        guard let entrySet = occurrence.entry else { fatalError("Occurrence Entry relationship is nil.") }
        
        var listOfDates: [Date] = [Date]()
        for entry in entrySet {
            if let e = entry as? OccurrenceEntry, let date = e.enteredDate {
                listOfDates.append(date)
            }
        }
        
        var earliestDate: Date?
        var latestDate: Date?
        for i in 0..<listOfDates.count {
            // Check for earliest
            if i == 0 {
                earliestDate = listOfDates[i]
            } else if listOfDates[i] < earliestDate! {
                earliestDate = listOfDates[i]
            }
            
            // Check for latest
            if i == 0 {
                latestDate = listOfDates[i]
            } else if listOfDates[i] > latestDate! {
                latestDate = listOfDates[i]
            }
        }
        
        chartDatePicker.minimumDate = earliestDate
        
        if latestDate == nil {
            chartDatePicker.maximumDate = Date()
        } else {
            chartDatePicker.maximumDate = latestDate
        }
        
    }
    
    private func assignNavigationTitle() {
        guard let o = selectedOccurrence else { return }
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        titleTextField.text = o.name
    }
    
    private func allowKeyboardToDismissOnTap() {
        if titleTextField.isFirstResponder && titleTextFieldTap == nil {
            titleTextFieldTap = UITapGestureRecognizer(target: self, action: #selector(dismissTitleTextFieldKeyboard))
            
            guard let tap = titleTextFieldTap else { return }
            
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
    }
    
    private func removeKeyboardDismissOnTap() {
        guard let tap = titleTextFieldTap else { return }
        view.removeGestureRecognizer(tap)
        titleTextFieldTap = nil
    }
    
    @objc private func dismissTitleTextFieldKeyboard() {
        // If keyboard is assigned to the titleTextField, dismiss it and remove border style
        if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
            titleTextField.borderStyle = UITextBorderStyle.none
        }
    }
    
    private func updateOccurrenceName() {
        // Applies the new name to the occurrence
        guard let titleText = titleTextField.text else { return }
        guard let sourceVC = sourceViewController else { return }
        guard let cell = sourceCell else { return }
        guard let cellPath = sourceVC.tableView.indexPath(for: cell) else { return }
        selectedOccurrence?.name = titleText
        sourceVC.tableView.reloadRows(at: [cellPath], with: .none)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // If the occurrence doesn't track any specific data, then don't segue but still add the occurrence entry and display an alert
        if identifier == "LogOccurrenceEntry" {
            guard let occurrence = selectedOccurrence else { fatalError("Selected Occurrence was not passed to the DetailOccurrenceViewController.") }
            guard let stringNames = occurrence.trackedStringDataNames else { fatalError("TrackedStringDataNames is nil.") }
            guard let booleanNames = occurrence.trackedBooleanDataNames else { fatalError("TrackedBooleanDataNames is nil.") }
            
            if stringNames.isEmpty && booleanNames.isEmpty && !occurrence.doesTrackLocation {
                guard let context = container?.viewContext else { fatalError("No context.") }
                guard let entity = NSEntityDescription.entity(forEntityName: "OccurrenceEntry", in: context) else { fatalError("Could not assign EntityDescription") }
                let entry = OccurrenceEntry(entity: entity, insertInto: context)
                entry.identifier = UUID().uuidString
                entry.enteredDate = Date()
                entry.trackedStringData = [:]
                entry.trackedBooleanData = [:]
                entry.trackedLocation = nil
                entry.formattedAddress = nil
                occurrence.addToEntry(entry)
                
                do {
                    try context.save()
                } catch let e as NSError {
                    print("Error saving a new entry. Error: \(e)")
                }
                
                setMinAndMaxDate()
                chartVC?.changeChartView()
                
                Alert.showSuccessfulLoggedEntryAlert(on: self)
                
                return false
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chartVC = segue.destination as? DetailedOccurrenceChartViewController {
            chartVC.detailedOccurrenceVC = self
        } else if let allDataVC = segue.destination as? AllDataTableViewController {
            allDataVC.detailedOccurrenceVC = self
            allDataVC.chartVC = self.chartVC
        } else if let detailedEntryVC = segue.destination as? DetailedOccurrenceEntryTableViewController {
            // Get the tapped on cell
            guard let selectedEntryCell = sender as? UITableViewCell else { fatalError("Unexpected sender: \(String(describing: sender))") }
            // Get the tapped on cell's indexPath
            guard let indexPath = dataTableView.indexPath(for: selectedEntryCell) else { fatalError("The selected cell is not being displayed by the table") }
            guard let occurrence = self.selectedOccurrence else { fatalError("Selected Occurrence was not passed to the DetailOccurrenceViewController.") }
            
            detailedEntryVC.selectedEntry = shownOnChartData[indexPath.row]
            detailedEntryVC.selectedOccurrence = occurrence
        } else if let logEntryVC = segue.destination as? LogOccurrenceEntryTableViewController {
            logEntryVC.detailedOccurrenceVC = self
            logEntryVC.selectedOccurrence = self.selectedOccurrence
        }
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownOnChartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chartEntryCell")! as! ShownChartDataTableViewCell
        
        cell.leftLabel.text = self.shownOnChartData[indexPath.row].enteredDataDateAsString()
        
        guard let occurrence = selectedOccurrence else { fatalError("Selected Occurrence was not passed to the DetailOccurrenceViewController.") }
        guard let stringNames = occurrence.trackedStringDataNames else { fatalError("TrackedStringDataNames is nil.") }
        guard let booleanNames = occurrence.trackedBooleanDataNames else { fatalError("TrackedBooleanDataNames is nil.") }
        
        if stringNames.isEmpty && booleanNames.isEmpty && !occurrence.doesTrackLocation {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let context = container?.viewContext else { fatalError("Could not get the context.") }
            
            let deletingCell = shownOnChartData[indexPath.row] as OccurrenceEntry
            
            let fetchRequest: NSFetchRequest<OccurrenceEntry> = OccurrenceEntry.fetchRequest()
            guard let uuidString = deletingCell.identifier else { fatalError("Could not get identifier.") }
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuidString)
            
            do {
                let result = try context.fetch(fetchRequest)
                context.delete(result[0])
                try context.save()
            } catch let e as NSError {
                print("Error trying to save OccurrenceEntry deletion. Error: \(e)")
            }
            
            shownOnChartData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            chartVC?.changeChartView()
        }
    }
    
}

// MARK: - Extensions

extension DetailedOccurrenceViewController: DetailedOccurrenceDelegate {
    func passOccurrenceDataToDetailViewController(occurrenceObject: Occurrence, sourceVC: OccurrenceTableViewController, sourceCell: OccurrenceTableViewCell) {
        selectedOccurrence = occurrenceObject
        sourceViewController = sourceVC
        self.sourceCell = sourceCell
    }
}

extension DetailedOccurrenceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        // Prevents the spacebar from being the first character
        if (text.isEmpty && string == " ") {
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Enable the gestureRecognizer
        allowKeyboardToDismissOnTap()
        
        // Change text field boarder style
        titleTextField.borderStyle = UITextBorderStyle.roundedRect
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        titleTextField.sizeToFit()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // If keyboard was dismissed with empty text, default the text to what it was before
        if let text = titleTextField.text, text.isEmpty {
            titleTextField.text = selectedOccurrence.name
            titleTextField.sizeToFit()
        } else {
            updateOccurrenceName()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard
        dismissTitleTextFieldKeyboard()
        
        // Remove the gestureRecognizer
        removeKeyboardDismissOnTap()
        
        return true
    }
}
