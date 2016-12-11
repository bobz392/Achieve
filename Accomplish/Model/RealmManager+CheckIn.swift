//
//  RealmManager+CheckIn.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

// - TODO 以后为多个年的 check in 优化
extension RealmManager {
    func queryCheckIn(first: Bool = true) -> CheckIn? {
        return realm.objects(CheckIn.self)
            .sorted(byProperty: "checkInDate", ascending: first)
            .first
    }
    
    func queryCheckIn(_ formatedDate: String) -> CheckIn? {
        return realm.objects(CheckIn.self)
            .filter("formatedDate = '\(formatedDate)'")
            .first
    }
    
    func saveCheckIn(_ checkIn: CheckIn) {
        if let old = queryCheckIn(checkIn.formatedDate) {
            deleteObject(old)
        }
        
        writeObject(checkIn)
    }
    
    func allCheckIn() -> Results<CheckIn> {
        return realm.objects(CheckIn.self)
    }
    
    func monthlyCheckIn() -> Results<CheckIn> {
        let month = NSDate().formattedDate(withFormat: queryDateFormat)!
        let checkIns = realm.objects(CheckIn.self)
            .filter("formatedDate BEGINSWITH '\(month)'")
            .sorted(byProperty: "checkInDate", ascending: true)
        return checkIns
    }
    
    func waitForUploadCheckIns() -> Results<CheckIn> {
        let today = NSDate().createdFormatedDateString()
        let checkIns = realm.objects(CheckIn.self)
            .filter("asynced == false AND formatedDate != '\(today)'")
        return checkIns
    }
}
