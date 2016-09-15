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
    let hintString: String
}

struct SystemActionBuilder {
    
    let allActions = [
        SystemAction(type: .phoneCall, actionImage: "app_phone", hintString: "addPhoneCall"),
        SystemAction(type: .messageTo, actionImage: "app_imessage", hintString: "addMessage"),
        SystemAction(type: .faceTime, actionImage: "app_facetime", hintString: "addFaceTime"),
        SystemAction(type: .mailTo, actionImage: "app_mail", hintString: "addMail"),
        SystemAction(type: .subtask, actionImage: "app_subtask", hintString: "addSubtask"),
        ]
    
}
