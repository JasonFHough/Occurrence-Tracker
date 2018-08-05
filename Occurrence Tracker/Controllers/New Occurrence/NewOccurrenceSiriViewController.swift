//
//  NewOccurrenceSiriViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/5/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit

class NewOccurrenceSiriViewController: UIViewController {

    @IBOutlet weak var siriShortcutSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func previousButtonAction(_ sender: UIButton) {
        guard let parentView = self.parent as? NewOccurrencePageViewController else { return }
        parentView.goToPreviousPage()
    }
    
    @IBAction private func nextButtonAction(_ sender: UIButton) {
        guard let parentView = self.parent as? NewOccurrencePageViewController else { return }
        
        parentView.goToNextPage()
    }
    
}
