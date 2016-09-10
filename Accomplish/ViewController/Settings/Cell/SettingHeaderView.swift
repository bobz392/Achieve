//
//  SettingHeaderView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/10.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SettingHeaderView: UIView {

    @IBOutlet weak var headerTitleLabel: UILabel!
 
    class func loadNib(target: AnyObject) -> SettingHeaderView? {
        return NSBundle.mainBundle().loadNibNamed("SettingHeaderView", owner: target, options: nil).first as? SettingHeaderView
    }
    
    override func awakeFromNib() {
        self.headerTitleLabel.textColor = Colors().secondaryTextColor
        super.awakeFromNib()
    }
}
