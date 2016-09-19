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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
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

    fileprivate func queryTaskFromApp(session: WCSession) {
        session.sendMessage([kWatchSentKey: kWatchQueryTodayTaskKey], replyHandler: { (reply) in
            DispatchQueue.main.async { [unowned self] in
                debugPrint("reply = \(reply)")
                guard let allTasks = reply[kAppSentKey] as? [[String]] else { return }
                self.configTableView(allTasks: allTasks)
            }
            }, errorHandler: { (error) in
                DispatchQueue.main.async {
                    debugPrint("error = \(error)")
                }
        })
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
            row.taskLabel.setText(" \(allTasks[i][GroupTaskTitleIndex])")
            row.taskUUID = allTasks[i][GroupTaskUUIDIndex]
        }
        self.titleLabel.setText(GroupTask.showTaskCountTitle(taskCount: allTasks.count))
        
        UserDefaults.standard.set(allTasks, forKey: kWatchTaskCachesKey)
        UserDefaults.standard.synchronize()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        debugPrint(rowIndex)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
            guard let messageValue = message[kAppSentKey] as? String else { return }
            
            switch messageValue {
            case kAppTellWatchQueryKey:
                self.queryTaskFromApp(session: session)
                
            default:
                break
            }
        }   
    }
}
