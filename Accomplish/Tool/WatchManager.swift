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
        return WCSession.isSupported()
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith activationState = \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        dispatch_async_main {
            // 如果没有最新数据
            let userdefault = AppUserDefault()
            if userdefault.readBool(kWatchDateHasNewKey) == false {
                replyHandler([kAppSentKey: kNoData])
            }
            
            guard let messageValue = message[kWatchSentKey] as? String else {
                replyHandler([kAppSentKey: kNoData])
                return
            }
            
            switch messageValue {
            case kWatchQueryTodayTaskKey:
                guard let group = GroupUserDefault() else {
                    replyHandler([kAppSentKey: kNoData])
                    return
                }
                let tasks = group.allTaskArray()
                userdefault.write(kWatchDateHasNewKey, value: false)
                replyHandler([kAppSentKey: tasks])
                
            default:
                replyHandler([kAppSentKey: kNoData])
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
