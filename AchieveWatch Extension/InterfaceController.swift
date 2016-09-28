//
//  InterfaceController.swift
//  AchieveWatch Extension
//
//  Created by zhoubo on 16/9/17.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var watchTable: WKInterfaceTable!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    var alltasks: [[String]]? = nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.setTitle("Achieve")
        
        self.titleLabel.setTextColor(WatchColors().titleColor)
        
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            
            debugPrint("WCSession.default().isReachable = \(WCSession.default().isReachable)")
            
            if (session.isReachable == true) {
                self.queryTaskFromApp(session: session)
            }
        }
    }
    
    override func didDeactivate() {
        ///    // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func handleAction(withIdentifier identifier: String?, for localNotification: UILocalNotification) {
        Logger.log("withIdentifier = \(identifier), localNotification = \(localNotification)")
        guard let uuid = localNotification.userInfo?[kNotifyUserInfoKey] as? String else {
            return
        }
        
        if identifier == kNotifyFinishAction {
            self.setTaskFinish(uuid: uuid)
        } else if identifier == kNotifyReschedulingAction {
            for i in 0..<self.watchTable.numberOfRows {
                guard let row = self.watchTable.rowController(at: i) as? TaskRowType
                    else { continue }
                if row.taskUUID == uuid {
                    guard let task = self.alltasks?[i] else { return }
                    self.pushController(withName: "taskInterfaceController", context: task)
                    break
                }
            }
        }
    }
    
    fileprivate func queryTaskFromApp(session: WCSession) {
        if session.isReachable {
            session.sendMessage([kWatchQueryTodayTaskKey: ""], replyHandler: { (reply) in
                DispatchQueue.main.async { [unowned self] in
                    debugPrint("reply = \(reply)")
                    guard let allTasks = reply[kAppSentTaskKey] as? [[String]] else { return }
                    self.alltasks = allTasks
                    self.configTableView(allTasks: allTasks)
                }
                }, errorHandler: { (error) in
                    DispatchQueue.main.async {
                        debugPrint("error = \(error)")
                    }
            })
        } else {
            debugPrint("session cant reachable")
        }
    }
    
    fileprivate func useCacheData() {
        guard let allTasks = UserDefaults.standard.array(forKey: kWatchTaskCachesKey)
            as? [[String]] else { return }
        
        configTableView(allTasks: allTasks)
    }
    
    fileprivate func configTableView(allTasks: [[String]]) {
        self.watchTable.setNumberOfRows(allTasks.count, withRowType: "taskRowType")
        for i in 0..<allTasks.count {
            guard let row: TaskRowType =
                self.watchTable.rowController(at: i) as? TaskRowType else { break }
            row.taskLabel.setText(allTasks[i][GroupTaskTitleIndex])
            row.taskUUID = allTasks[i][GroupTaskUUIDIndex]
            row.delegate = self
        }
        self.titleLabel.setText(GroupTask.showTaskCountTitle(taskCount: allTasks.count))
        
        UserDefaults.standard.set(allTasks, forKey: kWatchTaskCachesKey)
        UserDefaults.standard.synchronize()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        Logger.log(rowIndex)
        guard let task = self.alltasks?[rowIndex] else { return }
        self.pushController(withName: "taskInterfaceController", context: task)
    }
}

extension InterfaceController: WatchTaskRowDelegate {
    func setTaskFinish(uuid: String) {
        let session = WCSession.default()
        
        if session.isReachable {
            session.sendMessage([kWatchSetTaskFinishKey: uuid], replyHandler: { (reply) in
                DispatchQueue.main.async { [unowned self] in
                    guard let finishTaskUUID = reply[kAppSetTaskFinishOkKey] as? String else { return }
                    for i in 0..<self.watchTable.numberOfRows {
                        guard let row = self.watchTable.rowController(at: i) as? TaskRowType
                            else { continue }
                        if row.taskUUID == finishTaskUUID {
                            var set = IndexSet()
                            set.insert(i)
                            self.watchTable.removeRows(at: set)
                            
                            self.titleLabel.setText(
                                GroupTask.showTaskCountTitle(taskCount: self.watchTable.numberOfRows)
                            )
                            break
                        }
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    debugPrint(error)
                }
            }
        }
    }
}

extension InterfaceController: WCSessionDelegate {
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith error = \(error)")
        debugPrint("activationState = \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        debugPrint("didReceiveMessageData messageData = \(messageData)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        debugPrint("watch message = \(message)")
        
        dispatch_async_main { [unowned self] in
            guard let _ = message[kAppTellWatchQueryKey] as? String else { return }
            
            self.queryTaskFromApp(session: session)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        dispatch_async_main {
            Logger.log("didReceiveUserInfo userInfo = \(userInfo)")
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        dispatch_async_main {
            Logger.log(userInfoTransfer)
            Logger.log(error)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        dispatch_async_main {
            Logger.log("didReceiveApplicationContext \(applicationContext)")
        }
    }
}

protocol WatchTaskRowDelegate {
    func setTaskFinish(uuid: String)
}
