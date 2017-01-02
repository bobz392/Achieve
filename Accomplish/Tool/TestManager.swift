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
    
    func addAppStoreData() {
        let date = NSDate()
        guard let count = date.dayCountsInMonth() else { return }
        let month = date.month()
        let year = date.year()
        
        var checkins = [CheckIn]()
        for index in 0..<count {
            let checkIn = CheckIn()
            let checkInDate = NSDate(year: year, month: month, day: index + 1)
            checkIn.checkInDate = checkInDate
            checkIn.formatedDate = checkInDate?.createdFormatedDateString() ?? ""
            checkIn.createdCount = Int(arc4random_uniform(100))
            checkIn.completedCount = Int(arc4random_uniform(UInt32(checkIn.createdCount)))
            checkIn.asynced = true
            
            checkins.append(checkIn)
        }
        RealmManager.shared.writeObjects(checkins)
        
        let postTask = Task()
        //Read Harry Potter读三国演义
        postTask.createDefaultTask("读三国演义")
        postTask.postponeTimes = 6
        postTask.createdDate = date.subtractingDays(8) as NSDate
        postTask.finishedDate = date.subtractingDays(4) as NSDate
        RealmManager.shared.writeObject(postTask)
    }
}
