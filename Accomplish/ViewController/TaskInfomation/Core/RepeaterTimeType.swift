//
//  RepeaterTimeType.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

enum RepeaterTimeType: Int {
    case Daily
    case Weekday
    case EveryWeek
    case EveryMonth
    case Annual
    
    func getCalendarUnit() -> NSCalendarUnit {
        switch self {
        case .Daily:
            return .Day
        case .Weekday:
            return .WeekdayOrdinal
        case .EveryWeek:
            return .WeekOfYear
        case .EveryMonth:
            return .Month
        case .Annual:
            return .Year
        }
    }
    
    func repeaterTitle(createDate: NSDate) -> String {
        switch self {
        case .Daily:
            return Localized("everyday")
        case .Weekday:
            return Localized("weekday")
        case .EveryWeek:
            // 周
            return String(format: Localized("everyWeek"), createDate.formattedDateWithFormat("EEE"))
        case .EveryMonth:
            // 多少号 - st
            return String(format: Localized("everyMonth"), createDate.formattedDateWithFormat("d"))
        case .Annual:
            return String(format: Localized("annual"), createDate.formattedDateWithFormat("MMM d"))
        }
    }
}