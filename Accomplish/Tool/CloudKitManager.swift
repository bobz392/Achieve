//
//  CloudKitManager.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager: NSObject {
    
    let container = CKContainer(identifier: "iCloud.com.test.achieve")
    
    
    func fetchTestData() {
        let publicDB = container.privateCloudDatabase
        
        let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            debugPrint(records)
        }

//        publicDB.fetchAllRecordZones { (zones, error) in
//            debugPrint(zones)
//        }
        
//        let record = CKRecord(recordType: "Task")
//        record["uuid"] = NSString(string: "asd")
//        record["priority"] = NSNumber(integerLiteral: 1)
//        record["status"] = NSNumber(integerLiteral: 2)
//        record["taskNote"] = NSString(string: "asd")
//        record["taskToDo"] = NSString(string: "asd")
//        record["taskType"] = NSNumber(integerLiteral: 2)
//        publicDB.save(record) { (record, error) in
//            debugPrint(record)
//        }
    }
}
