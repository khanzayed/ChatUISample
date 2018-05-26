//
//  DateHelper.swift
//  ChatUISample
//
//  Created by Faraz Habib on 26/05/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Foundation

class DateHelper {
    
    private let dateFormatter = DateFormatter()
    
    internal static var shared: DateHelper = {
        let instance = DateHelper()
        return instance
    }()

    private init() {
        
    }
    
    internal func getDateHeader(fromDate:Date) -> String? {
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return dateFormatter.string(from: fromDate)
    }
    
    internal func getMessageDate(fromDate:Date) -> String? {
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: fromDate)
    }
    
    internal func getTodayOrYesterday(fromDate:Date) -> String? {
        let calendar = NSCalendar.current
        
        if calendar.isDateInToday(fromDate) {
            return "Today"
        } else if calendar.isDateInYesterday(fromDate) {
            return "Yesterday"
        }
        
        return nil
    }
    
}
