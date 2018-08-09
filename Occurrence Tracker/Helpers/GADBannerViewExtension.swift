//
//  GADBannerViewDelegateExtension.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 8/9/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension GADBannerView {
    // Animate the banner to slide up
    func flyBannerInUpwards() {
        let translateTransform = CGAffineTransform(translationX: 0, y: self.bounds.size.height)
        self.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform.identity
        }
    }
}
