//
//  EmptyView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

class EmptyView: UIView {
    @IBOutlet weak var hintLabel: UILabel!
    
    class func loadNib(target: AnyObject) -> EmptyView? {
        return NSBundle.mainBundle().loadNibNamed("EmptyView", owner: target, options: nil).first as? EmptyView
    }
    
    override func awakeFromNib() {
        self.hintLabel.text = Localized("emptyHint")
        self.hintLabel.textColor = Colors().mainTextColor
        super.awakeFromNib()
    }
    
    func layout(superview: View) {
        self.snp_makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.center.equalTo(superview)
        }
    }
    
}
