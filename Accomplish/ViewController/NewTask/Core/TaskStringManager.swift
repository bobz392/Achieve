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

struct TaskStringManager {
    
    func createTaskText(type: Int, name: String, info: String) -> String {
        return "\(type)$$\(name)$$\(info)"
    }
    
    func parseTaskText(text: String) -> NSMutableAttributedString {
        let taskTitleText = NSMutableAttributedString()
        
        let results = text.componentsSeparatedByString(kSpliteTaskIdentity)
        guard results.count == 3 else {
            fatalError("format error in text = \(text)")
        }
        
        let type = Int(results[0]) ?? 0
        let showString = results[1] ?? ""
        let taskActionString = results[2] ?? ""
        
        guard let actionType = SystemActionType(rawValue: type) else {
            return NSMutableAttributedString(string: "")
        }
        
        let colors = Colors()
        
        let actionTitle = actionType.ationNameWithType()
        let actionTitleActtributedString = createNormalText(actionTitle, colors: colors)
        taskTitleText.appendAttributedString(actionTitleActtributedString)
        
        let linkAttachment = NSMutableAttributedString(string: "\(showString)")
        let highlight = YYTextHighlight()
        highlight.tapAction = { (view, text, range, rect) -> Void in
            print("tap link \(taskActionString)")
            //            let notification = NSNotification(name: isAt ? kOpenTapAtNotification : kOpenTapLinkNotification, object: item.actionString)
            //            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
        
        linkAttachment
            .yy_setTextHighlight(highlight, range: NSRange(location: 0, length: linkAttachment.length))
        linkAttachment.yy_font = UIFont.systemFontOfSize(kTaskTitleFontSize)
        linkAttachment.yy_color = colors.linkTextColor
        
        return taskTitleText
    }
    
    private func createNormalText(text: String, colors: Colors)
        -> NSMutableAttributedString {
            let attachment = NSMutableAttributedString(string: text)
            attachment.yy_font = UIFont.systemFontOfSize(kTaskTitleFontSize)
            attachment.yy_color = colors.mainTextColor
            return attachment
    }
    
}

