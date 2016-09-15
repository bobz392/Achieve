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
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.custom)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
    }
    
    func show(_ status: String = "") {
        SVProgressHUD.show(withStatus: status)
    }
    
    func showOnce(_ status: String = "") {
        SVProgressHUD.showSuccess(withStatus: status)
    }
    
    func error(_ status: String) {
        SVProgressHUD.showError(withStatus: status)
    }
    
    func dismiss() {
        SVProgressHUD.dismiss()
    }
    
}
