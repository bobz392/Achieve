//
//  HUD.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/30.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import SVProgressHUD

final class HUD {
    
    static let sharedHUD = HUD()
    
    func config() {
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Light)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Custom)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.Native)
    }
    
    func show(status: String = "") {
        SVProgressHUD.showWithStatus(status)
    }
    
    func error(status: String) {
        SVProgressHUD.showErrorWithStatus(status)
    }
    
    func dismiss() {
        SVProgressHUD.dismiss()
    }
    
}