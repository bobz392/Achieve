//
//  RealmManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/25.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    typealias RealmBlock = () -> Void
    internal let realm = try! Realm()
    
    static let shareManager = RealmManager()
    
    static func configMainRealm() {
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
    }
    
    func writeObject(_ object: Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    func deleteObject(_ object: Object) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func updateObject(_ updateBlock: RealmBlock) {
        try! realm.write(block: {
            updateBlock()
        })
    }
    
    func writeObjects(_ objects: [Object]) {
        realm.beginWrite()
        realm.add(objects)
        try! realm.commitWrite()
    }
    
    func queryAll(clz: AnyClass) {
        let result = realm.allObjects(ofType: clz as! Object.Type)
        SystemInfo.log("result = \(result)")
    }
    
    func queryTodayTaskList(finished: Bool, tagUUID: String?) -> Results<Task> {
        let queryDate = NSDate().createdFormatedDateString()
        
        let queryWithTag: String
        if let uuid = tagUUID {
            queryWithTag = "AND tagUUID = '\(uuid)'"
        } else {
            queryWithTag = ""
        }
        
        let queryFormatted = "createdFormattedDate = '\(queryDate)'"
        let queryStatues = "status \(finished ? "!=" : "==") \(kTaskRunning)"
        let tasks = realm
            .allObjects(ofType: Task.self)
            .filter(using: "\(queryFormatted) AND \(queryStatues) \(queryWithTag)")
            .sorted(onProperty: "createdDate")
        
        return tasks
    }
    
    func queryTaskCount(date: NSDate) -> (complete: Int, created: Int) {
        let task = realm.allObjects(ofType: Task.self)
            .filter(using: "createdFormattedDate = '\(date.createdFormatedDateString())'")
        
        let created = task.count
        let complete = task.filter(using: "status == \(kTaskFinish)").count
        
        return (complete, created)
    }
    
    func queryTask(_ taskUUID: String) -> Task? {
        return realm.allObjects(ofType: Task.self).filter(using: "uuid = '\(taskUUID)'").first
    }
    
    func queryTaskList(_ date: NSDate) -> Results<Task> {
        return realm.allObjects(ofType: Task.self)
            .filter(using: "createdFormattedDate = '\(date.createdFormatedDateString())'")
    }
    
    func querySubtask(_ rootUUID: String, sorted: Bool = true) -> Results<Subtask> {
        let subtasks = realm.allObjects(ofType: Subtask.self)
            .filter(using: "rootUUID = '\(rootUUID)'")
        
        if sorted {
            return subtasks.sorted(onProperty: "createdDate")
        } else {
            return subtasks
        }
    }
    
    /**
     删除子任务， 删除通知， 删除重复
     **/
    func deleteTask(_ task: Task) {
        self.deleteTaskReminder(task)
        self.deleteRepeater(task)
        
        
        let subtasks = self.querySubtask(task.uuid, sorted: false)
        
        realm.beginWrite()
        if subtasks.count > 0 {
            realm.delete(subtasks)
        }
        realm.delete(task)
        try! realm.commitWrite()
    }
    
    func deleteTaskReminder(_ task: Task) {
        guard let _ = task.notifyDate else { return }
        
        self.updateObject {
            task.notifyDate = nil
        }
        LocalNotificationManager().cancelNotify(task.uuid)
    }
    
    func moveYesterdayTaskToToday() {
        let today = NSDate()
        let todayDateString = today.createdFormatedDateString()
        let yesterday = (today.subtractingDays(1) as NSDate).createdFormatedDateString()
        let movedtasks = realm.allObjects(ofType: Task.self)
            .filter(using: "createdFormattedDate = '\(yesterday)' AND status = \(kTaskRunning)")
            .filter { (task) -> Bool in
                return self.queryRepeaterWithTask(task.uuid) == nil
        }
        
        self.updateObject {
            for task in movedtasks {
                task.createdDate = task.createdDate?.addingDays(1) as NSDate?
                task.createdFormattedDate = todayDateString
                task.notifyDate = nil
                
                if #available(iOS 9.0, *) {
                    SpotlightManager().addTaskToIndex(task: task)
                }
            }
        }
    }
    
    func updateTaskStatus(_ task: Task, status: Int, updateDate: NSDate? = nil) {
        try! realm.write(block: {
            task.status = status
            if status == kTaskFinish {
                let now = NSDate()
                let subtasks = querySubtask(task.uuid)
                for subtask in subtasks {
                    subtask.finishedDate = updateDate ?? now
                }
                task.finishedDate = updateDate ?? now
                
                LocalNotificationManager().skipFireToday(skip: true, task: task)
            } else if status == kTaskRunning {
                task.finishedDate = nil
                LocalNotificationManager().skipFireToday(skip: false, task: task)
            }
        })
    }
}

// MARK: - CheckIn model
// 以后为多个年的 check in 优化
extension RealmManager {
    func queryFirstCheckIn() -> CheckIn? {
        return realm.allObjects(ofType: CheckIn.self)
            .sorted(onProperty: "checkInDate", ascending: true)
            .first
    }
    
    func queryCheckIn(_ formatedDate: String) -> CheckIn? {
        return realm.allObjects(ofType: CheckIn.self)
            .filter(using: "formatedDate = '\(formatedDate)'")
            .first
    }
    
    func saveCheckIn(_ checkIn: CheckIn) {
        if let old = queryCheckIn(checkIn.formatedDate) {
            deleteObject(old)
        }
        
        writeObject(checkIn)
    }
    
    func allCheckIn() -> Results<CheckIn> {
        return realm.allObjects(ofType: CheckIn.self)
    }
}

// MARK: -  Tag model
extension RealmManager {
    func saveTag(_ tag: Tag) -> Bool {
        if let _ = queryTag(usingName: true, query: tag.name) {
            return false
        }
        
        writeObject(tag)
        return true
    }
    
    func queryTag(usingName name: Bool, query: String) -> Tag? {
        let q = name == true ? "name" : "tagUUID"
        return realm
            .allObjects(ofType: Tag.self)
            .filter(using: "\(q) = '\(query)'")
            .first
    }
    
    
    func allTags() -> Results<Tag> {
        return realm.allObjects(ofType: Tag.self)
            .sorted(onProperty: "createdAt")
    }
}
