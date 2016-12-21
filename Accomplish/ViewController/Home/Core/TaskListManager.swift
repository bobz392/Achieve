//
//  TaskListManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/20.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class TaskListManager {
    
    weak var datasource: RealmNotificationDataSource? = nil
    
    fileprivate let rowHeight = TaskTableViewCell.rowHeight
    
    var preceedTasks = RealmManager.shared.queryTodayTaskList(finished: false)
    var completedTasks = RealmManager.shared.queryTodayTaskList(finished: true)
    
    fileprivate var preceedToken: RealmSwift.NotificationToken?
    fileprivate var completedToken: RealmSwift.NotificationToken?
    
    fileprivate let wormhole: MMWormhole
    
    init() {
        self.wormhole = MMWormhole(applicationGroupIdentifier: GroupIdentifier,
                                   optionalDirectory: nil)
        self.generatRealmToken()
    }
    
    /**
        生成 realm 的自动通知的 token
     */
    func generatRealmToken() {
        let ws = self
        self.preceedToken = preceedTasks.addNotificationBlock({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                ws.datasource?.initial(type: .preceed)
                ws.handleUpdateTodayGroup()
                
            case .update(_, let deletions, let insertions, let modifications):
                ws.datasource?.update(deletions: deletions, insertions: insertions,
                                      modifications: modifications, type: .preceed)
                ws.handleUpdateTodayGroup()
                
            case .error(let error):
                Logger.log("preceedToken realmNoticationToken error = \(error)")
                break
            }
        })
        
        self.completedToken = completedTasks.addNotificationBlock({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                ws.datasource?.initial(type: .completed)
                
            case .update(_, let deletions, let insertions, let modifications):
                ws.datasource?.update(deletions: deletions, insertions: insertions,
                                          modifications: modifications, type: .completed)
                ws.handleUpdateTodayGroup()
                
            case .error(let error):
                Logger.log("completedToken realmNoticationToken error = \(error)")
                break
            }
        })
    }
    
    deinit {
        self.preceedToken?.stop()
        self.completedToken?.stop()
    }
    
    /**
     处理 today extension 中完成的任务
     */
    func handelTodayExtensionFinish() {
        guard let group = GroupUserDefault() else { return }
        let completedTasksArray = group.getAllFinishTask()
        
        let manager = RealmManager.shared
        
        let _ = completedTasksArray.map({ (taskInfoArr) -> Void in
            let uuid = taskInfoArr[GroupTaskUUIDIndex]
            let dateString = taskInfoArr[GroupTaskFinishDateIndex]
            let date = dateString.dateFromString(UUIDFormat)
            guard let task = self.preceedTasks.filter({ (t) -> Bool in
                t.uuid == uuid
            }).first else { return }
            
            manager.updateTaskStatus(task, status: kTaskFinish, updateDate: date)
        })
        
        group.clearTaskFinish()
    }
    
    /**
     处理更新后的任务到 Today，通知 Today 即可
     */
    func handleUpdateTodayGroup() {
        guard let group = GroupUserDefault() else { return }
        group.writeTasks(self.preceedTasks)
        self.wormhole.passMessageObject(nil, identifier: WormholeNewTaskIdentifier)
    }
    
    /**
     查询今天的 task 列表，如果有 tag 则传递 tag 的 uuid
     */
    func queryTodayTask(tagUUID: String? = nil) {
        let shareManager = RealmManager.shared
        self.completedTasks = shareManager.queryTodayTaskList(finished: true, tagUUID: tagUUID)
        self.preceedTasks = shareManager.queryTodayTaskList(finished: false, tagUUID: tagUUID)
        self.generatRealmToken()
    }
}

// MARK: - task table view 代理相关的函数
extension TaskListManager {
    func taskForIndexPath(indexPath: IndexPath) -> Task {
        let row = indexPath.row
        return indexPath.section == 0 ?
            self.preceedTasks[row] : self.completedTasks[row]
    }
    
    func numberOfRows(section: Int, showFinishTask: Bool) -> Int {
        if section == 0 {
            return self.preceedTasks.count
        } else {
            return showFinishTask ? self.completedTasks.count : 0
        }
    }
    
    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return rowHeight
        } else {
            return rowHeight
        }
    }
    
    func heightForHeaderInSection(section: Int) -> CGFloat {
        if section == 0 {
            return 20
        } else {
            return self.completedTasks.count > 0 ? 40 : 0
        }
    }
    
    func viewForHeaderIn(section: Int, target: AnyObject) -> TaskTableHeaderView? {
        if section == 0 {
            let headerTitle = Localized("progess")
            let headerView = TaskTableHeaderView.loadNib(target, title: headerTitle)
            return headerView
        } else {
            let headerTitle = Localized("finished")
            let headerView = TaskTableHeaderView.loadNib(target, title: headerTitle)
            return headerView
        }
    }
}

//MARK: - 自动通知的协议
protocol RealmNotificationDataSource: NSObjectProtocol {
    func initial(type: TaskCellType)
    func update(deletions: [Int], insertions: [Int], modifications: [Int], type: TaskCellType)
}

enum TaskCellType {
    case preceed
    case completed
    
}
