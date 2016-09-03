//
//  s.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import YYText

let kAttributedStringLineSpace: CGFloat = 4
let kTaskTitleFontSize: CGFloat = 22
let kOpenTapLinkNotification = "open.link.notification"
let kOpenTapAtNotification = "open.at.notification"

let kSpliteTaskIdentity = "$$"

struct TaskManager {
    
    // 生成系统任务的字符串
    func createTaskText(type: Int, name: String, info: String?) -> String {
        if let info = info {
            return "\(type)$$\(name)$$\(info)"
        } else {
            return "\(type)$$\(name)"
        }
    }
    
    func parseTaskText(text: String) -> SystemActionContent? {
        let results = text.componentsSeparatedByString(kSpliteTaskIdentity)
        if results.count == 3 {
            guard let type = Int(results[0]) else { return nil }
            let showString = results[1] ?? ""
            let infoString = results[2] ?? ""
            
            guard let actionType = SystemActionType(rawValue: type) else { return nil }
            
            return SystemActionContent(type: actionType, name: showString, info: infoString)
        } else {
            return nil
        }
    }
    
//    private func createNormalText(text: String, colors: Colors)
//        -> NSMutableAttributedString {
//            let attachment = NSMutableAttributedString(string: text)
//            attachment.yy_font = UIFont.systemFontOfSize(kTaskTitleFontSize)
//            attachment.yy_color = colors.mainTextColor
//            return attachment
//    }
    
}

