//
//  ChartViewController.swift
//  Occurrence Tracker
//
//  Created by Jason Hough on 7/8/18.
//  Copyright © 2018 Jason Hough. All rights reserved.
//

import UIKit
import ResearchKit

class DetailedOccurrenceChartViewController: UIViewController, ORKGraphChartViewDataSource, ORKValueRangeGraphChartViewDataSource, ORKGraphChartViewDelegate {
    
    var detailedOccurrenceVC: DetailedOccurrenceViewController!
    
    @IBOutlet var graphChartView: ORKLineGraphChartView!
    private var graphPlotPoints: [[ORKValueRange]] = [[ORKValueRange]]()
    private var xAxisTitles: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailedOccurrenceVC.chartVC = self
        
        graphChartView.delegate = self
        graphChartView.dataSource = self as ORKValueRangeGraphChartViewDataSource
        graphChartView.showsVerticalReferenceLines = graphPlotPoints.isEmpty ? false : true
        graphChartView.showsHorizontalReferenceLines = graphPlotPoints.isEmpty ? false : true
        
        detailedOccurrenceVC.chartDatePicker.addTarget(self, action: #selector(changeChartView), for: .valueChanged)
        detailedOccurrenceVC.chartSegmentedControl.addTarget(self, action: #selector(changeChartView), for: .valueChanged)
        
        detailedOccurrenceVC.chartSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    // MARK: - Sorting Graph View
    
    @objc func changeChartView() {
        if detailedOccurrenceVC.selectedOccurrence.entry?.count == 0 {
            return
        }
        
        removeAllRowsFromTableView()
        
        switch detailedOccurrenceVC.chartSegmentedControl.selectedSegmentIndex {
        case 0:     // Hour
            detailedOccurrenceVC.chartDatePicker.datePickerMode = .dateAndTime
            viewByHour()
        case 1:     // Day
            detailedOccurrenceVC.chartDatePicker.datePickerMode = .date
            viewByDay()
        case 2:     // Week
            detailedOccurrenceVC.chartDatePicker.datePickerMode = .date
            viewByWeek()
        case 3:     // Month
            detailedOccurrenceVC.chartDatePicker.datePickerMode = .date
            viewByMonth()
        case 4:     // Year
            detailedOccurrenceVC.chartDatePicker.datePickerMode = .date
            viewByYear()
        default:    // No Selection
            return
        }
        
        graphChartView.showsVerticalReferenceLines = graphPlotPoints.isEmpty ? false : true
        graphChartView.showsHorizontalReferenceLines = graphPlotPoints.isEmpty ? false : true
        
        graphChartView.reloadData()
    }
    
    /*
     - Chart should have a plot point for every minute in the selected hour
     - Each plot point value should be the number of occurrences that minute
     - Each plot point should have an X-Axis label that is the minute of the selected hour
     */
    func viewByHour() {
        // Get the chosen date
        let selectedDate = detailedOccurrenceVC.chartDatePicker.date
        let selectedHour = selectedDate.getHour
        let selectedDay = selectedDate.getDay
        let selectedYear = selectedDate.getYear
        
        // Remove all prior data
        graphPlotPoints.removeAll()
        xAxisTitles.removeAll()
        var points: [ORKValueRange] = [ORKValueRange]()
        
        // Filters all the entries to only get the entries that are the same week as the selectedDate
        var listOfDates: [Date] = [Date]()
        if let entries = detailedOccurrenceVC.selectedOccurrence.entry {
            for entry in entries {
                guard let entry = entry as? OccurrenceEntry else { continue }
                guard let date = entry.enteredDate else { fatalError("There isn't a date for this entry.") }
                let dateHour = date.getHour
                let dateDay = date.getDay
                let dateYear = date.getYear
                
                if selectedYear == dateYear && selectedDay == dateDay && selectedHour == dateHour {   // If the date equal to or prior to the seleted date, but in the same year, the day is the same, and the hour is the same
                    listOfDates.append(date)
                    
                    detailedOccurrenceVC.shownOnChartData.append(entry)
                }
            }
        }
        
        // Insert the data to the TableView all at once
        batchInsertChartDataToTableView(using: detailedOccurrenceVC.shownOnChartData)
        
        listOfDates.sort(by: <)

        // Calculate how many occurrences occurred in the same hour
        var occurrencesPerMinute: [Int : Double] = [:]  //Minute number as Int : Number of occurrences for that minute as Double
        for date in listOfDates {
            if occurrencesPerMinute.keys.contains(date.getMinute) {
                occurrencesPerMinute.updateValue(occurrencesPerMinute[date.getMinute]! + 1, forKey: date.getMinute)
            } else {
                occurrencesPerMinute[date.getMinute] = 1
                
                xAxisTitles.append("\(date.timeAs12Hour)")
            }
        }

        let sortedDateMinuteKeys = occurrencesPerMinute.sorted(by: <)

        // Apply the above calculated data to variables that will change the chart's data shown
        for (_, keyValue) in sortedDateMinuteKeys {
            points.append(ORKValueRange(value: keyValue))
        }

        graphPlotPoints = [points]
    }
    
    /*
     - Chart should have a plot point for every hour in the selected day
     - Each plot point value should be the number of occurrences that hour
     - Each plot point should have an X-Axis label that is the hour of the selected day
     */
    func viewByDay() {
        // Get the chosen date
        let selectedDate = detailedOccurrenceVC.chartDatePicker.date
        let selectedDay = selectedDate.getDay
        let selectedYear = selectedDate.getYear
        
        // Remove all prior data
        graphPlotPoints.removeAll()
        xAxisTitles.removeAll()
        var points: [ORKValueRange] = [ORKValueRange]()
        
        // Filters all the entries to only get the entries that are the same week as the selectedDate
        var listOfDates: [Date] = [Date]()
        if let entries = detailedOccurrenceVC.selectedOccurrence.entry {
            for entry in entries {
                guard let entry = entry as? OccurrenceEntry else { continue }
                guard let date = entry.enteredDate else { fatalError("There isn't a date for this entry.") }
                let dateDay = date.getDay
                let dateYear = date.getYear
                
                if selectedYear == dateYear && selectedDay == dateDay {   // If the date equal to or prior to the seleted date, but in the same year and the day is the same
                    listOfDates.append(date)
                    
                    detailedOccurrenceVC.shownOnChartData.append(entry)
                }
            }
        }
        
        // Insert the data to the TableView all at once
        batchInsertChartDataToTableView(using: detailedOccurrenceVC.shownOnChartData)
        
        listOfDates.sort(by: <)
        
        // Calculate how many occurrences occurred in the same day
        var occurrencesPerHour: [Int : Double] = [:]  //Hour number as Int : Number of occurrences for that hour as Double
        for date in listOfDates {
            if occurrencesPerHour.keys.contains(date.getHour) {
                occurrencesPerHour.updateValue(occurrencesPerHour[date.getHour]! + 1, forKey: date.getHour)
            } else {
                occurrencesPerHour[date.getHour] = 1
                xAxisTitles.append("\(date.timeAs12Hour)")
            }
        }
        
        let sortedDateHourKeys = occurrencesPerHour.sorted(by: <)
        
        // Apply the above calculated data to variables that will change the chart's data shown
        for (_, keyValue) in sortedDateHourKeys {
            points.append(ORKValueRange(value: keyValue))
        }
        
        graphPlotPoints = [points]
    }
    
    /*
     - Chart should have a plot point for every day in the selected week
     - Each plot point value should be the number of occurrences that day
     - Each plot point should have an X-Axis label that is the day of the selected month
     */
    func viewByWeek() {
        // Get the chosen date
        let selectedDate = detailedOccurrenceVC.chartDatePicker.date
        let selectedYear = selectedDate.getYear
        let selectedWeekOfTheYear = Calendar.current.component(.weekOfYear, from: selectedDate)
        
        // Remove all prior data
        graphPlotPoints.removeAll()
        xAxisTitles.removeAll()
        var points: [ORKValueRange] = [ORKValueRange]()
        
        // Filters all the entries to only get the entries that are the same week as the selectedDate
        var listOfDates: [Date] = [Date]()
        if let entries = detailedOccurrenceVC.selectedOccurrence.entry {
            for entry in entries {
                guard let entry = entry as? OccurrenceEntry else { continue }
                guard let date = entry.enteredDate else { fatalError("There isn't a date for this entry.") }
                let dateYear = date.getYear
                let dateWeekOfTheYear = Calendar.current.component(.weekOfYear, from: date)
                
                if selectedWeekOfTheYear == dateWeekOfTheYear && selectedYear == dateYear {   // If the date is in the same week of the year as the selected date, and both are in the same year, then only add those days to the list
                    listOfDates.append(date)
                    
                    detailedOccurrenceVC.shownOnChartData.append(entry)
                }
            }
        }
        
        // Insert the data to the TableView all at once
        batchInsertChartDataToTableView(using: detailedOccurrenceVC.shownOnChartData)
        
        listOfDates.sort(by: <)
        
        // Calculate how many occurrences occurred on the same day
        var occurrencesPerDay: [Int : Double] = [:]  //Day number as Int : Number of occurrences for that day as Double
        for date in listOfDates {
            if occurrencesPerDay.keys.contains(date.getDay) {
                occurrencesPerDay.updateValue(occurrencesPerDay[date.getDay]! + 1, forKey: date.getDay)
            } else {
                occurrencesPerDay[date.getDay] = 1
                xAxisTitles.append("\(date.getMonth)/\(date.getDay)")
            }
        }
        
        let sortedDateDayKeys = occurrencesPerDay.sorted(by: <)
        
        // Apply the above calculated data to variables that will change the chart's data shown
        for (_, keyValue) in sortedDateDayKeys {
            points.append(ORKValueRange(value: keyValue))
        }
        
        graphPlotPoints = [points]
        
    }
    
    /*
    - Chart should have a plot point for every day in the selected month
    - Each plot point value should be the number of occurrences that day
    - Each plot point should have an X-Axis label that is the day of the selected month
    */
    func viewByMonth() {
        // Get the chosen date
        let selectedDate = detailedOccurrenceVC.chartDatePicker.date
        let selectedMonth = selectedDate.getMonth
        let selectedYear = selectedDate.getYear
        
        // Remove all prior data
        graphPlotPoints.removeAll()
        xAxisTitles.removeAll()
        var points: [ORKValueRange] = [ORKValueRange]()
        
        // Filters all the entries to only get the entries that are the same month as the selectedDate
        var listOfDates: [Date] = [Date]()
        if let entries = detailedOccurrenceVC.selectedOccurrence.entry {
            for entry in entries {
                guard let entry = entry as? OccurrenceEntry else { continue }
                guard let date = entry.enteredDate else { fatalError("There isn't a date for this entry.") }
                let dateMonth = date.getMonth
                let dateYear = date.getYear
                
                if selectedYear == dateYear && selectedMonth == dateMonth {   // If the date is in the same year and month
                    listOfDates.append(date)
                    
                    detailedOccurrenceVC.shownOnChartData.append(entry)
                }
            }
        }
        
        // Insert the data to the TableView all at once
        batchInsertChartDataToTableView(using: detailedOccurrenceVC.shownOnChartData)
        
        listOfDates.sort(by: <)
        
        // Calculate how many occurrences occurred on the same day
        var occurrencesPerDay: [Int : Double] = [:]  //Day number as Int : Number of occurrences for that day as Double
        for date in listOfDates {
            if occurrencesPerDay.keys.contains(date.getDay) {
                occurrencesPerDay.updateValue(occurrencesPerDay[date.getDay]! + 1, forKey: date.getDay)
            } else {
                occurrencesPerDay[date.getDay] = 1
                xAxisTitles.append("\(date.getMonth)/\(date.getDay)")
            }
        }
        
        let sortedDateDayKeys = occurrencesPerDay.sorted(by: <)
        
        // Apply the above calculated data to variables that will change the chart's data shown
        for (_, keyValue) in sortedDateDayKeys {
            points.append(ORKValueRange(value: keyValue))
        }
        
        graphPlotPoints = [points]
    }
    
    /*
     - Chart should have a plot point for every month in the selected year
     - Each plot point value should be the number of occurrences that month
     - Each plot point should have an X-Axis label that is the month of the selected year
     */
    func viewByYear() {
        // Get the chosen date
        let selectedDate = detailedOccurrenceVC.chartDatePicker.date
        let selectedYear = selectedDate.getYear
        
        // Remove all prior data
        graphPlotPoints.removeAll()
        xAxisTitles.removeAll()
        var points: [ORKValueRange] = [ORKValueRange]()
        
        // Filters all the entries to only get the entries that are the same year as the selectedDate
        var listOfDates: [Date] = [Date]()
        if let entries = detailedOccurrenceVC.selectedOccurrence.entry {
            for entry in entries {
                guard let entry = entry as? OccurrenceEntry else { continue }
                guard let date = entry.enteredDate else { fatalError("There isn't a date for this entry.") }
                let dateYear = date.getYear
                
                if selectedYear == dateYear {   // If the date is in the same year
                    listOfDates.append(date)
                    
                    detailedOccurrenceVC.shownOnChartData.append(entry)
                }
            }
        }
        
        // Insert the data to the TableView all at once
        batchInsertChartDataToTableView(using: detailedOccurrenceVC.shownOnChartData)
        
        // Calculate how many occurrences occurred in the same month
        var occurrencesPerMonth: [Int : Double] = [:]  //Month number as Int : Number of occurrences for that month as Double
        for date in listOfDates {
            if occurrencesPerMonth.keys.contains(date.getMonth) {
                occurrencesPerMonth.updateValue(occurrencesPerMonth[date.getMonth]! + 1, forKey: date.getMonth)
            } else {
                occurrencesPerMonth[date.getMonth] = 1
                xAxisTitles.append("\(date.getMonth)/\(date.getYear)")
            }
        }
        
        let sortedDateMonthKeys = occurrencesPerMonth.sorted(by: <)
        
        // Apply the above calculated data to variables that will change the chart's data shown
        for (_, keyValue) in sortedDateMonthKeys {
            points.append(ORKValueRange(value: keyValue))
        }
        
        graphPlotPoints = [points]
    }
    
    func batchInsertChartDataToTableView(using entries: [OccurrenceEntry]) {
        if entries.isEmpty {
            return
        }
        
        var indexPaths: [IndexPath] = [IndexPath]()
        for i in 0..<entries.count {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        
        if !indexPaths.isEmpty {
            detailedOccurrenceVC.dataTableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func removeAllRowsFromTableView() {
        detailedOccurrenceVC.shownOnChartData.removeAll()
        detailedOccurrenceVC.dataTableView.reloadData()
    }
    
    // MARK: - Required Graph Chart Functions
    
    // Number of points on the graph. Needs to be within range of plotPoints[][]
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        return graphPlotPoints[plotIndex].count
    }
    
    // Puts plotPoints on the graph
    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
        return graphPlotPoints[plotIndex][pointIndex]
    }
    
    // Number of plots (graphs) being displayed
    func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return graphPlotPoints.count
    }
    
    // MARK: - Optional Graph Chart Methods
    
//    // The color of the chart
//    func graphChartView(_ graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
//        return .red
//    }
//
//    func graphChartView(_ graphChartView: ORKGraphChartView, fillColorForPlotIndex plotIndex: Int) -> UIColor {
//        return .red
//    }
    
    // X-Axis point title
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        if graphPlotPoints.isEmpty {
            return nil
        } else {
            return xAxisTitles[pointIndex]
        }
    }

    func graphChartView(_ graphChartView: ORKGraphChartView, drawsPointIndicatorsForPlotIndex plotIndex: Int) -> Bool {
        return true
    }

//    func graphChartView(_ graphChartView: ORKGraphChartView, accessibilityUnitLabelForPlotIndex plotIndex: Int) -> String {
//
//    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, drawsVerticalReferenceLineAtPointIndex pointIndex: Int) -> Bool {
        return true
    }
    
//    func graphChartView(_ graphChartView: ORKGraphChartView, accessibilityLabelForXAxisAtPointIndex pointIndex: Int) -> String {
//
//    }
    
    // Returns the highest value in graphPlotPoints
    func maximumValue(for graphChartView: ORKGraphChartView) -> Double {
        if graphPlotPoints.isEmpty {
            return 1
        }
        
        var maxValue: Double = 0
        for point in graphPlotPoints[0] {
            if point.maximumValue > maxValue {
                maxValue = point.maximumValue
            }
        }
        
        return maxValue
    }

    func minimumValue(for graphChartView: ORKGraphChartView) -> Double {
        return 0
    }
    
//    func scrubbingPlotIndex(for graphChartView: ORKGraphChartView) -> Int {
//
//    }
    
    func numberOfDivisionsInXAxis(for graphChartView: ORKGraphChartView) -> Int {
        if graphPlotPoints.isEmpty {
            return 2
        } else {
            return graphPlotPoints[0].count
        }
    }
    
}
