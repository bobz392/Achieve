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
    
    func start(completed: Int, created: Int) {
        self.circleShapeLayer.start(created, finish: completed)
    }
    
    func setup() {
        self.circleShapeLayer.frame = self.bounds
        self.layer.addSublayer(self.circleShapeLayer)
    }
}


internal final class CircleShapeLayer: CAShapeLayer, CAAnimationDelegate {
    
    fileprivate let progressLayer = CAShapeLayer()
    fileprivate let circleLineWidth: CGFloat = 10
    fileprivate var percent: Double = 0
    
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

    func start(_ total: Int, finish: Int) {
        guard total > 0 && finish > 0 && total >= finish else {
            self.progressLayer.strokeEnd = 0
            return
        }
        self.percent = Double(finish) / Double(total)
        
        self.progressLayer.strokeEnd = CGFloat(self.percent)
        self.startAnimation(self.percent)
    }
    
    fileprivate func startAnimation(_ percent: Double) {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = kCalendarProgressAnimationDuration
        pathAnimation.fromValue = 0
        pathAnimation.toValue = percent
        pathAnimation.delegate = self
        pathAnimation.isRemovedOnCompletion = true
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        self.progressLayer.add(pathAnimation, forKey: nil)
        self.inAnimation = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.inAnimation = false
    }
    
    fileprivate func setupLayer() {
        let colors = Colors()
        self.path = self.drawPathWithArcCenter()
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = colors.cloudColor.cgColor
        self.lineWidth = circleLineWidth
        self.backgroundColor = UIColor.clear.cgColor
        
        self.progressLayer.backgroundColor = UIColor.clear.cgColor
        self.progressLayer.path = self.drawPathWithArcCenter()
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.strokeColor = colors.progressColor.cgColor
        self.progressLayer.lineWidth = circleLineWidth
        self.progressLayer.lineCap = kCALineCapRound
        self.progressLayer.lineJoin = kCALineJoinRound
        self.progressLayer.strokeEnd = 0
        
        self.addSublayer(progressLayer)
    }
    
    fileprivate func drawPathWithArcCenter() -> CGPath {
        let positionY = self.frame.height * 0.5
        let positionX = self.frame.width * 0.5
        let center = CGPoint(x: positionX, y: positionY)
        return UIBezierPath(arcCenter: center, radius: positionX, startAngle: CGFloat(-M_PI * 0.5), endAngle: CGFloat(1.5 * M_PI), clockwise: true).cgPath
    }
}
