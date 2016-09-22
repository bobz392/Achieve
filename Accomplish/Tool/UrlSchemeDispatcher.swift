//
//  UrlSchemeDispatcher.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct UrlSchemeDispatcher {
 
    func handleUrl(_ url: URL) -> Bool {
//        SystemInfo.log(url)
//        SystemInfo.log("url.baseURL = \(url.baseURL)")
//        SystemInfo.log("absoluteString = \(url.absoluteString)")
//        SystemInfo.log("pathComponents = \(url.pathComponents)")
//        SystemInfo.log("relativeString = \(url.relativeString)")
//        SystemInfo.log("lastPathComponent = \(url.lastPathComponent)")
//        SystemInfo.log("query = \(url.query)")
        
        if url.absoluteString.contains(kTaskDetailPath) {
            let uuid = url.lastPathComponent
            self.checkTaskDetail(uuid)
            return true
        } else if url.absoluteString.contains(kTaskAllPath) {
            self.enterDestop()
            return true
        }
        
        return false
    }
    
    fileprivate func rootViewController() -> UINavigationController? {
        return UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    }
    
    func checkTaskDetail(_ uuid: String) {
        guard let rootNavigationController = rootViewController() else { return }
        rootNavigationController.popToRootViewController(animated: false)
        guard let homeVC = rootNavigationController.viewControllers.first as? HomeViewController else { return }
        homeVC.enterTaskFromToday(uuid)
    }
    
    func enterDestop() {
        guard let rootNavigationController = rootViewController() else { return }
        rootNavigationController.popToRootViewController(animated: false)
    }
}
