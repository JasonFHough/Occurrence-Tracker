//
//  NewOccurrencePageViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 6/20/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit

class NewOccurrencePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var subViewControllers: [UIViewController] = {
       return [
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewOccurrenceNameView") as! NewOccurrenceNameViewController,
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrackedDataView") as! TrackedDataTableViewController,
//        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewOccurrenceSiriView") as! NewOccurrenceSiriViewController,
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewOccurrenceLocationView") as! NewOccurrenceLocationViewController,
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinishNewOccurrenceView") as! FinishNewOccurrenceViewController
        ]
    }()
    
    var newOccurrenceDelegate: NewOccurrenceDelegate?
    var newPageDelegate: NewOccurrencePageViewDelegate!
    
    var previousBarButton: UIBarButtonItem!
    var nextBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        previousBarButton.target = self
        nextBarButton.target = self
        previousBarButton.action = #selector(goToPreviousPage)
        nextBarButton.action = #selector(goToNextPage)
        
        // Set the VC that will display in the PageView first
        setViewControllers([subViewControllers[0]], direction: .forward, animated: true, completion: nil)
        
        // Assign the appropriate title for the first PageView
        newPageDelegate.changePageTitle(to: assignAppropriatePageTitle(using: 0))
        
        // Set the amount of PageControl dots
        newPageDelegate.newOccurrencePageViewController(newOccurrencePageViewController: self, didUpdatePageCount: subViewControllers.count)
    }
    
    func getCurrentPage() -> UIViewController? {
        return self.viewControllers?.first
    }
    
    func getNextPage() -> UIViewController? {
        guard let currentViewController = self.viewControllers?.first else { fatalError("Could not get the currentViewController.") }
        
        return dataSource?.pageViewController(self, viewControllerAfter: currentViewController)
    }
    
    func getPreviousPage() -> UIViewController? {
        guard let currentViewController = self.viewControllers?.first else { fatalError("Could not get the currentViewController.") }
        return dataSource?.pageViewController(self, viewControllerBefore: currentViewController)
    }
    
    @objc func goToNextPage() {
        if let nextViewController = getNextPage() {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
            newPageDelegate.newOccurrencePageViewController(newOccurrencePageViewController: self, didUpdatePageIndex: subViewControllers.index(of: nextViewController)!)
            newPageDelegate.changePageTitle(to: assignAppropriatePageTitle(using: subViewControllers.index(of: nextViewController)!))
        }
    }
    
    @objc func goToPreviousPage() {
        if let previousViewController = getPreviousPage() {
            setViewControllers([previousViewController], direction: .reverse, animated: true, completion: nil)
            newPageDelegate.newOccurrencePageViewController(newOccurrencePageViewController: self, didUpdatePageIndex: subViewControllers.index(of: previousViewController)!)
            newPageDelegate.changePageTitle(to: assignAppropriatePageTitle(using: subViewControllers.index(of: previousViewController)!))
        }
    }
    
    @objc func cancelOccurrence() {
        guard let parentView = self.parent as? NewOccurrenceViewController else { return }
        parentView.dismissView()
    }
    
    private func assignAppropriatePageTitle(using indexValue: Int) -> String {
        switch indexValue {
        case 0:
            return "Name of Occurrence"
        case 1:
            return "Tracked Data"
        case 2:
            return "Use Location"
        case 3:
            return "Finish"
        default:
            return "New Occurrence"
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex: Int = subViewControllers.index(of: viewController) ?? 0
        
        if currentIndex <= 0 {
            return nil
        }
        
        return subViewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex: Int = subViewControllers.index(of: viewController) ?? 0
        
        if currentIndex >= subViewControllers.count - 1 {
            return nil
        }
        
        return subViewControllers[currentIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let firstViewController = viewControllers?.first, let index = subViewControllers.index(of: firstViewController) {
            newPageDelegate.changePageTitle(to: assignAppropriatePageTitle(using: index))
            newPageDelegate.newOccurrencePageViewController(newOccurrencePageViewController: self, didUpdatePageIndex: index)
        }
        
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    
}
