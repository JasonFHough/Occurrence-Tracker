//
//  NewOccurrenceViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 6/11/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit

class NewOccurrenceViewController: UIViewController {

    var newOccurrenceDelegate: NewOccurrenceDelegate!
    
    @IBOutlet weak private var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func cancelButtonActions(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newOccurrencePageViewController = segue.destination as? NewOccurrencePageViewController {
            newOccurrencePageViewController.newPageDelegate = self
            newOccurrencePageViewController.newOccurrenceDelegate = newOccurrenceDelegate
        }
    }

}

extension NewOccurrenceViewController: NewOccurrencePageViewDelegate {
    
    func changePageTitle(to newTitle: String) {
        self.navigationItem.title = newTitle
    }
    
    func newOccurrencePageViewController(newOccurrencePageViewController: NewOccurrencePageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func newOccurrencePageViewController(newOccurrencePageViewController: NewOccurrencePageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
