//
//  CircleProgressView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/6.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

let kCalendarProgressAnimationDuration: CFTimeInterval = 0.75

final class CircleProgressView: UIView {
    
    let circleShapeLayer = CircleShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clearView()
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.circleShapeLayer.frame = self.bounds
    }
    
    func isInAnimation() -> Bool {
        return circleShapeLayer.inAnimation
    }
    
    func start(completed completed: Int, created: Int) {
        self.circleShapeLayer.start(created, finish: completed)
    }
    
    func setup() {
        self.circleShapeLayer.frame = self.bounds
        self.layer.addSublayer(self.circleShapeLayer)
    }
}


internal final class CircleShapeLayer: CAShapeLayer {
    
    private let progressLayer = CAShapeLayer()
    private let circleLineWidth: CGFloat = 10
    private var percent: Double = 0
    
    var inAnimation = false
    
    override init() {
        super.init()
        self.setupLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        self.path = self.drawPathWithArcCenter()
        self.progressLayer.path = self.drawPathWithArcCenter()
        
        super.layoutSublayers()
    }

    func start(total: Int, finish: Int) {
        guard total > 0 && finish > 0 && total > finish else {
            self.progressLayer.strokeEnd = 0
            return
        }
        self.percent = Double(finish) / Double(total)
        
        self.progressLayer.strokeEnd = CGFloat(self.percent)
        self.startAnimation(self.percent)
    }
    
    private func startAnimation(percent: Double) {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = kCalendarProgressAnimationDuration
        pathAnimation.fromValue = 0
        pathAnimation.toValue = percent
        pathAnimation.delegate = self
        pathAnimation.removedOnCompletion = true
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        self.progressLayer.addAnimation(pathAnimation, forKey: nil)
        self.inAnimation = true
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.inAnimation = false
    }
    
    private func setupLayer() {
        let colors = Colors()
        self.path = self.drawPathWithArcCenter()
        self.fillColor = UIColor.clearColor().CGColor
        self.strokeColor = colors.cloudColor.CGColor
        self.lineWidth = circleLineWidth
        self.backgroundColor = UIColor.clearColor().CGColor
        
        self.progressLayer.backgroundColor = UIColor.clearColor().CGColor
        self.progressLayer.path = self.drawPathWithArcCenter()
        self.progressLayer.fillColor = UIColor.clearColor().CGColor
        self.progressLayer.strokeColor = colors.priorityLowColor.CGColor
        self.progressLayer.lineWidth = circleLineWidth
        self.progressLayer.lineCap = kCALineCapRound
        self.progressLayer.lineJoin = kCALineJoinRound
        self.progressLayer.strokeEnd = 0
        
        self.addSublayer(progressLayer)
    }
    
    private func drawPathWithArcCenter() -> CGPathRef {
        let positionY = self.frame.height * 0.5
        let positionX = self.frame.width * 0.5
        let center = CGPointMake(positionX, positionY)
        return UIBezierPath(arcCenter: center, radius: positionX, startAngle: CGFloat(-M_PI * 0.5), endAngle: CGFloat(1.5 * M_PI), clockwise: true).CGPath
    }
}