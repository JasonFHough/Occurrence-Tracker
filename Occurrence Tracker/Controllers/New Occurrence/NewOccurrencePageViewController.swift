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
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewOccurrenceSiriView") as! NewOccurrenceSiriViewController,
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewOccurrenceLocationView") as! NewOccurrenceLocationViewController,
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinishNewOccurrenceView") as! FinishNewOccurrenceViewController
        ]
    }()
    
    var newOccurrenceDelegate: NewOccurrenceDelegate?
    var newPageDelegate: NewOccurrencePageViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        removePageSwipeGesture()
        
        // Set the VC that will display in the PageView first
        let startingVCArrayIndex: Int = 0
        setViewControllers([subViewControllers[startingVCArrayIndex]], direction: .forward, animated: true, completion: nil)
        
        // Assign the appropriate title for the first PageView
        newPageDelegate.changePageTitle(to: assignAppropriatePageTitle(using: startingVCArrayIndex))
        
        // Set the amount of PageControl dots
        newPageDelegate.newOccurrencePageViewController(newOccurrencePageViewController: self, didUpdatePageCount: subViewControllers.count)
    }
    
    private func removePageSwipeGesture(){
        for view in view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
    
    private func getNextPage() -> UIViewController? {
        guard let currentViewController = self.viewControllers?.first else { fatalError("Could not get the currentViewController.") }
        
        return dataSource?.pageViewController(self, viewControllerAfter: currentViewController)
    }
    
    func getPreviousPage() -> UIViewController? {
        guard let currentViewController = self.viewControllers?.first else { fatalError("Could not get the currentViewController.") }
        return dataSource?.pageViewController(self, viewControllerBefore: currentViewController)
    }
    
    func goToNextPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: animated, completion: nil)
        newPageDelegate.newOccurrencePageViewController(newOccurrencePageViewController: self, didUpdatePageIndex: subViewControllers.index(of: nextViewController)!)
        newPageDelegate.changePageTitle(to: assignAppropriatePageTitle(using: subViewControllers.index(of: nextViewController)!))
    }
    
    func goToPreviousPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: animated, completion: nil)
        newPageDelegate.newOccurrencePageViewController(newOccurrencePageViewController: self, didUpdatePageIndex: subViewControllers.index(of: previousViewController)!)
        newPageDelegate.changePageTitle(to: assignAppropriatePageTitle(using: subViewControllers.index(of: previousViewController)!))
    }
    
    private func assignAppropriatePageTitle(using indexValue: Int) -> String {
        switch indexValue {
        case 0:
            return "Name of Occurrence"
        case 1:
            return "Tracked Data"
        case 2:
            return "Use Siri Shortcut"
        case 3:
            return "Use Location"
        case 4:
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
