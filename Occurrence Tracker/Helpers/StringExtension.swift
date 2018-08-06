//
//  StringExtension.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 8/6/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import Foundation

extension String {
    // In the event that the string includes any commas, we delimit the entire string to prevent .CSV making a new cell
    var makeCSVFileFormatSafe: String {
        var newString: String = self
        
        newString.insert("\"", at: newString.startIndex)
        newString.insert("\"", at: newString.index(before: newString.endIndex))
        
        return newString
    }
}
