//
//  Alert.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/26/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit

struct Alert {
    static func showSuccessfulLoggedEntryAlert(on viewController: UIViewController, popNavViewControllerOnCompletion: Bool? = false) {
        let alert = UIAlertController(title: "Entry Added", message: "The entry was successfully logged.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) {
            UIAlertAction in
            if let pop = popNavViewControllerOnCompletion, pop {
                alert.dismiss(animated: true, completion: nil)
                viewController.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
