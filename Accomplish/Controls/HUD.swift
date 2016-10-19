//
//  HUD.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/30.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

final class HUD {
    
    static let shared = HUD()
    
    func config() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        SVProgressHUD.setDefaultAnimationType(.flat)
    }
    
    func showProgress(_ status: String = "") {
        SVProgressHUD.show(withStatus: status)
    }
    
    func showSwitch(_ status: String, left: Bool) {
        guard let icon = left ?
            FAKFontAwesome.arrowLeftIcon(withSize: 18) :
            FAKFontAwesome.arrowRightIcon(withSize: 18) else { return }
        
        icon.addAttribute(NSForegroundColorAttributeName, value: Colors().mainGreenColor)
        let iconImage = icon.image(with: CGSize(width: 28, height: 28))
        
        SVProgressHUD.show(iconImage, status: status)
    }
    
    func showOnce(_ status: String = "") {
        SVProgressHUD.showSuccess(withStatus: status)
    }
    
    func error(_ status: String) {
        SVProgressHUD.showError(withStatus: status)
    }
    
    func dismiss() {
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
    }
    
}
