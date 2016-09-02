//
//  LocalNotificationManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct LocalNotificationManager {
    let notifyKey = "com.zhou.achieve.task"
    let repeaterKey = "com.zhou.achieve.repeater"
    
    func notifyWithUUID(taskUUID: String) -> UILocalNotification? {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        guard let notifys = notifications else { return nil }
        for notify in notifys {
            guard let userInfo = notify.userInfo else { continue }
            guard let name = userInfo[notifyKey] as? String else { continue }
            if name == taskUUID {
                return notify
            }
        }
        
        return nil
    }
    
    func cancelNotify(taskUUID: String) {
        guard let notify = notifyWithUUID(taskUUID) else { return }
        UIApplication.sharedApplication().cancelLocalNotification(notify)
        debugPrint("clear task uuid = \(taskUUID) success")
    }
    
    func updateNotify(task: Task, repeatInterval: NSCalendarUnit) {
        guard let notify = LocalNotificationManager().notifyWithUUID(task.uuid) else {
            createNotify(task)
            return
        }
        
        UIApplication.sharedApplication().cancelLocalNotification(notify)
        createNotify(task)
    }
    
    func createNotify(task: Task) {
        guard let notifyDate = task.notifyDate else { return }
        let notify = UILocalNotification()
        
        notify.fireDate = notifyDate
        notify.soundName = UILocalNotificationDefaultSoundName
        notify.alertBody = task.getNormalDisplayTitle()
        
        let repeater = RepeaterManager(taskUUID: task.uuid).repeaterWithTaskUUID()
        if let repeater = repeater,
            let type = RepeaterTimeType(rawValue: repeater.repeatType) {
            notify.repeatInterval = type.getCalendarUnit()
//            if type.getCalendarUnit() == .WeekOfYear {
//                
//                notify.fireDate = notifyDate.dateBySubtractingWeeks(1)
//            }
        } else {
            notify.repeatInterval = NSCalendarUnit(rawValue: 0)
        }
        
        notify.applicationIconBadgeNumber =
            UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        let info = [notifyKey: task.uuid]
        notify.userInfo = info
        
        UIApplication.sharedApplication().scheduleLocalNotification(notify)
    }
}

struct RepeaterManager {
    private let repeater: Repeater?
    
    private init() { self.repeater = nil }
    
    init(taskUUID: String) {
        self.repeater = RealmManager.shareManager.queryRepeaterWithTask(taskUUID)
    }
    
    func repeaterWithTaskUUID() -> Repeater? {
        return repeater
    }
    
    func changeRepeaterType() {
        
    }
    
    func clearRepeater() {
        guard let repeater = self.repeater else { return }
        RealmManager.shareManager.deleteObject(repeater)
    }
}

