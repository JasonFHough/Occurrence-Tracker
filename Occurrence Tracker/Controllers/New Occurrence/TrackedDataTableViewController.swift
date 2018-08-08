//
//  TrackedDataTableViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 6/20/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit

class TrackedDataTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var stringEditButton: UIButton?
    private var booleanEditButton: UIButton?
    
    private var numOfStringData = 0
    private var numOfBooleanData = 0
    
    // The GestureRecognizer used for dismissing the keyboard when changing titleNames
    private var textFieldTap: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TrackedDataHeaderView.self, forHeaderFooterViewReuseIdentifier: "TrackedDataHeaderView")
    }

    @objc private func addStringDataButtonAction() {
        numOfStringData += 1
        let indexPath = IndexPath(row: numOfStringData - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @objc private func addBooleanDataButtonAction() {
        numOfBooleanData += 1
        let indexPath = IndexPath(row: numOfBooleanData - 1, section: 1)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @objc private func editStringButtonAction() {
        guard let stringButton = stringEditButton else { return }
        guard let booleanButton = booleanEditButton else { return }
        
        if numOfStringData == 0 {
            return
        }
        
        booleanButton.isEnabled = !booleanButton.isEnabled
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        tableView.isEditing ? stringButton.setTitle("Done", for: .normal) : stringButton.setTitle("Edit", for: .normal)
    }
    
    @objc private func editBooleanButtonAction() {
        guard let stringButton = stringEditButton else { return }
        guard let booleanButton = booleanEditButton else { return }
        
        if numOfBooleanData == 0 {
            return
        }
        
        stringButton.isEnabled = !stringButton.isEnabled

        tableView.setEditing(!tableView.isEditing, animated: true)
        
        tableView.isEditing ? booleanButton.setTitle("Done", for: .normal) : booleanButton.setTitle("Edit", for: .normal)
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return numOfStringData
        case 1:
            return numOfBooleanData
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StringDataCell", for: indexPath) as? StringDataTableViewCell else { fatalError("Could not downcast to StringDataTableViewCell") }
            
            cell.stringDataNameTextField.delegate = self
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BooleanDataCell", for: indexPath) as? BooleanDataTableViewCell else { fatalError("Could not downcast to BooleanDataTableViewCell") }
            
            cell.booleanDataNameTextField.delegate = self
            
            return cell
        default:
            fatalError("Could not dequeue cell for either StringData or BooleanData")
        }
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier:"TrackedDataHeaderView") as! TrackedDataHeaderView
            header.dataTypeLabel.text = "String Data"
            header.addButton.addTarget(self, action: #selector(self.addStringDataButtonAction), for: .touchUpInside)
            header.editButton.addTarget(self, action: #selector(self.editStringButtonAction), for: .touchUpInside)
            stringEditButton = header.editButton
            return header
        case 1:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier:"TrackedDataHeaderView") as! TrackedDataHeaderView
            header.dataTypeLabel.text = "Boolean Data"
            header.addButton.addTarget(self, action: #selector(self.addBooleanDataButtonAction), for: .touchUpInside)
            header.editButton.addTarget(self, action: #selector(self.editBooleanButtonAction), for: .touchUpInside)
            booleanEditButton = header.editButton
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if booleanEditButton?.isEnabled == false && indexPath.section == 0 {
            return true
        } else if stringEditButton?.isEnabled == false && indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                numOfStringData -= 1
                
                if numOfStringData == 0 {
                    stringEditButton?.isEnabled = true
                    booleanEditButton?.isEnabled = true
                    tableView.setEditing(false, animated: true)
                    stringEditButton?.setTitle("Edit", for: .normal)
                }
            case 1:
                numOfBooleanData -= 1
                
                if numOfBooleanData == 0 {
                    stringEditButton?.isEnabled = true
                    booleanEditButton?.isEnabled = true
                    tableView.setEditing(false, animated: true)
                    booleanEditButton?.setTitle("Edit", for: .normal)
                }
            default:
                fatalError("Could not remove row from data source")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: - TextField Functions
    
    private func allowKeyboardToDismissOnTap() {
        if textFieldTap == nil {
            textFieldTap = UITapGestureRecognizer(target: self, action: #selector(dismissTitleTextFieldKeyboard))
            
            guard let tap = textFieldTap else { return }
            
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
    }
    
    private func removeKeyboardDismissOnTap() {
        guard let tap = textFieldTap else { return }
        view.removeGestureRecognizer(tap)
        textFieldTap = nil
    }
    
    @objc private func dismissTitleTextFieldKeyboard() {
        view.endEditing(true)
    }
    
}

extension TrackedDataTableViewController: UITextFieldDelegate {
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
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard
        dismissTitleTextFieldKeyboard()
        
        // Remove the gestureRecognizer
        removeKeyboardDismissOnTap()
        
        return true
    }
}












