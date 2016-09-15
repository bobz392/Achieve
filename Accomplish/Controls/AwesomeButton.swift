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
        
        self.addTarget(self, action: #selector(self.buttonAnimationStartAction(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchUpOutside)
        
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchUpInside)
    }
    
    func buttonAnimationStartAction(_ btn: UIButton) {
        UIView.animate(withDuration: kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
            btn.transform = btn.transform.scaledBy(x: 0.8, y: 0.8)
        }) { (finish) in }
    }
    
    func buttonAnimationEndAction(_ btn: UIButton) {
        UIView.animate(withDuration: kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .layoutSubviews, animations: {
            btn.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (finish) in }
    }
}
