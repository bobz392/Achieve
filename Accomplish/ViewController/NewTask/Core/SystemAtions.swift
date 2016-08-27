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
    
    func ationNameWithType() -> String {
        switch self {
        case .PhoneCall:
            return Localized("callAction")
        default:
            return ""
        }
    }
    
    func actionPresent() -> ActionFeaturePresent {
        switch self {
        case .PhoneCall, .MessageTo, .FaceTime:
            return .AddressBook
            
        default:
            return .AddressBook
        }
    }
    
    func actionBlockWithType() -> ActionBlock? {
        switch self {
        case .PhoneCall:
            return { (string) -> Void in
                guard let url = NSURL(string: "tel:\(string)") else {
                    return
                }
                let application = UIApplication.sharedApplication()
                guard application.canOpenURL(url) == true else {
                    debugPrint("can not call")
                    return
                }
                
                application.openURL(url)
            }
            
        default:
            return nil
        }
    }
}

/**
 ** action 对应的功能展现
 ** such 从 address book 中取回数据
 **/
enum ActionFeaturePresent {
    case AddressBook
}

//func configWithIcon(iconString: String) {
//    self.actionButton.layer.cornerRadius =  (UIScreen.mainScreen().bounds.width / 5 - 15) * 0.5
//    let colors = Colors()
//    let icon = try? FAKFontAwesome(identifier: iconString, size: 20)
//    icon?.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
//    actionButton.setImage(icon?.imageWithSize(CGSize(width: 20, height: 20)), forState: .Normal)
//}
//
//func configWithString(string: String) {
//    self.actionButton.layer.cornerRadius =  self.actionButton.bounds.width * 0.5
//    actionButton.setTitle(string, forState: .Normal)
//}