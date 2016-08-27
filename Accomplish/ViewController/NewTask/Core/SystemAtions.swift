//
//  SystemItem.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct SystemAction {
    let type: SystemActionType
    let iconString: String
}

struct ActionBuilder {
    
    typealias ActionBlock = (actionString: String) -> Void
    
    let allActions = [
        SystemAction(type: .PhoneCall, iconString: "fa-phone"),
        SystemAction(type: .MessageTo, iconString: "fa-phone"),
        SystemAction(type: .FaceTime, iconString: "fa-video-camera"),
        SystemAction(type: .MailTo, iconString: "fa-envelope-o"),
    ]
    
    
    func actionBlockWithType(type: SystemActionType) -> ActionBlock? {
        switch type {
        case .PhoneCall:
            return { (string) -> Void in
                guard let url = NSURL(string: "tel:\(string)") else {
                    return
                }
                
                UIApplication.sharedApplication().openURL(url)
            }
            
            
        default:
            return nil
        }
    }
    
    
}

enum SystemActionType: Int {
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
    
    func actionPresent() -> ActionPresent {
        switch self {
        case .PhoneCall, .MessageTo, .FaceTime:
            return .AddressBook
            
        default:
            return .AddressBook
        }
    }
}

enum ActionPresent {
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