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
    
    typealias iCloudEnableBlock = (Bool) -> Void
    
    let container = CKContainer(identifier: "iCloud.com.zhou.bob.achieve")
    
    func fetchTestData() {
        let publicDB = container.privateCloudDatabase
        
        let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            debugPrint(records ?? "icloud no test data")
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
    
    func iCloudEnable(block: @escaping iCloudEnableBlock) {
        CKContainer.default().accountStatus { (accountStatus, error) in
            dispatch_async_main {
                block(accountStatus == .available)
            }
        }
    }
    
    func uploadTasks(date: NSDate) {
        let privateDB = container.privateCloudDatabase
        
        let format = date.createdFormatedDateString()
        let predicate = NSPredicate(format: "formatedDate = '\(format)'")
        let query = CKQuery(recordType: "CheckIn", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { [weak self] (checkIns, error) in
            guard let weakSelf = self else { return }
            Logger.log("checkIns in \(date) == \(checkIns)")
            if (checkIns?.count ?? 0) <= 0 {
                dispatch_async_main {
                    weakSelf.uploadToICloud(date: date, format: format, privateDB: privateDB)
                }
                
            }
        }
    }
    
    private func uploadToICloud(date: NSDate, format: String, privateDB: CKDatabase) {
        var subtaskRecords = [CKRecord]()
        
        let todayCheckIn: CheckIn
        if let checkIn = RealmManager.shared.queryCheckIn(format) {
            if checkIn.asynced == true {
                return
            }
            
            todayCheckIn = checkIn
            let recordId = CKRecordID(recordName: checkIn.formatedDate)
            let checkInRecord = CKRecord(recordType: "CheckIn", recordID: recordId)
            
            checkInRecord["formatedDate"] = NSString(string: checkIn.formatedDate)
            checkInRecord["completedCount"] = NSNumber(integerLiteral: checkIn.completedCount)
            checkInRecord["createdCount"] = NSNumber(integerLiteral: checkIn.createdCount)
            checkInRecord["checkInDate"] = checkIn.checkInDate
            subtaskRecords.append(checkInRecord)
        } else {
            return
        }
        
        let tasks = RealmManager.shared.queryTaskList(date)
        let taskRecords = tasks.map { (task) -> CKRecord in
            let recordId = CKRecordID(recordName: task.uuid)
            let record = CKRecord(recordType: "Task", recordID: recordId)
            record["createdDate"] = task.createdDate
            record["estimateDate"] = task.estimateDate
            record["finishedDate"] = task.finishedDate
            record["notifyDate"] = task.notifyDate
            record["subTaskCount"] = NSNumber(integerLiteral: task.subTaskCount)
            record["createdFormattedDate"] = NSString(string: task.createdFormattedDate)
            record["uuid"] = NSString(string: task.uuid)
            record["postponeTimes"] = NSNumber(integerLiteral: task.postponeTimes)
            record["priority"] = NSNumber(integerLiteral: task.priority)
            record["status"] = NSNumber(integerLiteral: task.status)
            record["taskNote"] = NSString(string: task.taskNote)
            record["taskToDo"] = NSString(string: task.taskToDo)
            record["taskType"] = NSNumber(integerLiteral: task.taskType)
            
            if task.subTaskCount > 0 {
                let subtasks = RealmManager.shared.querySubtask(task.uuid)
                let subRecords = subtasks.map({ (subtask) -> CKRecord in
                    let recordId = CKRecordID(recordName: subtask.uuid)
                    let record = CKRecord(recordType: "SubTask", recordID: recordId)
                    record["rootUUID"] = NSString(string: subtask.rootUUID)
                    record["taskToDo"] = NSString(string: subtask.taskToDo)
                    record["uuid"] = NSString(string: subtask.uuid)
                    record["createdDate"] = subtask.createdDate
                    record["finishedDate"] = subtask.finishedDate
                    return record
                })
                subtaskRecords.append(contentsOf: subRecords)
            }
            
            return record
        }
        
        subtaskRecords.append(contentsOf: taskRecords)
        for record in subtaskRecords {
            privateDB.save(record, completionHandler: { (record, error) in
                Logger.log("save = \(record), error = \(error)")
            })
        }
        
        RealmManager.shared.updateObject {
            todayCheckIn.asynced = true
        }
    }
    
    func asyncFromCloudIfNeeded() {
        let appUD = AppUserDefault()
        if (appUD.readBool(kUserSyncCloudDataKey) != true) {
            let privateDB = container.privateCloudDatabase
            
            let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
            var tasks = [Task]()
            privateDB.perform(query, inZoneWith: nil) { [unowned self] (records, error) in
                if let rs = records {
                    if rs.count > 0 {
                        HUD.shared.showProgress(Localized("asyncing"))
                    }
                    for r in rs {
                        let task = Task()
                        task.createdDate = r["createdDate"] as? NSDate
                        task.estimateDate = r["estimateDate"] as? NSDate
                        task.finishedDate = r["finishedDate"] as? NSDate
                        task.notifyDate = r["notifyDate"] as? NSDate
                        task.subTaskCount = (r["subTaskCount"] as? Int) ?? 0
                        task.createdFormattedDate = (r["createdFormattedDate"] as? String) ?? ""
                        task.uuid = (r["uuid"] as? String) ?? ""
                        task.postponeTimes = (r["postponeTimes"] as? Int) ?? 0
                        task.priority = (r["priority"] as? Int) ?? 0
                        task.status = (r["status"] as? Int) ?? 0
                        
                        task.taskNote = (r["taskNote"] as? String) ?? ""
                        task.taskToDo = (r["taskToDo"] as? String) ?? ""
                        task.taskType = (r["taskType"] as? Int) ?? 0
                        
                        tasks.append(task)
                    }
                    
                    dispatch_async_main {
                        RealmManager.shared.writeObjects(tasks)
                    }
                    self.asyncSubtask(db: privateDB)
                }
            }
            
            appUD.write(kUserSyncCloudDataKey, value: true)
        }
    }
    
    fileprivate func asyncSubtask(db: CKDatabase) {
        let query = CKQuery(recordType: "SubTask", predicate: NSPredicate(value: true))
        var subtasks = [Subtask]()
        
        db.perform(query, inZoneWith: nil) { [unowned self] (records, error) in
            if let rs = records {
                for r in rs {
                    let subtask = Subtask()
                    if let rootUUID = r["rootUUID"] as? String,
                        let uuid = r["uuid"] as? String {
                        subtask.rootUUID = rootUUID
                        subtask.uuid = uuid
                    }
                    subtask.taskToDo = (r["taskToDo"] as? String) ?? ""
                    subtask.createdDate = r["createdDate"] as? NSDate
                    subtask.finishedDate = r["finishedDate"] as? NSDate
                    subtasks.append(subtask)
                }
               
                dispatch_async_main {
                    RealmManager.shared.writeObjects(subtasks)
                }
            }
            
            self.asyncCheckIn(db: db)
        }
    }
    
    fileprivate func asyncCheckIn(db: CKDatabase) {
        let query = CKQuery(recordType: "CheckIn", predicate: NSPredicate(value: true))
        var checkIns = [CheckIn]()
        
        db.perform(query, inZoneWith: nil) { (records, error) in
            if let rs = records {
                Logger.log("async from icloud checkin = \(records)")
                for r in rs {
                    let checkIn = CheckIn()
                    if let formatedDate = r["formatedDate"] as? String {
                        checkIn.formatedDate = formatedDate
                    }
                    
                    checkIn.completedCount = (r["completedCount"] as? Int) ?? 0
                    checkIn.createdCount = (r["createdCount"] as? Int) ?? 0
                    checkIn.checkInDate = r["checkInDate"] as? NSDate
                    checkIn.asynced = true
                    
                    checkIns.append(checkIn)
                }
                
                dispatch_async_main {
                    RealmManager.shared.writeObjects(checkIns)
                    HUD.shared.dismiss()
                }
            } else {
                HUD.shared.dismiss()
            }
        }
    }
}
