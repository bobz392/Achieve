//
//  UrlSchemeDispatcher.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct UrlSchemeDispatcher {
 
    func handleUrl(url: NSURL) -> Bool {
        debugPrint(url)
        
        debugPrint("url.baseURL = \(url.baseURL)")
        debugPrint("absoluteString = \(url.absoluteString)")
        debugPrint("pathComponents = \(url.pathComponents)")
        debugPrint("relativeString = \(url.relativeString)")
        debugPrint("lastPathComponent = \(url.lastPathComponent)")
        debugPrint("query = \(url.query)")
        
        if url.absoluteString.containsString(kTaskDetailPath) {
            guard let uuid = url.lastPathComponent else { return false }
            self.checkTaskDetail(uuid)
            return true
        }
        
        return false
    }
    
    private func rootViewController() -> UINavigationController? {
        return UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController
    }
    
    func checkTaskDetail(uuid: String) {
        guard let rootNavigationController = rootViewController() else { return }
        rootNavigationController.popToRootViewControllerAnimated(false)
        guard let homeVC = rootNavigationController.viewControllers.first as? HomeViewController else { return }
        homeVC.enterTaskFromToday(uuid)
    }
}