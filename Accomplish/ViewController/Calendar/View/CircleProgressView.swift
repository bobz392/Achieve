//
//  CircleProgressView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/6.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

let kCalendarProgressAnimationDuration: TimeInterval = 0.75

final class CircleProgressView: UIView {
    
    let circleShapeLayer = CircleShapeLayer()
    let circleButton = UIButton(type: UIButtonType.custom)
    let precentLabel = UICountingLabel()
    let scheduleLabel = UILabel()
    
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
        let percent: CGFloat
        if completed > 0 && created >= completed {
            percent = CGFloat(completed) / CGFloat(created)
        } else {
            percent = 0
        }
        self.circleShapeLayer.startAnimation(Double(percent))
        let labelPercent = CGFloat(percent * 100.0)
        self.precentLabel.countFromCurrentValue(to: labelPercent, withDuration: kCalendarProgressAnimationDuration)
    }
    
    func setup() {
        self.circleShapeLayer.frame = self.bounds
        self.layer.addSublayer(self.circleShapeLayer)
        
        self.addSubview(self.circleButton)
        self.circleButton.backgroundColor = Colors.cellCardColor
        self.circleButton.addButtonShadow()
        self.circleButton.addTarget(self, action: #selector(self.buttonAnimationStartAction(_:)), for: .touchDown)
        self.circleButton.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchUpOutside)
        self.circleButton.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchDragOutside)
        self.circleButton.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchUpInside)
        self.circleButton.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchCancel)
        self.circleButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        self.addSubview(self.precentLabel)
        self.precentLabel.textColor = Colors.mainTextColor
        self.precentLabel.numberOfLines = 1
        self.precentLabel.animationDuration = kCalendarProgressAnimationDuration
        self.precentLabel.font = UIFont(name: "Courier New", size: DeviceSzie.isSmallDevice() ? 40 : 60)
        self.precentLabel.method = .easeInOut
        self.precentLabel.format = "%d"
        self.precentLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview().offset(DeviceSzie.isSmallDevice() ? -10 : -30)
        }
        
        self.addSubview(self.scheduleLabel)
        self.scheduleLabel.textColor = Colors.secondaryTextColor
        self.scheduleLabel.font = UIFont.systemFont(ofSize: DeviceSzie.isSmallDevice() ? 14 : 18)
        self.scheduleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(DeviceSzie.isSmallDevice() ? 25 : 45)
        }
        
        let pLabel = UILabel()
        pLabel.font = UIFont.systemFont(ofSize: DeviceSzie.isSmallDevice() ? 14 : 20, weight: UIFontWeightLight)
        pLabel.textColor = Colors.mainTextColor
        pLabel.text = "%"
        self.addSubview(pLabel)
        pLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.precentLabel.snp.right)
            make.bottom.equalTo(self.precentLabel).offset(-15)
        }
        
    }
    
    func configButtonCorner() {
        self.circleButton.layer.cornerRadius = self.circleButton.frame.width * 0.5
    }

    func buttonAnimationStartAction(_ btn: UIButton) {
        UIView.animate(withDuration: kNormalAnimationDuration) { 
            self.circleButton.backgroundColor = Colors.cellCardSelectedColor
        }
    }
    
    func buttonAnimationEndAction(_ btn: UIButton) {
        UIView.animate(withDuration: kNormalAnimationDuration) {
            self.circleButton.backgroundColor = Colors.cellCardColor
        }
    }
}


internal final class CircleShapeLayer: CAShapeLayer, CAAnimationDelegate {
    
    fileprivate let progressLayer = CAShapeLayer()
    fileprivate let circleLineWidth: CGFloat = 2
    
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
    
    func startAnimation(_ percent: Double) {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = kCalendarProgressAnimationDuration
//        pathAnimation.fromValue = self.percent
        pathAnimation.toValue = percent
        pathAnimation.delegate = self
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.progressLayer.add(pathAnimation, forKey: nil)
        self.inAnimation = true
        
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        self.progressLayer.strokeEnd = CGFloat(self.percent)
//        CATransaction.commit()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.inAnimation = false
    }
    
    fileprivate func setupLayer() {
        self.path = self.drawPathWithArcCenter()
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = Colors.mainBackgroundColor.cgColor
        self.lineWidth = circleLineWidth
        self.backgroundColor = UIColor.clear.cgColor
        
        self.progressLayer.backgroundColor = UIColor.clear.cgColor
        self.progressLayer.path = self.drawPathWithArcCenter()
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.strokeColor = Colors.cellLabelSelectedTextColor.cgColor
        self.progressLayer.lineWidth = circleLineWidth
        self.progressLayer.lineCap = kCALineCapButt//kCALineCapRound
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
