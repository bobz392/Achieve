//
//  TouchButton.swift
//  Accomplish
//
//  Created by zhoubo on 2017/1/10.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class TouchButton: UIButton {
    
    func config() {
        self.backgroundColor = Colors.cellCardColor
        self.addButtonShadow()
        self.addTarget(self, action: #selector(self.buttonAnimationStartAction(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchUpOutside)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchCancel)
        
        self.adjustsImageWhenHighlighted = false
    }
    
    func configButtonCorner() {
        self.layer.cornerRadius = self.frame.width * 0.5
    }
    
    func buttonAnimationStartAction(_ btn: UIButton) {
        UIView.animate(withDuration: kNormalAnimationDuration) {
            self.backgroundColor = Colors.cellCardSelectedColor
        }
    }
    
    func buttonAnimationEndAction(_ btn: UIButton) {
        UIView.animate(withDuration: kNormalAnimationDuration) {
            self.backgroundColor = Colors.cellCardColor
        }
    }
    
    func changeStatus(color: UIColor) {
        UIView.animate(withDuration: kNormalLongAnimationDuration) {
            self.tintColor = color
        }
    }
}
