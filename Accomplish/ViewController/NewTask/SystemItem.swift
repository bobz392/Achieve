//
//  SystemItem.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

class CallAtion: SystemItemPresent {
    
    func present() -> String {
        return Localized(ActionBuilder.identity)
    }
    
    func ActionClass() -> AnyClass {
        return CallAtion.self
    }
}


class MailAction: SystemItemPresent {
    
    func present() -> String {
        return Localized(ActionBuilder.identity)
    }
    
    func ActionClass() -> AnyClass {
        return CallAtion.self
    }
}

protocol SystemItemPresent {
    func present() -> String
    func ActionClass() -> AnyClass
}


class ActionBuilder {
    static let identity = "callAction"
    
    func getAction(identity: String) -> SystemItemPresent {
        
        switch identity {
        case ActionBuilder.identity:
            return CallAtion()
            
        default:
            return CallAtion()
        }
    }
}