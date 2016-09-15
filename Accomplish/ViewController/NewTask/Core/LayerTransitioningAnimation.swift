//
//  LayerAnimation.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class LayerTransitioningAnimation: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    internal let animationDuration: TimeInterval = 0.5
    var reverse = false
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        
        let bounds = screenBounds
        fromView.frame=CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height);
        toView.frame=CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height);
        
        self.animateTransition(transitionContext, fromView: fromView, toView: toView)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    fileprivate func animateTransition(_ transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        let temporaryPoint = CGPoint(x: -toView.frame.maxX, y: toView.frame.midY)
        let centerPoint = toView.center
        
        if (self.reverse){
            toView.center = temporaryPoint
            UIView.animate(withDuration: self.animationDuration * 0.7, animations: {
                fromView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                fromView.alpha = 0
                }, completion: nil)
            
            UIView.animate(withDuration: self.animationDuration * 0.7, delay: self.animationDuration * 0.3, options: UIViewAnimationOptions(), animations: {
                toView.center = centerPoint
                
                }, completion: { (finish) in
                    transitionContext.completeTransition(true)
                    fromView.removeFromSuperview()
            })
        } else {
            toView.alpha = 0.3
            toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: self.animationDuration, animations: {
                fromView.center = temporaryPoint
                toView.transform = CGAffineTransform.identity
                toView.alpha = 1.0
                }, completion: { (finish) in
                    transitionContext.completeTransition(true)
                    fromView.removeFromSuperview()
            })
        }
    }
}
