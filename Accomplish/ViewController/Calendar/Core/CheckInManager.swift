//
//  CheckInManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/7.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct CheckInManager {
    fileprivate let allCheckIn = RealmManager.shared.allCheckIn()
    fileprivate var cacheTaskData
        = Dictionary<Date, (completed:Int, created: Int)>()
    
    func checkInWithDate(date: NSDate) -> CheckIn? {
        return allCheckIn
            .filter("formatedDate == '\(date.createdFormatedDateString())'")
            .first
    }
    
    mutating func taskCount(date: Date) -> (completed: Int, created: Int) {
        let d = date as NSDate
        guard let counts = self.cacheTaskData[date] else {
            let newCounts =
                RealmManager.shared.queryTaskCount(date: d)
            if !d.isToday() {
                self.cacheTaskData[date] = newCounts
            }
            return newCounts
        }
        
        return counts
    }
    
    func getMonthCheckIn(format: String) -> Array<CheckIn> {
        let checkIns = RealmManager.shared.monthlyCheckIn(format: format)
        
        return Array<CheckIn>(checkIns)
    }
    
}
