//
//  HintView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class HintView: UIView {

    class func loadNib(target: AnyObject) -> HintView? {
        return NSBundle.mainBundle().loadNibNamed("HintView", owner: target, options: nil).first as? HintView
    }

}
