//
//  Subtask.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class Subtask: Object {
    dynamic var uuid = ""
    dynamic var taskToDo = ""
    dynamic var rootUUID = ""
    dynamic var createdDate: NSDate?
    dynamic var finishedDate: NSDate?

    func createDefaultSubtask(todo: String, rootTaskUUID: String, createDate: NSDate = NSDate()) {
        self.rootUUID = rootTaskUUID
        self.createdDate = createDate
        self.taskToDo = todo
        self.uuid = createDate.createTaskUUID()
    }
}
