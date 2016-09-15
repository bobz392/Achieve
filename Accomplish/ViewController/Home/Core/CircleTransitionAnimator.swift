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
    var buttonFrame: CGRect = CGRect.zero
    let maskLayer = CAShapeLayer()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 10
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        guard let containerView = transitionContext.containerView else { return }
        
        print(transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from))
//        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else { return }
        
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        
        containerView.addSubview(toViewController.view)
        
        let circleMaskPathInitial = UIBezierPath(ovalIn: buttonFrame)
        //        let extremePoint = CGPoint(x: button.center.x - 0, y: button.center.y - CGRectGetHeight(toViewController.view.bounds))
        //        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let radius = (buttonFrame.origin.y + 40)
        let circleMaskPathFinal = UIBezierPath(ovalIn: buttonFrame.insetBy(dx: -radius, dy: -radius))
        
        
        toViewController.view.layer.mask = maskLayer
        
        
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        if (self.reverse) {
            maskLayer.path = circleMaskPathInitial.cgPath
            maskLayerAnimation.toValue = circleMaskPathInitial.cgPath
            maskLayerAnimation.fromValue = circleMaskPathFinal.cgPath
        } else {
            maskLayer.path = circleMaskPathFinal.cgPath
            maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
            maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        }
        maskLayerAnimation.duration = 0.25
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
        
    }
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.transitionContext?.completeTransition(true)
        
        self.maskLayer.removeFromSuperlayer()
    }
}
