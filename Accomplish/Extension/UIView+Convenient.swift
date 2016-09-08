//
//  UIView+Corner.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

extension UIView {
    func addCorner(rectCorner: UIRectCorner, value: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: value, height: value))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.CGPath
        layer.mask = maskLayer
    }
    
    func convertViewToImage() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func addShadow() {
        self.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 3
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
    }
    
    func addTopShadow() {
        self.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 3
        self.layer.shadowOffset = CGSize(width: 3, height: -3)
        
        let slayer = CALayer()
        slayer.backgroundColor = UIColor.clearColor().CGColor
        slayer.shadowColor = UIColor.darkGrayColor().CGColor
        slayer.shadowOpacity = 0.15
        slayer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.addSublayer(slayer)
    }
    
    func addSmallShadow() {
        self.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 1.5
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    }
    
    func addCornerRadiusAnimation(from: CGFloat, to: CGFloat, duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        self.layer.addAnimation(animation, forKey: "cornerRadius")
        self.layer.cornerRadius = to
    }
    
    func buttonColor(colors: Colors) {
        self.tintColor = colors.mainGreenColor
        self.backgroundColor = colors.cloudColor
    }
    
    func clearView() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    func addBlurEffect() {
        let eff = UIBlurEffect(style: .Light)
        let effView = UIVisualEffectView(effect: eff)
        effView.userInteractionEnabled = false
        
        self.insertSubview(effView, atIndex: 0)
        layoutIfNeeded()
        effView.frame = self.bounds
    }
}
