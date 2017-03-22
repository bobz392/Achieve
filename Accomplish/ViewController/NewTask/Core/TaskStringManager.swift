//
//  s.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let kAttributedStringLineSpace: CGFloat = 4
let kTaskTitleFontSize: CGFloat = 22
let kOpenTapLinkNotification = "open.link.notification"
let kOpenTapAtNotification = "open.at.notification"

let kSpliteTaskIdentity = "$$"

struct TaskManager {
    
    // 生成系统任务的字符串, 3 个的时候是
    // such as name = zhoubo info = 18827420512
    // taskToText = 1$$zhoubo$$18827420512
    // show = call zhoubo
    func createTaskText(_ type: Int, name: String, info: String) -> String {
        return "\(type)$$\(name)$$\(info)"
    }
    
    func parseTaskToDoText(_ text: String) -> SystemActionContent? {
        let results = text.components(separatedBy: kSpliteTaskIdentity)
        if results.count == 3 {
            guard let type = Int(results[0]) else { return nil }
            let showString = results[1]
            let infoString = results[2] 
            
            guard let actionType = SystemActionType(rawValue: type) else { return nil }
            
            return SystemActionContent(type: actionType, name: showString, urlSchemeInfo: infoString)
        } else {
            return nil
        }
    }

}

