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
    
    static let shared = RealmManager()
    
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
    
    func updateObject(_ updateBlock: @escaping RealmBlock) {
        try! realm.write({
            updateBlock()
        })
    }
    
    func writeObjects(_ objects: [Object]) {
        realm.beginWrite()
        realm.add(objects)
        try! realm.commitWrite()
    }
    
    func queryAll(clz: AnyClass) {
        let result = realm.objects(clz as! Object.Type)
        Logger.log("result = \(result)")
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
        
//        let needSortProperty = AppUserDefault().readBool(kSortByPriority)
//        var sortPropertys = [SortDescriptor(property: "createdDate", ascending: false)]
//        if needSortProperty {
//            let needSort = SortDescriptor(property: "priority", ascending: false)
//            sortPropertys.append(needSort)
//        }
        
        let tasks = realm
            .objects(Task.self)
            .filter("\(queryFormatted) AND \(queryStatues) \(queryWithTag)")
//            .sorted(by: sortPropertys)
            .sorted(byProperty: "createdDate", ascending: false)
//            .sorted(byProperty: "priority", ascending: false)
        
        return tasks
    }
    
    func queryTaskCount(date: NSDate) -> (completed: Int, created: Int) {
        let task = realm.objects(Task.self)
            .filter("createdFormattedDate == '\(date.createdFormatedDateString())'")
        
        let created = task.count
        let complete = task.filter("status == \(kTaskFinish)").count
        Logger.log("created = \(created), complete = \(complete)")
        return (complete, created)
    }
    
    func queryTask(_ taskUUID: String) -> Task? {
        return realm.objects(Task.self).filter("uuid = '\(taskUUID)'").first
    }
    
    /**
     查询本月需要 report 的 task
     */
    func queryMonthlyTask() -> Results<Task> {
        let month = NSDate().formattedDate(withFormat: queryDateFormat)!
        return realm.objects(Task.self)
            .filter("(repeaterUUID != nil) OR (postponeTimes > 0) AND (createdFormattedDate BEGINSWITH '\(month)')")
    }
    
    func queryTaskList(_ date: NSDate) -> Results<Task> {
        return realm.objects(Task.self)
            .filter("createdFormattedDate = '\(date.createdFormatedDateString())'")
    }
    
    func querySubtask(_ rootUUID: String, sorted: Bool = true) -> Results<Subtask> {
        let subtasks = realm.objects(Subtask.self)
            .filter("rootUUID = '\(rootUUID)'")
        
        if sorted {
            return subtasks.sorted(byProperty: "createdDate")
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
        LocalNotificationManager.shared.cancel(task)
    }
    
    func hasUnfinishTaskMoveToday() -> [Task] {
        let yesterday = (NSDate().subtractingDays(1) as NSDate).createdFormatedDateString()
        let yesterdayTask = realm.objects(Task.self)
            .filter("createdFormattedDate = '\(yesterday)' AND status = \(kTaskRunning)")
        let taskArr = Array(yesterdayTask)
        let movedtasks = taskArr.filter { (task) -> Bool in
            return task.repeaterUUID == nil
        }
        
        return movedtasks
    }
    
    func moveYesterdayTaskToToday(movedtasks: [Task]) {
        let todayDateString = NSDate().createdFormatedDateString()
        self.updateObject {
            for task in movedtasks {
                task.createdDate = task.createdDate?.addingDays(1) as NSDate?
                task.createdFormattedDate = todayDateString
                task.postponeTimes += 1
                task.notifyDate = nil
                
                if #available(iOS 9.0, *) {
                    SpotlightManager().addTaskToIndex(task: task)
                }
            }
        }
    }
    
    func updateTaskStatus(_ task: Task, status: Int, updateDate: NSDate? = nil) {
        try! realm.write({
            task.status = status
            if status == kTaskFinish {
                let now = NSDate()
                let subtasks = querySubtask(task.uuid)
                for subtask in subtasks {
                    subtask.finishedDate = updateDate ?? now
                }
                task.finishedDate = updateDate ?? now
                
                LocalNotificationManager.shared.skipFireToday(skip: true, task: task)
            } else if status == kTaskRunning {
                task.finishedDate = nil
                LocalNotificationManager.shared.skipFireToday(skip: false, task: task)
            }
        })
    }
    
    //MARK: tasks search
    //note: this realm must create new one in other thread
    func searchTasks(queryString: String) -> Results<Task> {
        let tasks = realm.objects(Task.self)
            .filter("taskToDo CONTAINS '\(queryString)'")
            .sorted(byProperty: "createdDate", ascending: false)
        
        return tasks
    }
}

// MARK: - CheckIn model
// 以后为多个年的 check in 优化
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
            .objects(Tag.self)
            .filter("\(q) = '\(query)'")
            .first
    }
    
    func allTags() -> Results<Tag> {
        return realm.objects(Tag.self)
            .sorted(byProperty: "createdAt")
    }
}
