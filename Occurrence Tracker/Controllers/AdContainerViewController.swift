//
//  AdContainerViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 8/9/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdContainerViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var adView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AdMobInformation.initBannerAdView(view: adView, rootVC: self)
    }

    // MARK: - GADBannerViewDelegate
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.flyBannerInUpwards()
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads. Error: \(error)")
    }
    
}
