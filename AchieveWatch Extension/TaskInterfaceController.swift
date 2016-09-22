//
//  TaskInterfaceController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/20.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import WatchKit
import Foundation


class TaskInterfaceController: WKInterfaceController {
    @IBOutlet var fullTitleLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        guard let task = context as? [String] else { return }
        
        
        self.fullTitleLabel.setText(task[GroupTaskTitleIndex])
//        if let estimate = task[GroupTaskEstimateIndex].optionalDateFromString(TimeDateFormat) {
//        
//        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.setTitle(Localized("today"))
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
