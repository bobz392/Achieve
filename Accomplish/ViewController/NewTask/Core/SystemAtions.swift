//
//  SystemItem.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

/**
 ** action 的内容数据
 **/
struct SystemActionContent {
    let type: SystemActionType
    let name: String
    let info: String
}

enum SystemActionType: Int {
    
    typealias ActionBlock = (actionString: String) -> Void
    
    case PhoneCall
    case MessageTo
    case FaceTime
    case MailTo
    case Subtask
    
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
            return Localized("")
        }
    }
    
    func actionPresent() -> ActionFeaturePresent {
        switch self {
        case .PhoneCall, .MessageTo, .FaceTime:
            return .AddressBook
        
        case .MailTo:
            return .AddressBookEmail
        
        case .Subtask:
            return .KeyValue
        }
    }
    
    func actionBlockWithType() -> ActionBlock? {
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
            
        case .Subtask:
            return nil
        }
        
        return { (string) -> Void in
            let checkString = string.stringByReplacingOccurrencesOfString(" ", withString: "")
            guard let url = NSURL(string: "\(urlScheme)\(checkString)") else {
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

/**
 ** action 对应的功能展现
 ** such 从 address book 中取回数据
 **/
enum ActionFeaturePresent {
    case AddressBook
    case AddressBookEmail
    case KeyValue
}
