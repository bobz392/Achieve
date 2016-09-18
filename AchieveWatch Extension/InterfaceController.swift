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
            
            session.sendMessage([WatchSentKey: WatchQueryTodayTaskKey], replyHandler: { (reply) in
                
                DispatchQueue.main.async {
                    debugPrint("reply = \(reply)")
                    guard let allTasks = reply[AppSentKey] as? [[String]] else { return }
                    self.watchTable.setNumberOfRows(allTasks.count, withRowType: "taskRowType")
                    for i in 0..<allTasks.count {
                        guard let row: TaskRowType =
                            self.watchTable.rowController(at: i) as? TaskRowType else { break }
                        row.taskLabel.setText(" \(allTasks[i][GroupTaskTitleIndex])")
                    }

                }
                
                }, errorHandler: { (error) in
                    
                    DispatchQueue.main.async {
                        debugPrint("error = \(error)")
                    }
            })
        }
    
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
    
    fileprivate func sessionInitialize() {
    
    }
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith error = \(error)")
        debugPrint("activationState = \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        debugPrint("didReceiveMessageData messageData = \(messageData)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        debugPrint("watch message = \(message)")
    }
    
}
