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
    @objc dynamic var uuid = ""
    @objc dynamic var taskToDo = ""
    @objc dynamic var rootUUID = ""
    @objc dynamic var createdDate: NSDate?
    @objc dynamic var finishedDate: NSDate?

    func createDefaultSubtask(todo: String, rootTaskUUID: String, createDate: NSDate = NSDate()) {
        self.rootUUID = rootTaskUUID
        self.createdDate = createDate
        self.taskToDo = todo
        self.uuid = createDate.createTaskUUID()
    }
}
