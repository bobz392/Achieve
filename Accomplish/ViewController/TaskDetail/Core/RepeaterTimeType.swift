//
//  RepeaterTimeType.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

enum RepeaterTimeType: Int {
    case daily
    case weekday
    case everyWeek
    case everyMonth
    case annual
    
    func getCalendarUnit() -> NSCalendar.Unit {
        switch self {
        case .daily:
            return .day
        case .weekday:
            return .weekOfYear
        case .everyWeek:
            return .weekOfYear
        case .everyMonth:
            return .month
        case .annual:
            return .year
        }
    }
    
    func getCalendarComponent() -> Set<Calendar.Component> {
        switch self {
        case .daily:
            return [.hour, .minute]
        case .weekday:
            return [.weekday, .hour, .minute]
        case .everyWeek:
            return [.weekday, .hour, .minute]
        case .everyMonth:
            return [.day, .hour, .minute]
        case .annual:
            return [.month, .day, .hour, .minute]
        }
    }
    
    func repeaterTitle(createDate: NSDate) -> String {
        switch self {
        case .daily:
            return Localized("everyday")
        case .weekday:
            return Localized("weekday")
        case .everyWeek:
            // 周
            return String(format: Localized("everyWeek"), createDate.formattedDate(withFormat: "EEE"))
        case .everyMonth:
            // 多少号 - st
            return String(format: Localized("everyMonth"), createDate.formattedDate(withFormat: "d"))
        case .annual:
            return String(format: Localized("annual"), createDate.formattedDate(withFormat: "MMM d"))
        }
    }
}
