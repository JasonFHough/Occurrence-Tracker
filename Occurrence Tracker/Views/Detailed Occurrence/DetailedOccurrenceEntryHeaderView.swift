//
//  DetailedOccurrenceEntryHeaderView.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/20/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit

class DetailedOccurrenceEntryHeaderView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupHeaderView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let dataTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Tracked Data"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupHeaderView() {
        addSubview(dataTypeLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": dataTypeLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : dataTypeLabel]))
    }
    
}
