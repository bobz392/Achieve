//
//  TestManager.swift
//  Accomplish
//
//  Created by zhoubo on 2016/10/12.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct TestManager {
    
    func addTestCheckIn() {
        guard let count = NSDate().dayCountsInMonth() else { return }
        
        for i in 0..<count {
            let checkIn = CheckIn()
            let date = NSDate(year: 2016, month: 10, day: i)!
            checkIn.checkInDate = date
            checkIn.formatedDate = date.createdFormatedDateString()
            
            let create = Int(arc4random() % 100) + 1
            checkIn.createdCount = create
            
            checkIn.completedCount = Int(arc4random() % UInt32(create))
            
            RealmManager.shared.writeObject(checkIn)
        }
    }
    
}
