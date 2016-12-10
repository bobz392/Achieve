//
//  FinishView.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/10.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class FinishView: UIView {
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var finishLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    class func loadNib(_ target: AnyObject) -> FinishView? {
        return Bundle.main.loadNibNamed("FinishView", owner: target, options: nil)?.first as? FinishView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let colors = ShareColors()
        self.finishLabel.textColor = colors.cloudColor
        
        self.shadowView.alpha = 0
        self.contentView.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.finishLabel.isHidden = true
        self.finishLabel.text = Localized("shareCreated")
    }
    
    func addToWindow(window: UIWindow, finishBlock: @escaping () -> Void) {
        self.frame = window.bounds
        window.addSubview(self)
        
        let weakSelf = self
        
        UIView.animate(withDuration: 0.15, animations: {
            weakSelf.shadowView.alpha = 0.8
        })
        
        let options: UIViewAnimationOptions = [.beginFromCurrentState, .layoutSubviews]
        
        UIView.animate(withDuration: 0.25, delay: 0.14, options: options, animations: {
            weakSelf.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (finish) -> Void in
                weakSelf.finishLabel.isHidden = false
        })
        
        UIView.animate(withDuration: 0.25, delay: 1.6, options: options, animations: {
            weakSelf.alpha = 0
        }, completion: { (finish) -> Void in
            weakSelf.removeFromSuperview()
            finishBlock()
        })
    }
}
