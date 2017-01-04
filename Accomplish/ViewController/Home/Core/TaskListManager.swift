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
    
    fileprivate static var status: TaskUpdateStatus = .none
    
    weak var datasource: RealmNotificationDataSource? = nil
    
    fileprivate let rowHeight = TaskTableViewCell.rowHeight
    
    var preceedTasks: Results<Task>
    var completedTasks: Results<Task>
    
    fileprivate var preceedToken: RealmSwift.NotificationToken?
    fileprivate var completedToken: RealmSwift.NotificationToken?
    
    fileprivate let wormhole: MMWormhole
    fileprivate var realmUpdating = false
    
    fileprivate weak var completedHeaderView: TaskTableHeaderView? = nil
    
    init() {
        var tagUUID: String? = nil
        if let uuid = AppUserDefault().readString(kUserDefaultCurrentTagUUIDKey) {
            tagUUID = uuid
        }
        self.preceedTasks = RealmManager.shared.queryTodayTaskList(taskStatus: .preceed, tagUUID: tagUUID)
        self.completedTasks = RealmManager.shared.queryTodayTaskList(taskStatus: .completed, tagUUID: tagUUID)
        self.wormhole = MMWormhole(applicationGroupIdentifier: GroupIdentifier,
                                   optionalDirectory: nil)
        self.generatRealmToken()
    }
    
    static func updateCurrentStatus(newStatues: TaskUpdateStatus) {
        status = newStatues
    }
    
    static func currentStatus() -> TaskUpdateStatus {
        return TaskListManager.status
    }
    
    private func realmTokenUpdating() {
        if !self.realmUpdating && TaskListManager.currentStatus() != .resort {
            self.datasource?.updating(begin: true)
            self.realmUpdating = true
            dispatch_delay(0.2, closure: { [unowned self] in
                self.datasource?.updating(begin: false)
                self.realmUpdating = false
            })
        }
    }
    
    /**
     生成 realm 的自动通知的 token
     */
    func generatRealmToken() {
        let ws = self
        self.preceedToken = preceedTasks.addNotificationBlock({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                ws.datasource?.initial(status: .preceed)
                ws.handleUpdateTodayGroup()
                
            case .update(_, let deletions, let insertions, let modifications):
                ws.realmTokenUpdating()
                ws.datasource?.update(deletions: deletions, insertions: insertions,
                                      modifications: modifications, status: .preceed)
                ws.handleUpdateTodayGroup()
                
            case .error(let error):
                Logger.log("preceedToken realmNoticationToken error = \(error)")
                break
            }
        })
        
        self.completedToken = completedTasks.addNotificationBlock({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                ws.datasource?.initial(status: .completed)
                
            case .update(_, let deletions, let insertions, let modifications):
                ws.realmTokenUpdating()
                ws.datasource?.update(deletions: deletions, insertions: insertions,
                                      modifications: modifications, status: .completed)
                ws.completedHeaderView?.updateTitle(newTitle: ws.updateCompletedHeaderViewTitle())
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
            
            manager.updateTaskStatus(task, newStatus: .completed, updateDate: date)
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
        self.completedTasks = shareManager.queryTodayTaskList(taskStatus: .completed, tagUUID: tagUUID)
        self.preceedTasks = shareManager.queryTodayTaskList(taskStatus: .preceed, tagUUID: tagUUID)
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
            return self.preceedTasks.count > 0 ?
                TaskTableHeaderView.preceedHeight : EmptyDataView.height
        } else {
            return TaskTableHeaderView.completedHeight
        }
    }
    
    func viewForHeaderIn(section: Int, target: AnyObject) -> UIView? {
        if section == 0 {
            if self.preceedTasks.count > 0 {
                let headerTitle = Localized("progess")
                let headerView = TaskTableHeaderView.loadNib(target, title: headerTitle)
                return headerView
            } else {
                let title: String
                let hiddenLinkButton: Bool
                if let tagUUID = AppUserDefault().readString(kUserDefaultCurrentTagUUIDKey),
                    let tag = RealmManager.shared.queryTag(usingName: false, query: tagUUID) {
                    title = String(format: Localized("emptyTagTask"), tag.name)
                    hiddenLinkButton = false
                } else {
                    title = Localized("emptyTask")
                    hiddenLinkButton = true
                }
                
                let headerView = EmptyDataView.loadNib(target)
                if let header = headerView {
                    header.setImage(imageName: Icons.listEmpty.iconString())
                        .setTitle(title: title)
                    header.linkButton.isHidden = hiddenLinkButton
                    header.linkButton.setTitle(Localized("backToAllTask"), for: .normal)
                    let linkAction = #selector(self.headerSwitchTagAction)
                    header.linkButton.addTarget(self, action: linkAction, for: .touchUpInside)
                }
                
                return headerView
            }
        } else {
            let headerView = TaskTableHeaderView.loadNib(target, title: self.updateCompletedHeaderViewTitle())
            self.completedHeaderView = headerView
            return headerView
        }
    }
    
    fileprivate func updateCompletedHeaderViewTitle() -> String {
        return Localized("finished") + "(\(self.completedTasks.count))"
    }
    
    @objc fileprivate func headerSwitchTagAction() {
        AppUserDefault().remove(kUserDefaultCurrentTagUUIDKey)
        self.datasource?.switchTagTo(tag: nil)
    }
}

//MARK: - 自动通知的协议
protocol RealmNotificationDataSource: NSObjectProtocol, SwitchTagDelegate {
    func initial(status: TaskStatus)
    func update(deletions: [Int], insertions: [Int], modifications: [Int], status: TaskStatus)
    func updating(begin: Bool)
}

enum TaskUpdateStatus {
    case move
    case resort
    case none
}
