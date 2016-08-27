//
//  SystemActionBuilder.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

/**
 ** action 的展现结构
 ** 是什么type 以及 对应的 image name
 **/
struct SystemAction {
    let type: SystemActionType
    let actionImage: String
}

struct SystemActionBuilder {
    let allActions = [
        SystemAction(type: .PhoneCall, actionImage: "app_phone"),
        SystemAction(type: .MessageTo, actionImage: "app_imessage"),
        SystemAction(type: .FaceTime, actionImage: "app_facetime"),
        SystemAction(type: .MailTo, actionImage: "app_mail"),
        ]
 
}