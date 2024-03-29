//
//  MenuButton.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/28.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import QuartzCore

class MenuButton: UIButton {
    
    var menuPath : CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: thickness * 0.5, y: thickness * 0.5))
        path.addLine(to: CGPoint(x: lineWidth - thickness * 0.5, y: thickness * 0.5))
        
        return path
    }
    
    var sidePath: CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: self.bounds.height * 0.5))
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height * 0.5))
        return path
    }
    
    let animateDuration : Double = 0.3
    let animateDelay: Double = 0.05
    
    
    @IBInspectable var lineWidth : CGFloat = 28{
        didSet{
            self.updateSubLayers()
        }
    }
    
    @IBInspectable var thickness : CGFloat = 4{
        didSet{
            self.updateSubLayers()
        }
    }
    
    @IBInspectable var lineMargin : CGFloat = 10{
        didSet{
            self.updateSubLayers()
        }
    }
    
    @IBInspectable var lineCapRound : Bool = true{
        didSet{
            self.updateSubLayers()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var strokeColor : UIColor = UIColor.white{
        didSet{
            self.updateSubLayers()
        }
    }
    
    override var isSelected: Bool{
        didSet{
            self.showMenu(self.isSelected)
        }
    }

    let topLayer = CAShapeLayer()
    let midLayer = CAShapeLayer()
    let bottomLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setups()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setups()
    }
    
    func setups(){
        for layer in  [topLayer, midLayer, bottomLayer] {
            layer.masksToBounds = true
            layer.actions = [
                "strokeStart": NSNull(),
                "strokeEnd": NSNull(),
            ]
            self.layer.addSublayer(layer)
        }
        self.updateSubLayers()
    }
    
    func showMenu(_ isShow: Bool){
        let keyPath = "strokeEnd"
        for (idx, layer) in [topLayer, midLayer, bottomLayer].enumerated(){
            let anim = CABasicAnimation(keyPath: keyPath)
            let toValue = isShow ? 0.3 + Double(idx) * 0.2 : 1.0
            anim.toValue = toValue
            anim.duration = animateDuration
            anim.fillMode = CAMediaTimingFillMode.backwards
            anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            anim.beginTime = CACurrentMediaTime() + Double(idx) * animateDelay
            layer.applyAnimation(anim)
        }
    }
    
    
    func updateSubLayers(){
        let path = self.menuPath
        let strokingPath = CGPath(__byStroking: path, transform: nil, lineWidth: thickness, lineCap: CGLineCap.round, lineJoin: CGLineJoin.miter, miterLimit: 10)
        let bounds = strokingPath?.boundingBoxOfPath
        for layer in [topLayer, midLayer, bottomLayer] {
            layer.path = path
            layer.bounds = bounds!
            layer.strokeColor = self.strokeColor.cgColor
            layer.lineWidth = thickness
            layer.lineCap = lineCapRound ? .round : .square
        }
        self.setNeedsLayout()
    }
    
    
    override func layoutSubviews() {
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        self.midLayer.position = center
        self.topLayer.position = CGPoint(x: center.x, y: center.y - lineMargin)
        self.bottomLayer.position = CGPoint(x: center.x, y: center.y + lineMargin)
    }
}

extension CALayer {
    func applyAnimation(_ animation: CABasicAnimation) {
        let copy = animation.copy() as! CABasicAnimation
        if copy.fromValue == nil {
            copy.fromValue = self.presentation()!.value(forKeyPath: copy.keyPath!)
        }
        self.add(copy, forKey: copy.keyPath)
        self.setValue(copy.toValue, forKeyPath:copy.keyPath!)
    }
}

