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
let monthFormat: String = "MMM"
let onlyTimeFormat = "hh:mm"
let onlyAmFormat = "a"

// TASK
extension NSDate {
    func createTaskUUID() -> String {
        return self.formattedDateWithFormat(uuidFormat + uuidGenerator())
    }
    
    func createdFormatedDateString() -> String {
        debugPrint("created formated date string = \(self.formattedDateWithFormat(createdDateFormat, locale: NSLocale.init(localeIdentifier: "en_US")))")
        return self.formattedDateWithFormat(createdDateFormat, locale: NSLocale.init(localeIdentifier: "en_US"))
    }
    
    func toLocalDate() -> NSDate {
        let zone = NSTimeZone.systemTimeZone()
        let iter = NSTimeInterval(zone.secondsFromGMTForDate(self))
        return self.dateByAddingTimeInterval(iter)
    }
    
    func timeDateString() -> String {
        return self.formattedDateWithFormat(timeDateFormat)
    }
    
    func timeString() -> String {
        return self.formattedDateWithFormat(onlyTimeFormat)
    }
    func am() -> String {
        return self.formattedDateWithFormat(onlyAmFormat)
    }
    
    func isLaterThenToday() -> Bool {
        let now = NSDate()
        return self.isToday() || self.isLaterThan(now)
    }
    
    func isMorning() -> Bool {
        return self.hour() < 10
    }
}
