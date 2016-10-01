//
//  HomePulldownView.swift
//  Accomplish
//
//  Created by zhoubo on 2016/10/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class HomePulldownView: UIView {

    class func loadNib(_ target: AnyObject) -> HomePulldownView? {
        return Bundle.main.loadNibNamed("HomePulldownView", owner: target, options: nil)?
            .first as? HomePulldownView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func layout(superview: UIView) {
        self.snp.makeConstraints { (make) in
            make.width.equalTo(superview)
            make.height.equalTo(60)
            make.bottom.equalTo(superview.snp.top)
        }
    }
    


}
