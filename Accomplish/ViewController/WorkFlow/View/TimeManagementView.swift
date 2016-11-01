//
//  TimeManagementView.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/1.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagementView: UIView {

    class func loadNib(_ target: AnyObject) -> TimeManagementView? {
        return Bundle.main.loadNibNamed("TimeManagementView", owner: target, options: nil)?
            .first as? TimeManagementView
    }

    func moveIn(view: UIView) {
        view.addSubview(self)
        
        self.snp.makeConstraints({ (make) in
            make.top.equalTo(view)
            make.trailing.equalTo(view)
            make.leading.equalTo(view)
            make.height.equalTo(view)
        })
        self.alpha = 0
        UIView.animate(withDuration: kSmallAnimationDuration) { [unowned self] in
            self.alpha = 1
        }
        
        // Test Remember delete
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.moveOut))
        self.addGestureRecognizer(tap)
    }
    
    func moveOut() {
        UIView.animate(withDuration: kSmallAnimationDuration, animations: {
            self.alpha = 0
            }) { (finish) in
                self.removeFromSuperview()
        }
    }

}
