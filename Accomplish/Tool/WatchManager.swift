//
//  WatchManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/18.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import WatchConnectivity

@available(iOS 9.0, *)
class WatchManager: NSObject, WCSessionDelegate {
    
    var session : WCSession?
    
    static let shareManager = WatchManager()
    
    override fileprivate init() {
        super.init()
        
        self.activateSession()
    }
    
    fileprivate func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            
            self.session = session
        } else {
            debugPrint("Watch does not support WCSession")
        }
    }
    
    func supported() -> Bool {
        return WCSession.isSupported() &&
            (self.session?.isPaired ?? false) &&
            (self.session?.isWatchAppInstalled ?? false)
    }
    
    func tellWatchQueryNewTask() {
        AppUserDefault().write(kWatchDateHasNewKey, value: true)
        
        if supported() {
            guard let session = self.session else { return }
            if session.isReachable == true {
                session.sendMessage([kAppTellWatchQueryKey : ""], replyHandler: nil, errorHandler: { (error) in
                    debugPrint("error = \(error)")
                })
            }
        }
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith activationState = \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        dispatch_async_main {
            
            // 如果是请求新数据
            if let _ = message[kWatchQueryTodayTaskKey] as? String  {
//                // 如果没有新数据则直接返回， watch 会直接使用 cache data
//                let userdefault = AppUserDefault()
//                if userdefault.readBool(kWatchDateHasNewKey) == false {
//                    replyHandler([kAppSentTaskKey: kNoData])
//                    return
//                }
                
                // 如果有新数据，则发送新数据后标记为没有新数据
                guard let group = GroupUserDefault() else {
                    replyHandler([kAppSentTaskKey: kNoData])
                    return
                }
                let tasks = group.allTaskArray()
//                userdefault.write(kWatchDateHasNewKey, value: false)
                replyHandler([kAppSentTaskKey: tasks])
                
                // 如果是设置任务完成的key
            } else if let uuid = message[kWatchSetTaskFinishKey] as? String {
                guard let task = RealmManager.shareManager.queryTask(uuid) else { return }
                RealmManager.shareManager.updateTaskStatus(task, status: kTaskFinish)
                replyHandler([kAppSetTaskFinishOkKey: uuid])
                
            } else {
                replyHandler([kAppSentTaskKey: kNoData])
            }
            
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint("didReceiveMessage = \(message)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("app sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("app sessionDidDeactivate")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        self.activateSession()
    }
}
