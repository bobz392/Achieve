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
        debugPrint(result)
    }
    
    func queryTodayTaskList(finished: Bool) -> Results<Task> {
        let queryDate = NSDate().createdFormatedDateString()
        
        let tasks = realm
            .allObjects(ofType: Task.self)
            .filter(using: "createdFormattedDate = '\(queryDate)' AND status \(finished ? "!=" : "==") \(kTaskRunning)")
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
        return realm.allObjects(ofType: Task.self).filter(using: "createdFormattedDate = '\(date.createdFormatedDateString())'")
    }
    
    func querySubtask(_ rootUUID: String) -> Results<Subtask> {
        return realm.allObjects(ofType: Subtask.self)
            .filter(using: "rootUUID = '\(rootUUID)'")
            .sorted(onProperty: "createdDate")
    }
    
    func deleteTask(_ task: Task) {
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
            } else if status == kTaskRunning {
                task.finishedDate = nil
            } else {
                
            }
        })
    }
}

// 以后为多个年的 check in 优化
extension RealmManager {
    func queryFirstCheckIn() -> CheckIn? {
        return realm.allObjects(ofType: CheckIn.self).sorted(onProperty: "checkInDate", ascending: true).first
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

extension RealmManager {
    func saveTag(_ tag: Tag) {
        if let old = queryTag(usingName: true, query: tag.name) {
            deleteObject(old)
        }
        
        writeObject(tag)
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
    }
}
