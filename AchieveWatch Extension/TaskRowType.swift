//
//  TaskRowType.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/17.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import WatchKit

class TaskRowType: NSObject {
    
    var taskUUID: String?
    
    @IBOutlet var checkButton: WKInterfaceButton!
    @IBOutlet var taskLabel: WKInterfaceLabel!

    @IBAction func setTaskFinish() {
        
    }

}
