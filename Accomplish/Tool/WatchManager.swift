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
        
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            
            self.session = session
        } else {
            debugPrint("Watch does not support WCSession")
        }
    }
    
    class func supported() -> Bool {
        return WCSession.isSupported()
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        dispatch_async_main {
            guard let messageValue = message[WatchSentKey] as? String else {
                replyHandler([AppSentKey: NoData])
                return
            }
            
            switch messageValue {
            case WatchQueryTodayTaskKey:
                guard let group = GroupUserDefault() else {
                    replyHandler([AppSentKey: NoData])
                    return
                }
                let tasks = group.allTaskArray()
                replyHandler([AppSentKey: tasks])
                
            default:
                replyHandler([AppSentKey: NoData])
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint(message)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("app sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("app sessionDidDeactivate")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
            
            self.session = session
        } else {
            debugPrint("Watch does not support WCSession")
        }
        
    }
}
