//
//  NewOccurrenceViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 6/11/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit

class NewOccurrenceViewController: UIViewController {

    var displayAdDelegate: DisplayInterstitialAdDelegate!
    var newOccurrenceDelegate: NewOccurrenceDelegate!
    
    @IBOutlet weak var previousBarButton: UIBarButtonItem!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newOccurrencePageViewController = segue.destination as? NewOccurrencePageViewController {
            newOccurrencePageViewController.newPageDelegate = self
            newOccurrencePageViewController.newOccurrenceDelegate = newOccurrenceDelegate
            newOccurrencePageViewController.previousBarButton = self.previousBarButton
            newOccurrencePageViewController.nextBarButton = self.nextBarButton
        }
    }

    func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewOccurrenceViewController: NewOccurrencePageViewDelegate {
    
    func changePageTitle(to newTitle: String) {
        self.navigationItem.title = newTitle
    }
    
    func newOccurrencePageViewController(newOccurrencePageViewController: NewOccurrencePageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
        
        previousBarButton.title = "Cancel"
        previousBarButton.action = #selector(newOccurrencePageViewController.cancelOccurrence)
        nextBarButton.action = #selector(newOccurrencePageViewController.goToNextPage)
    }
    
    func newOccurrencePageViewController(newOccurrencePageViewController: NewOccurrencePageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        
        // Enabling/disabling previous button
        if newOccurrencePageViewController.getPreviousPage() == nil {
            previousBarButton.title = "Cancel"
            previousBarButton.action = #selector(newOccurrencePageViewController.cancelOccurrence)
        } else {
            previousBarButton.title = "Previous"
            previousBarButton.action = #selector(newOccurrencePageViewController.goToPreviousPage)
        }
        
        // Enabling/disabling next button
        if newOccurrencePageViewController.getNextPage() == nil {
            nextBarButton.isEnabled = false
            
            if let finishPage = newOccurrencePageViewController.getCurrentPage() as? FinishNewOccurrenceViewController {
                finishPage.checkForRequiredAttributes()
            }
        } else {
            nextBarButton.isEnabled = true
        }
    }
    
}
