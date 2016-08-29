//
//  LayerAnimation.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class LayerTransitioningAnimation: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    internal let animationDuration: NSTimeInterval = 0.5
    var reverse = false
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view else { return }
        guard let toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view else { return }
        
        let bounds = screenBounds
        fromView.frame=CGRectMake(0, 0, bounds.width, bounds.height);
        toView.frame=CGRectMake(0, 0, bounds.width, bounds.height);
        
        self.animateTransition(transitionContext, fromView: fromView, toView: toView)
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    private func animateTransition(transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {
        
        guard let containerView = transitionContext.containerView() else { return }
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        let temporaryPoint = CGPointMake(-CGRectGetMaxX(toView.frame), CGRectGetMidY(toView.frame))
        let centerPoint = toView.center
        
        if (self.reverse){
            toView.center = temporaryPoint
            UIView.animateWithDuration(self.animationDuration * 0.7, animations: {
                fromView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                fromView.alpha = 0.3
                }, completion: nil)
            
            UIView.animateWithDuration(self.animationDuration, delay: self.animationDuration / 8.0, options: .CurveEaseInOut, animations: {
                toView.center = centerPoint
                fromView.alpha = 0
                }, completion: { (finish) in
                    transitionContext.completeTransition(true)
                    fromView.removeFromSuperview()
            })
        } else {
            toView.alpha = 0.3
            toView.transform = CGAffineTransformMakeScale(0.8, 0.8)
            UIView.animateWithDuration(self.animationDuration, animations: {
                fromView.center = temporaryPoint
                toView.transform = CGAffineTransformIdentity
                toView.alpha = 1.0
                }, completion: { (finish) in
                    transitionContext.completeTransition(true)
                    fromView.removeFromSuperview()
            })
        }
    }
}