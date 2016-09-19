//
//  TaskRowType.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/17.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import WatchKit
import WatchConnectivity

class TaskRowType: NSObject {
    
    var delegate: WatchTaskRowDelegate? = nil
    var taskUUID: String?
    
    @IBOutlet var checkButton: WKInterfaceButton!
    @IBOutlet var taskLabel: WKInterfaceLabel!
    
    @IBAction func setTaskFinish() {
        guard let uuid = self.taskUUID else { return }
        self.delegate?.setTaskFinish(uuid: uuid)
    }
    
}
