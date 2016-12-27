//
//  LaunchView.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class LaunchView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    weak var realRootVC: UIViewController? = nil
    
    class func loadNib(_ target: AnyObject, realRootVC: UIViewController) -> LaunchView? {
        guard let view =
            Bundle.main.loadNibNamed("LaunchView", owner: target, options: nil)?
                .first as? LaunchView else {
                    return nil
        }
        view.backgroundColor = Colors.mainBackgroundColor
        view.titleLabel.textColor = Colors.mainTextColor
        
        if let window = target as? UIWindow {
            view.frame = window.bounds
            window.addSubview(view)
            window.windowLevel = UIWindowLevelStatusBar + 1
        }
        
        Logger.log(UIScreen.main.bounds)
        
        return view
    }
    
    func showAndAutoFade() {
        let weakSelf = self
        realRootVC?.view.alpha = 0
        UIView.animate(withDuration: 1, delay: 0.5, options: [.layoutSubviews], animations: {
            weakSelf.alpha = 0
            weakSelf.realRootVC?.view.alpha = 1
        }) { (finish) in
            
//            weakSelf.removeFromSuperview()
        }
    }
}
