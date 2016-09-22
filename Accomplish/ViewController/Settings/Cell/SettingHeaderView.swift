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
    @IBOutlet weak var separatorView: UIView!
 
    class func loadNib(_ target: AnyObject) -> SettingHeaderView? {
        return Bundle.main.loadNibNamed("SettingHeaderView", owner: target, options: nil)?.first as? SettingHeaderView
    }
    
    override func awakeFromNib() {
        let colors = Colors()
        self.headerTitleLabel.textColor = colors.secondaryTextColor
        self.separatorView.backgroundColor = colors.separatorColor
        self.clearView()
        super.awakeFromNib()
    }
}
