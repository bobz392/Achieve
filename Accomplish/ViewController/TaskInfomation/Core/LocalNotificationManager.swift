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
    
    func notifyWithUUID(taskUUID: String) -> [UILocalNotification] {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        guard let notifys = notifications else { return [] }
        return notifys.filter { (n) -> Bool in
            guard let userInfo = n.userInfo else { return false }
            guard let name = userInfo[notifyKey] as? String else { return false }
            return name == taskUUID
        }
    }
    
    func cancelNotify(taskUUID: String) {
        let notify = notifyWithUUID(taskUUID)
        guard notify.count > 0 else { return }
        for n in notify {
            UIApplication.sharedApplication().cancelLocalNotification(n)
        }
        debugPrint("clear local notifycation task uuid = \(taskUUID) success")
    }
    
    func updateNotify(task: Task, repeatInterval: NSCalendarUnit) {
        guard let _ = task.notifyDate else  { return }
        
        let notify = LocalNotificationManager().notifyWithUUID(task.uuid)
        guard notify.count > 0 else {
            createNotify(task)
            return
        }
        
        for n in notify {
            UIApplication.sharedApplication().cancelLocalNotification(n)
        }
        createNotify(task)
    }
    
    func createNotify(task: Task) {
        guard let notifyDate = task.notifyDate else { return }
        let notify = UILocalNotification()
        
        let repeater = RealmManager.shareManager.queryRepeaterWithTask(task.uuid)
        if let repeater = repeater,
            let type = RepeaterTimeType(rawValue: repeater.repeatType) {
            if type == .Weekday {
                self.createWeekday(task)
                return
            } else {
                notify.repeatInterval = type.getCalendarUnit()
            }
        } else {
            notify.repeatInterval = NSCalendarUnit(rawValue: 0)
        }
        
        notify.fireDate = notifyDate
        notify.soundName = UILocalNotificationDefaultSoundName
        notify.alertBody = task.getNormalDisplayTitle()
        notify.applicationIconBadgeNumber =
            UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        notify.timeZone = NSTimeZone.systemTimeZone()
        let info = [notifyKey: task.uuid]
        notify.userInfo = info
        
        UIApplication.sharedApplication().scheduleLocalNotification(notify)
    }
    
    private func createWeekday(task: Task) {
        guard let notifyDate = task.notifyDate else { return }
        
        for i in 0 ..< 7 {
            let fireDate = notifyDate.dateByAddingDays(i)
            if fireDate.isWeekend() {
                continue
            }else {
                let notify = UILocalNotification()
                notify.fireDate = fireDate
                notify.soundName = UILocalNotificationDefaultSoundName
                notify.alertBody = task.getNormalDisplayTitle()
                notify.timeZone = NSTimeZone.systemTimeZone()
                notify.repeatInterval = .WeekOfYear
                notify.applicationIconBadgeNumber =
                    UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                let info = [notifyKey: task.uuid]
                notify.userInfo = info
                
                UIApplication.sharedApplication().scheduleLocalNotification(notify)
            }
        }
    }
}

