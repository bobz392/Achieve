//
//  LocalNotificationManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct LocalNotificationManager {
    let notifyKey = "com.zhou.achieve"
    
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
    
    func createNotify(task: Task) {
        guard let notifyDate = task.notifyDate else { return }
        let notify = UILocalNotification()
        notify.fireDate = notifyDate
        notify.soundName = UILocalNotificationDefaultSoundName
        notify.alertBody = task.getNormalDisplayTitle()
        notify.repeatInterval = NSCalendarUnit(rawValue: 0)
        notify.applicationIconBadgeNumber = 1
        let info = [notifyKey: task.uuid]
        notify.userInfo = info
        UIApplication.sharedApplication().scheduleLocalNotification(notify)
    }
}