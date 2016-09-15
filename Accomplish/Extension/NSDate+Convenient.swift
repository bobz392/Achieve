//
//  NSDate+Convenient.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let uuidFormat: String = "yyMMddHHmmssZ"
internal let createdDateFormat: String = "yyyy.MM.dd"
let timeDateFormat: String = "hh: mm a"
let monthDayFormat: String = "MM/dd"
let monthFormat: String = "MMM YYYY"
let onlyTimeFormat = "hh:mm"
let onlyAmFormat = "a"

// TASK
extension NSDate {
    func createTaskUUID() -> String {
        return (self as NSDate).formattedDate(withFormat: uuidFormat + uuidGenerator())
    }
    
    func createdFormatedDateString() -> String {
        debugPrint("created formated date string = \(self.formattedDate(withFormat: createdDateFormat, locale: Locale.init(identifier: "en_US")))")
        return self.formattedDate(withFormat: createdDateFormat, locale: Locale.init(identifier: "en_US"))
    }
    
    func toLocalDate() -> NSDate {
        let zone = TimeZone.current
        let iter = TimeInterval(zone.secondsFromGMT(for: self as Date))
        return self.addingTimeInterval(iter)
    }
    
    func timeDateString() -> String {
        return self.formattedDate(withFormat: timeDateFormat)
    }
    
    func timeString() -> String {
        return self.formattedDate(withFormat: onlyTimeFormat)
    }
    func am() -> String {
        return self.formattedDate(withFormat: onlyAmFormat)
    }
    
    func isLaterThenToday() -> Bool {
        let now = Date()
        return self.isToday() || self.isLaterThan(now)
    }
    
    func isMorning() -> Bool {
        return self.hour() < 10
    }
}
