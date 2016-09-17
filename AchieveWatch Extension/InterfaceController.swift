//
//  InterfaceController.swift
//  AchieveWatch Extension
//
//  Created by zhoubo on 16/9/17.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var watchTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        guard let alltasks = GroupUserDefault()?.allTasks() else { return }
        self.watchTable.setNumberOfRows(alltasks.count, withRowType: "taskRowType")
        for i in 0..<alltasks.count {
            guard let row: TaskRowType =
                self.watchTable.rowController(at: i) as? TaskRowType else { break }
            row.checkButton.setTitle(alltasks[i].taskTitle)
        }
        
        debugPrint()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
