//
//  UserDefault.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/25.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let kUserDefaultFullScreenKey = "com.current.screen.size"

let kUserDefaultWeekStartKey = "com.date.start"
// 是否关闭推迟到今天
let kUserDefaultCloseDueTodayKey = "com.due.today"
let kUserDefaultCloseSoundKey = "com.close.finish.sound"
// 当前选中的主题色
let kUserDefaultBackgroundKey = "com.background.color"
let kUserDefaultWatchDateHasNewKey = "com.watch.date.is.new"

let kUserDefaultCurrentTagUUIDKey = "com.current.tag"
// 注册通知并告知用户
let kUserDefaultNeedReisterNoitificationKey = "com.call.notification"
// 需要移动未完成的任务到今天
let kUserDefaultMoveUnfinishTaskKey = "com.check.unfinish.task"
// 需要同步 icloud
let kUserDefaultSynciCloudKey = "com.sync.cloud.data"
// 是否创建内置的工作法
let kUserDefaultBuildInTMKey = "com.build.in.time.method"
// 工作法的中断保存信息，例如进行情况和 time manager 的 uuid
let kUserDefaultTMDetailsKey = "com.tm.manager"
let kUserDefaultTMUUIDKey = "com.tm.uuid"
let kUserDefaultTMTaskUUID = "com.tm.task.uuid"

struct AppUserDefault {
    let def = UserDefaults.standard
    
    func write(_ key: String, value: Any) {
//        Logger.log("write to user default with key = \(key) and value = \(value)")
        def.set(value, forKey: key)
        def.synchronize()
    }
    
    func readBool(_ key: String) -> Bool {
        return def.bool(forKey: key)
    }
    
    func readString(_ key: String) -> String? {
        return def.string(forKey: key)
    }
    
    func readInt(_ key: String) -> Int {
        return def.integer(forKey: key)
    }
    
    func readArray(_ key: String)-> Array<Any>? {
        return def.array(forKey: key)
    }
    
    func remove(_ key: String) {
        def.removeObject(forKey: key)
        def.synchronize()
    }
}

