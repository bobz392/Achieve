//
//  HUD.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/30.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import SVProgressHUD

final class HUD {
    
    static let shared = HUD()
    
    func config() {
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        SVProgressHUD.setDefaultAnimationType(.flat)
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
