//
//  AwesomeButton.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class AwesomeButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addTarget(self, action: #selector(self.buttonAnimationStartAction(_:)), forControlEvents: .TouchDown)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), forControlEvents: .TouchUpOutside)
        
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), forControlEvents: .TouchUpInside)
    }
    
    func buttonAnimationStartAction(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
            btn.transform = CGAffineTransformScale(btn.transform, 0.8, 0.8)
        }) { (finish) in }
    }
    
    func buttonAnimationEndAction(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .LayoutSubviews, animations: {
            btn.transform = CGAffineTransformMakeScale(1, 1)
        }) { (finish) in }
    }
}
