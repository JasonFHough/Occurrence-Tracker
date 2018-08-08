//
//  NewOccurrenceLocationViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/5/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import MapKit

class NewOccurrenceLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    @IBOutlet weak var locationNoteLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        askForLocationAccess()
        
        locationSwitch.addTarget(self, action: #selector(askForLocationAccess), for: .valueChanged)
    }

    @IBAction private func previousButtonAction(_ sender: UIButton) {
        guard let parentView = self.parent as? NewOccurrencePageViewController else { return }
        parentView.goToPreviousPage()
    }
    
    @IBAction private func nextButtonAction(_ sender: UIButton) {
        guard let parentView = self.parent as? NewOccurrencePageViewController else { return }
        parentView.goToNextPage()
    }
    
    @objc private func askForLocationAccess() {
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted, .notDetermined:
            locationNoteLabel.isHidden = false
            locationSwitch.isOn = false
            locationSwitch.isEnabled = false
            
            locationManager.requestAlwaysAuthorization()
        default:
            locationNoteLabel.isHidden = true
            locationSwitch.isEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        askForLocationAccess()
    }
    
}
