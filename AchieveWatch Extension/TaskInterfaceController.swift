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
    @IBOutlet var detailTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        guard let task = context as? [String] else { return }
        self.fullTitleLabel.setText(task[GroupTaskTitleIndex])
        
        var infoArray = [[String]]()
        
        let create = task[GroupTaskCreateDateIndex]
        if create.length() > 0 {
            infoArray.append([Localized("createdAt"), create])
        }
        
        let estimate = task[GroupTaskEstimateIndex]
        if estimate.length() > 0 {
            infoArray.append([Localized("estimeateAt"), estimate])
        }
        
        let tag = task[GroupTaskTagIndex]
        if tag.length() > 0 {
            infoArray.append([Localized("tag"), tag])
        }
        
        if let priority = Int(task[GroupTaskPriorityIndex]) {
            infoArray.append([Localized("priority"), Localized("priority\(priority)")])
        }
        
        self.detailTable.setNumberOfRows(infoArray.count, withRowType: "detailRowType")
        
        for i in 0..<infoArray.count {
            guard let row: DetailRowType =
                self.detailTable.rowController(at: i) as? DetailRowType else { break }
            
            row.titleLabel.setText(infoArray[i][0])
            row.detailLabel.setText(infoArray[i][1])
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.setTitle(Localized("Today"))
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
