//
//  UrlSchemeDispatcher.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct ControllerUtil {
    
    internal func drawerController() -> MMDrawerController? {
        guard let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
            let drawer = navi.viewControllers.first as? MMDrawerController else { return nil }
        let _ = navi.popToRootViewController(animated: false)
        drawer.closeDrawer(animated: false, completion: nil)
        return drawer
    }
    
    internal func menuHomeViewControllers() -> (MenuViewController?, HomeViewController?) {
        guard let drawer = self.drawerController() else { return (nil, nil) }
        Logger.log((drawer.leftDrawerViewController as? MenuViewController, drawer.centerViewController as? HomeViewController))
        return (drawer.leftDrawerViewController as? MenuViewController, drawer.centerViewController as? HomeViewController)
    }
    
}

struct UrlSchemeDispatcher {
 
    private let controllerUtil = ControllerUtil()
    
    func handleURL(url: URL) -> Bool {
        if url.absoluteString.contains(UrlType.taskDetail.pathString()) {
            let uuid = url.lastPathComponent
            self.checkTaskDetail(uuid)
            return true
        } else if url.absoluteString.contains(UrlType.home.pathString()) {
            self.enterDestop()
            return true
        }
        
        return false
    }
    
    func enterDestop() {
        let (menuVC, _) = self.controllerUtil.menuHomeViewControllers()
        menuVC?.selectedNewMenu(index: 0)
    }
    
    func checkTaskDetail(_ uuid: String) {
        let (menuVC, homeVC) = self.controllerUtil.menuHomeViewControllers()
        menuVC?.selectedNewMenu(index: 0)
        homeVC?.enterTaskFromToday(uuid)
    }

}
