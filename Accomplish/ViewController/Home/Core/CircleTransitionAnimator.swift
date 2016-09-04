//
//  File.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/4.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class CircleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    var reverse: Bool = false
    var buttonFrame: CGRect = CGRectZero
    let maskLayer = CAShapeLayer()
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 10
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        guard let containerView = transitionContext.containerView() else { return }
        
        print(transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey))
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else { return }
        
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else { return }
        
        containerView.addSubview(toViewController.view)
        
        let circleMaskPathInitial = UIBezierPath(ovalInRect: buttonFrame)
        //        let extremePoint = CGPoint(x: button.center.x - 0, y: button.center.y - CGRectGetHeight(toViewController.view.bounds))
        //        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let radius = (buttonFrame.origin.y + 40)
        let circleMaskPathFinal = UIBezierPath(ovalInRect: CGRectInset(buttonFrame, -radius, -radius))
        
        
        toViewController.view.layer.mask = maskLayer
        
        
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        if (self.reverse) {
            maskLayer.path = circleMaskPathInitial.CGPath
            maskLayerAnimation.toValue = circleMaskPathInitial.CGPath
            maskLayerAnimation.fromValue = circleMaskPathFinal.CGPath
        } else {
            maskLayer.path = circleMaskPathFinal.CGPath
            maskLayerAnimation.fromValue = circleMaskPathInitial.CGPath
            maskLayerAnimation.toValue = circleMaskPathFinal.CGPath
        }
        maskLayerAnimation.duration = 0.25
        maskLayerAnimation.delegate = self
        maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.transitionContext?.completeTransition(true)
        
        self.maskLayer.removeFromSuperlayer()
    }
}