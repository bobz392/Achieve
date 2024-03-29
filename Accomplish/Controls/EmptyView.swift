//
//  EmptyView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    @IBOutlet weak var hintLabel: UILabel!
    
    class func loadNib(_ target: AnyObject) -> EmptyView? {
        return Bundle.main.loadNibNamed("EmptyView", owner: target, options: nil)?.first as? EmptyView
    }
    
    override func awakeFromNib() {
        self.hintLabel.text = "Nothing here :("
        self.hintLabel.textColor = Colors.mainTextColor
        super.awakeFromNib()
    }
    
    func layout(superview: UIView) {
        self.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.center.equalTo(superview)
        }
    }
    
}
