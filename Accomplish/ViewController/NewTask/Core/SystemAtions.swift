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
        case .MessageTo:
            return Localized("sendMessage")
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
}

//extension AddressBookViewController: MFMessageComposeViewControllerDelegate {
//
//    private func invite(person person: AddressBook.Person) {
//
//        guard MFMessageComposeViewController.canSendText() else {
//            SVProgressHUD.showWithStatus("无法发送短信")
//            return
//        }
//
//        guard let phoneNumberString = person.phoneNumbers.first?.phoneNumberString else {
//            SVProgressHUD.showWithStatus("无法添加该联系人")
//            return
//        }
//
//        let messageComposer = MFMessageComposeViewController()
//        messageComposer.recipients = [phoneNumberString]
//        //    messageComposer.body = shareInfo.makeBodyText(username: delegate.name ?? "", html: false)
//        messageComposer.messageComposeDelegate = self
//
//        navigationController?.presentViewController(messageComposer, animated: true, completion: nil)
//    }
//
//    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
//
//        if result == MessageComposeResultFailed {
//            SVProgressHUD.showWithStatus("邀请失败")
//        }
//
//        if result == MessageComposeResultCancelled {
//            SVProgressHUD.showWithStatus("邀请已取消")
//        }
//
//        navigationController?.dismissViewControllerAnimated(true, completion: nil)
//    }
//
//}
