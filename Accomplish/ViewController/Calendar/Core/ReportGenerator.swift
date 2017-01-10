//
//  ReportGenerator.swift
//  Accomplish
//
//  Created by zhoubo on 2016/10/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

struct ReportGenerator {

    func generateReport(taskList: Results<Task>) -> String {
        let string = taskList.reduce("", { (content, task) -> String in
            
            let taskTodo = task.realTaskToDo()
            var dateString = ""
            if let startDate =
                task.createdDate?.formattedDate(withFormat: ReportDateFormat) {
                if let finishDate =
                    task.finishedDate?.formattedDate(withFormat: ReportDateFormat) {
                    dateString = "\(startDate) - \(finishDate) "
                } else {
                    dateString = "\(startDate) "
                }
            }

            return content + dateString + taskTodo + "\n"
        })
        
        return string
    }
}
