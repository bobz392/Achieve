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
    // @task 开始于 @time, 预计在 @time 完成
    // @task started at @time, estimate finish at @time
    
//    "reportFinish"="%@-%@ %@";
//    "reportUnfinish"="%@ %@";
//    "reportOvertime"="，超出预期 %@。";
//    "reportEarlier"="，提前 %@ 完成。";
//    "reportEstimate"="，预计于 %@ 完成。";
    func generateReport(taskList: Results<Task>) -> String {
        let string = taskList.reduce("", { (content, task) -> String in
            
            var newTaskContent = ""
            let taskTodo = task.realTaskToDo()
            
            if let startDate =
                task.createdDate?.formattedDate(withFormat: ReportDateFormat) {
                
                if let finishDate = task.finishedDate?.formattedDate(withFormat: ReportDateFormat) {
                    newTaskContent += String(format: Localized("reportFinish"), startDate, finishDate, taskTodo)
                    
                    if let estimateDate = task.estimateDate,
                        let finishDate = task.finishedDate as? Date {
                        let hours: Int
                        let minis: Int
                        let isEarlier: Bool
                        
                        if estimateDate.isEarlierThan(finishDate) {
                            hours = Int(estimateDate.hoursEarlierThan(finishDate))
                            minis = Int(estimateDate.minutesEarlierThan(finishDate)) % 60
                            isEarlier = false
                            
                        } else {
                            hours = Int(estimateDate.hoursLaterThan(finishDate))
                            minis = Int(estimateDate.minutesLaterThan(finishDate)) % 60
                            isEarlier = true
                        }
                        
                        var time = ""
                        
                        if hours > 0 {
                            time += "\(hours) \(Localized( hours > 1 ? "hours" : "hour" )) "
                        }
                        
                        if minis > 0 {
                            time += "\(minis) \(Localized("mins"))"
                        }
                        
                        newTaskContent +=
                            String(format: Localized( isEarlier ? "reportEarlier" : "reportOvertime" ), time)
                    }
                } else {
                    newTaskContent += String(format: Localized("reportUnfinish"), startDate, taskTodo)
                    if let estimateDate = task.estimateDate?.formattedDate(withFormat: ReportDateFormat) {
                        newTaskContent += String(format: Localized("reportEstimate"), estimateDate)
                    }
                }
            }
            
            return content + newTaskContent + "\n"
        })
        
        return string
    }
}
