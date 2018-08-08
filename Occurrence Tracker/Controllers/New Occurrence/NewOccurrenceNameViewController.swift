//
//  NewOccurrenceNameViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/4/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit

class NewOccurrenceNameViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    // The GestureRecognizer used for dismissing the keyboard when changing titleNames
    private var textFieldTap: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
    }
    
    private func allowKeyboardToDismissOnTap() {
        if nameTextField.isFirstResponder && textFieldTap == nil {
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

extension NewOccurrenceNameViewController: UITextFieldDelegate {
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

