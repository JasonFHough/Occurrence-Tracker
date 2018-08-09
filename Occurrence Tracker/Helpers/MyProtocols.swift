//
//  MyProtocols.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 6/21/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import Foundation
import GoogleMobileAds

protocol DetailedOccurrenceDelegate {
    func passOccurrenceDataToDetailViewController(occurrenceObject: Occurrence, sourceVC: OccurrenceTableViewController, sourceCell: OccurrenceTableViewCell)
}

protocol NewOccurrenceDelegate {
    func createNewOccurrenceUsingCollectedData(name: String, identifier: String, doesTrackLocation: Bool, trackedStringDataNames: [String], trackedBooleanDataNames: [String])
}

protocol NewOccurrencePageViewDelegate {
    func changePageTitle(to newTitle: String)
    
    /**
     Called when the number of pages is updated.
     
     - parameter newOccurrencePageViewController: the NewOccurrencePageViewController instance
     - parameter count: the total number of pages.
     */
    func newOccurrencePageViewController(newOccurrencePageViewController: NewOccurrencePageViewController, didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter newOccurrencePageViewController: the NewOccurrencePageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func newOccurrencePageViewController(newOccurrencePageViewController: NewOccurrencePageViewController, didUpdatePageIndex index: Int)
}

protocol DisplayInterstitialAdDelegate {
    func display(interstitial: GADInterstitial)
}
