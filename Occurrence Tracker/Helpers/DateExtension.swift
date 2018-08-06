//
//  MyExtensions.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/11/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import Foundation

extension Date {
    var getYear: Int { return Calendar.current.component(.year, from: self) }
    var getMonth: Int { return Calendar.current.component(.month, from: self) }
    var getDay: Int { return Calendar.current.component(.day, from: self) }
    var getHour: Int { return Calendar.current.component(.hour, from: self) }
    var getMinute: Int { return Calendar.current.component(.minute, from: self) }
    var getSecond: Int { return Calendar.current.component(.second, from: self) }
    
    var timeAs12Hour: String {
        let date = self
        let timeAsString = String("\(date.getHour):\(date.getMinute)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let time = dateFormatter.date(from: timeAsString)
        dateFormatter.dateFormat = "h:mm a"
        let formattedDate = dateFormatter.string(from: time!)
        
        return formattedDate
    }
    
    var formattedDate: String {
        let date = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: date)
    }
}
