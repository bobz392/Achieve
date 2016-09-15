//
//  SystemActionType.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

enum SystemActionType: Int {
    
    typealias ActionBlock = (_ actionString: String) -> Void
    
    case phoneCall
    case messageTo
    case faceTime
    case mailTo
    case subtask
    case none
    
    // action 本地化的 key， 用于显示文本
    func ationNameWithType() -> String {
        switch self {
        case .phoneCall:
            return Localized("callAction")
        case .messageTo:
            return Localized("sendMessageAction")
        case .faceTime:
            return Localized("faceTimeAction")
        case .mailTo:
            return Localized("mailAction")
        case .subtask:
            return Localized("addSubtask")
            
        case .none:
            return ""
        }
    }
    
    func hintNameWithType() -> (String, String)? {
        switch self {
        case .subtask:
            return ("subtaskTitle", "subtaskInfo")
            
        default:
            return nil
        }
    }
    
    // 具体的功能类型，决定跳转页面
    func actionPresent() -> ActionFeaturePresent {
        switch self {
        case .phoneCall, .messageTo, .faceTime:
            // 跳转通讯录的电话
            return .addressBook
            
        case .mailTo:
            //跳转通讯录的email
            return .addressBookEmail
            
        case .subtask:
            // 跳转到创建任务清单
            return .createSubtasks
            
        case .none:
            return .none
        }
    }
    
    func actionScheme() -> String? {
        let urlScheme: String
        switch self {
        case .phoneCall:
            urlScheme = "tel:"
            
        case .messageTo:
            urlScheme = "sms:"
            
        case .faceTime:
            urlScheme = "facetime://"
            
        case .mailTo:
            urlScheme = "mailto:"
            
        case .subtask, .none:
            return nil
        }
        
        return urlScheme
    }
    
    // action 的 回调 block
    func actionBlockWithType() -> ActionBlock? {
        guard let scheme = self.actionScheme() else { return nil }
        
        return { (string) -> Void in
            let checkString = string.replacingOccurrences(of: " ", with: "")
            guard let url = URL(string: "\(scheme)\(checkString)") else {
                return
            }
            let application = UIApplication.shared
            guard application.canOpenURL(url) == true else {
                debugPrint("can not call")
                return
            }
            
            application.openURL(url)
        }
    }
}

/**
 ** action 对应的功能展现
 ** such as 从 address book 中取回数据
 **/
enum ActionFeaturePresent {
    case addressBook
    case addressBookEmail
    case createSubtasks
    case none
}
