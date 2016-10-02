//
//  HomePulldownView.swift
//  Accomplish
//
//  Created by zhoubo on 2016/10/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class HomePulldownView: UIView {

    let minFontSize: CGFloat = 9
    let maxFontSize: CGFloat = 18
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    class func loadNib(_ target: AnyObject) -> HomePulldownView? {
        return Bundle.main.loadNibNamed("HomePulldownView", owner: target, options: nil)?
            .first as? HomePulldownView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let colors = Colors()
        self.imageView.createIconImage(iconSize: 25, imageSize: 35, icon: "fa-arrow-circle-up", color: colors.mainGreenColor)
    }
    
    func layout(superview: UIView, holderView: UIView) {
        self.snp.makeConstraints { (make) in
            make.width.equalTo(superview)
            make.top.equalTo(holderView.snp.bottom)
            make.bottom.equalTo(superview.snp.top).offset(-5.0)
        }
    }
    

    func setConstraint(current: Int) {
//        if current == kRunningSegmentIndex {
//            constraint.constant.multiply(by: 0.5)
//        } else {
//            constraint.constant.multiply(by: 1.5)
//        }
    }
    

}
