//
//  TimeManagementView.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/1.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagementView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: MZTimerLabel!
    @IBOutlet weak var statusButton: UIButton!
    
    fileprivate var method: TimeMethod!
    // 当前所在的 group 的 index
    fileprivate var groupIndex = 0
    // 当前 method 的 repeat 的数量
    fileprivate var methodRepeatTimes = 0
    // 当前所在的 item 的 index
    fileprivate var itemIndex = 0
    // 当前 group 的 repeat 的数量
    fileprivate var groupRepeatTimes = 0
    
    fileprivate let soundManager = SoundManager()
    
    class func loadNib(_ target: AnyObject, method: TimeMethod) -> TimeManagementView? {
        guard let view =
            Bundle.main.loadNibNamed("TimeManagementView", owner: target, options: nil)?
                .first as? TimeManagementView else {
                    return nil
        }
        
        let colors = Colors()
        
        view.countLabel.timerType = MZTimerLabelType.init(1)
        view.countLabel.timeFormat = "HH:mm:ss"
        view.countLabel.font = UIFont(name: "Courier", size: 30)
        view.countLabel.textColor = colors.cloudColor
        view.countLabel.delegate = view
        
        view.titleLabel.textColor = colors.secondaryTextColor
        
        view.statusButton.setTitleColor(colors.cloudColor, for: .normal)
        view.statusButton.addTarget(view, action: #selector(view.start), for: .touchUpInside)
        view.statusButton.tag = 0
        view.statusButton.setTitle(Localized("startTimeManage"), for: .normal)
        
        view.method = method
        
        NotificationCenter.default
            .addObserver(view, selector: #selector(view.saveTimeManage),
                         name: NSNotification.Name.UIApplicationDidEnterBackground,
                         object: nil)
        NotificationCenter.default
            .addObserver(view, selector: #selector(view.enterTimeManage),
                         name: NSNotification.Name.UIApplicationDidBecomeActive,
                         object: nil)
        
        return view
    }
    
    func saveTimeManage() {
        self.countLabel.pause()
    }
    
    func enterTimeManage() {
        self.countLabel.start()
        
        AppUserDefault().remove(kUserDefaultTMDetailsKey)
    }
    
    func moveIn(view: UIView) {
        UIApplication.shared.isIdleTimerDisabled = true
        view.addSubview(self)
        
        self.snp.makeConstraints({ (make) in
            make.top.equalTo(view)
            make.trailing.equalTo(view)
            make.leading.equalTo(view)
            make.height.equalTo(view)
        })
        self.alpha = 0
        UIView.animate(withDuration: kSmallAnimationDuration) { [unowned self] in
            self.alpha = 1
        }
    }
    
    func moveOut() {
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.removeObserver(self)
        
        UIView.animate(withDuration: kSmallAnimationDuration, animations: {
            self.alpha = 0
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    func start() {
        if self.statusButton.tag == 0 {
            self.statusButton.setTitle(Localized("endTimeManage"), for: .normal)
            self.statusButton.tag = 1
            self.nextStatus()
        } else {
            self.statusButton.setTitle(Localized("startTimeManage"), for: .normal)
            self.statusButton.tag = 0
            self.finish()
        }
    }
}

extension TimeManagementView: MZTimerLabelDelegate {
    func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        Logger.log("finish")
        
        self.soundManager.systemDing()
        self.nextStatus()
    }
    
    fileprivate func nextStatus() {
        let group = self.method.groups[self.groupIndex]
        let item = group.items[self.itemIndex]
        
        // 如果当前的 method 的重复已经完成了，则结束
        if self.methodRepeatTimes > self.method.repeatTimes
            && self.method.repeatTimes != kTimeMethodInfiniteRepeat {
            self.finish()
        } else {
            self.titleLabel.text = item.name
            #if debug
                self.countLabel.setCountDownTime(5)
            #else
                self.countLabel.setCountDownTime(item.interval)
            #endif
            self.countLabel.start()
            
            // 每次时间到了 itemIndex + 1
            // 如果 itemIndex 加一后，已经超过 group 中 item 的 count，那么 groupRepeatTimes + 1
            // 如果 groupRepeatTimes 超过了 group 的 repeat count 那么 groupIndex + 1
            // 如果 groupIndex 超过了 method 中 group count 那么 methodRepeatTimes + 1, 并且 index 都恢复为最初状态
            self.itemIndex += 1
            if self.itemIndex >= group.items.count {
                self.itemIndex = 0
                self.groupRepeatTimes += 1
                if self.groupRepeatTimes >= group.repeatTimes {
                    self.groupRepeatTimes = 0
                    self.groupIndex += 1
                    
                    if self.groupIndex >= method.groups.count {
                        self.methodRepeatTimes += 1
                        self.groupIndex = 0
                        self.itemIndex = 0
                    }
                }
            }
        }
    }
    
    fileprivate func finish() {
        self.moveOut()
    }
}
