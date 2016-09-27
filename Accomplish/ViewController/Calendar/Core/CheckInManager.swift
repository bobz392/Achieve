//
//  CheckInManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/7.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct CheckInManager {
    fileprivate let allCheckIn = RealmManager.shareManager.allCheckIn()
    fileprivate var cacheTaskData
        = Dictionary<Date, (completed:Int, created: Int)>()
    
    
    func checkInWithDate(date: NSDate) -> CheckIn? {
        return allCheckIn
            .filter(using: "formatedDate == '\(date.createdFormatedDateString())'")
            .first
    }
    
    mutating func taskCount(date: Date) -> (completed: Int, created: Int) {
        guard let counts = self.cacheTaskData[date] else {
            let newCounts =
                RealmManager.shareManager.queryTaskCount(date: date as NSDate)
            self.cacheTaskData[date] = newCounts
            return newCounts 
        }
        
        return counts
    }
    
}
