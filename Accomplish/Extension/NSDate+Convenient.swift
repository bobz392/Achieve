//
//  NSDate+Convenient.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let FullStyleFormat = "yy/MM/dd/HH:mm:ss"
let UUIDFormat = "yyMMddHHmmssZ"
let CreatedDateFormat = "yyyy.MM.dd"
let TimeDateFormat = "hh: mm a"
let ReportDateFormat = "HH:mm"
let MonthDayFormat = "MMMM dd"
let MonthFormat = "MMMM"
let OnlyTimeFormat = "hh:mm aa"
let ChartQueryDateFormat = "yyyy.MM"
let MenuDateFormat = "MMMM  yyyy"

// TASK
extension NSDate {
    func createTaskUUID() -> String {
        return self.formattedDate(withFormat: UUIDFormat)
    }
    
    func createTagUUID() -> String {
        return self.formattedDate(withFormat: UUIDFormat) + "-tag"
    }
    
    func createTimeManagerUUID() -> String {
        return self.formattedDate(withFormat: UUIDFormat) + "-tm"
    }
    
    func createReadLaterUUID() -> String {
        return self.formattedDate(withFormat: UUIDFormat) + "-rl"
    }
    
    func createdFormatedDateString() -> String {
        guard let formateDate = self.formattedDate(withFormat: CreatedDateFormat, locale: Locale.init(identifier: "en_US")) else {
            fatalError()
        }
        
        return formateDate
    }
    
    func toLocalDate() -> NSDate {
        let zone = TimeZone.current
        let iter = TimeInterval(zone.secondsFromGMT(for: self as Date))
        return self.addingTimeInterval(iter)
    }
    
    func timeDateString() -> String {
        return self.formattedDate(withFormat: TimeDateFormat)
    }
    
    func timeString() -> String {
        return self.formattedDate(withFormat: OnlyTimeFormat)
    }

    func isLaterThenToday() -> Bool {
        let now = Date()
        return self.isToday() || self.isLaterThan(now)
    }
    
    func isMorning() -> Bool {
        return self.hour() < 10
    }
    
    func clearSecond() -> NSDate {
        let newDate = NSDate(year: self.year(), month: self.month(),
                             day: self.day(), hour: self.hour(), minute: self.minute(), second: 0)
        return newDate ?? self
    }
    
    func secAndHourMoveNow(min: Int, hour: Int) -> NSDate? {
        let newDate = NSDate(year: self.year(), month: self.month(),
                             day: self.day(), hour: hour, minute: min, second: 0)
        return newDate
    }
    
    func getDateString() -> String {
        if self.isToday() {
            return Localized("today")
        } else if self.isTomorrow() {
            return Localized("tomorrow")
        } else if self.isYesterday() {
            return Localized("yesterday")
        } else {
            return self.formattedDate(with: .medium)
        }
    }
    
    func dayCountsInMonth() -> Int? {
        let c = NSCalendar.current
        let days =
            c.range(of: .day, in: .month, for: self as Date)
        return days?.count
    }
}
