//
//  FinishNewOccurrenceViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/5/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import GoogleMobileAds

class FinishNewOccurrenceViewController: UIViewController, GADInterstitialDelegate {
    
    private var parentView: NewOccurrencePageViewController?
    private var pageViewPages: [UIViewController]?
    
    var interstitialAd: GADInterstitial?
    var displayAdDelegate: DisplayInterstitialAdDelegate!
    
    @IBOutlet weak var missingNameLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Store a reference to the PageViewController
        if let parent = self.parent as? NewOccurrencePageViewController {
            parentView = parent
            pageViewPages = parent.subViewControllers
            
            // Set the displayAdDelegate from the var in NewOccurrenceViewController
            if let newOccurrenceVC = parent.parent as? NewOccurrenceViewController {
                displayAdDelegate = newOccurrenceVC.displayAdDelegate
            }
        }
        
        interstitialAd = createAndLoadInterstitial()
        
        checkForRequiredAttributes()
    }
    
    // MARK: - GADInterstitial
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        let interstitial = GADInterstitial(adUnitID: AdMobInformation.interstitialTestID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitialAd = createAndLoadInterstitial()
    }
    
    // MARK: - Other functions
    
    func checkForRequiredAttributes() {
        // Prevent finishing without a name
        if let pages = pageViewPages {
            let namePage = pages[0] as! NewOccurrenceNameViewController
            let name = namePage.nameTextField.text
            if name == "" {
                finishButton.isEnabled = false
                missingNameLabel.isHidden = false
            } else {
                finishButton.isEnabled = true
                missingNameLabel.isHidden = true
            }
        }
    }
    
    @IBAction private func finishOccurrenceButtonAction(_ sender: UIButton) {
        guard let pages = pageViewPages else { fatalError("Could not finalize the new occurrence") }
        
        // Get references to each page's specific ViewController
        let namePage = pages[0] as! NewOccurrenceNameViewController
        let trackDataPage = pages[1] as! TrackedDataTableViewController
        let locationPage = pages[2] as! NewOccurrenceLocationViewController
        
        // Start collecting the data for each piece of the Occurrence
        let occurrenceName = namePage.nameTextField.text
        guard let name = occurrenceName else { fatalError("Could not finalize the new occurrence") }
        let identifier = UUID().uuidString
        var trackedStringDataNames: [String] = []
        var trackedBooleanDataNames: [String] = []
        for section in 0 ..< trackDataPage.tableView.numberOfSections {
            let rowCount = trackDataPage.tableView.numberOfRows(inSection: section)
            
            for row in 0 ..< rowCount {
                if section == 0 {
                    guard let cell = trackDataPage.tableView.cellForRow(at: IndexPath(row: row, section: section)) as? StringDataTableViewCell else { continue }
                    
                    guard let text = cell.stringDataNameTextField.text else { fatalError("Data did not have a name entered.") }
                    
                    if !text.isEmpty {
                        trackedStringDataNames.append(text)
                    }
                    
                } else if section == 1 {
                    guard let cell = trackDataPage.tableView.cellForRow(at: IndexPath(row: row, section: section)) as? BooleanDataTableViewCell else { continue }
                    
                    guard let text = cell.booleanDataNameTextField.text else { fatalError("Data did not have a name entered.") }
                    
                    if !text.isEmpty {
                        trackedBooleanDataNames.append(text)
                    }
                }
            }
        }
        
        let useLocation = locationPage.locationSwitch.isOn
        
        // Send the Occurrence Data to OccurrenceTableViewController
        parentView?.newOccurrenceDelegate?.createNewOccurrenceUsingCollectedData(name: name, identifier: identifier, doesTrackLocation: useLocation, trackedStringDataNames: trackedStringDataNames, trackedBooleanDataNames: trackedBooleanDataNames)
        
        // Go back to the home view
        dismiss(animated: true, completion: nil)
        
        // Tell OccurrenceTableViewController to display the interstitial
        if let interstitial = interstitialAd {
            displayAdDelegate.display(interstitial: interstitial)
        }
    }
    
}
