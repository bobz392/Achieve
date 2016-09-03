//
//  SystemActionType.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

enum SystemActionType: Int {
    
    typealias ActionBlock = (actionString: String) -> Void
    
    case PhoneCall
    case MessageTo
    case FaceTime
    case MailTo
    case Subtask
    case None
    
    // action 本地化的 key， 用于显示文本
    func ationNameWithType() -> String {
        switch self {
        case .PhoneCall:
            return Localized("callAction")
        case .MessageTo:
            return Localized("sendMessageAction")
        case .FaceTime:
            return Localized("faceTimeAction")
        case .MailTo:
            return Localized("mailAction")
        case .Subtask:
            return Localized("addSubtask")
            
        case .None:
            return ""
        }
    }
    
    func hintNameWithType() -> (String, String)? {
        switch self {
        case .Subtask:
            return ("subtaskTitle", "subtaskInfo")
            
        default:
            return nil
        }
    }
    
    // 具体的功能类型，决定跳转页面
    func actionPresent() -> ActionFeaturePresent {
        switch self {
        case .PhoneCall, .MessageTo, .FaceTime:
            // 跳转通讯录的电话
            return .AddressBook
            
        case .MailTo:
            //跳转通讯录的email
            return .AddressBookEmail
            
        case .Subtask:
            // 跳转到创建任务清单
            return .CreateSubtasks
            
        case .None:
            return .None
        }
    }
    
    func actionScheme() -> String? {
        let urlScheme: String
        switch self {
        case .PhoneCall:
            urlScheme = "tel:"
            
        case .MessageTo:
            urlScheme = "sms:"
            
        case .FaceTime:
            urlScheme = "facetime://"
            
        case .MailTo:
            urlScheme = "mailto:"
            
        case .Subtask, .None:
            return nil
        }
        
        return urlScheme
    }
    
    // action 的 回调 block
    func actionBlockWithType() -> ActionBlock? {
        guard let scheme = self.actionScheme() else { return nil }
        
        return { (string) -> Void in
            let checkString = string.stringByReplacingOccurrencesOfString(" ", withString: "")
            guard let url = NSURL(string: "\(scheme)\(checkString)") else {
                return
            }
            let application = UIApplication.sharedApplication()
            guard application.canOpenURL(url) == true else {
                debugPrint("can not call")
                return
            }
            
            application.openURL(url)
        }
    }
}