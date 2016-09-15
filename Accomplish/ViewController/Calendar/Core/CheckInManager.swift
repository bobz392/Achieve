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
    
    func checkInWithDate(date: NSDate) -> CheckIn? {
        return allCheckIn.filter(using: "formatedDate == '\(date.createdFormatedDateString())'").first
    }
    
}
