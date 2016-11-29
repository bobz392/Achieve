//
//  TimeManagementView.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/1.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

enum StartTimeStatuType {
    case Start
    case Init
}

class TimeManagementView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loopLabel: UILabel!
    @IBOutlet weak var countLabel: MZTimerLabel!
    @IBOutlet weak var statusShutterButton: KYShutterButton!
    @IBOutlet weak var cancelTMButton: UIButton!
    @IBOutlet weak var finishTaskButton: UIButton!
    
    fileprivate var method: TimeMethod!
    // 当前所在的 group 的 index
    fileprivate var groupIndex = 0
    // 当前 method 的 repeat 的数量
    fileprivate var methodRepeatTimes = 0
    // 当前所在的 item 的 index
    fileprivate var itemIndex = 0
    // 当前 group 的 repeat 的数量
    fileprivate var groupRepeatTimes = 0
    
    fileprivate var currentStatusRunning = false

    var startType = StartTimeStatuType.Init
    var task: Task!
    
    fileprivate let soundManager = SoundManager()
    
    class func loadNib(_ target: AnyObject, method: TimeMethod, task: Task) -> TimeManagementView? {
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
        view.loopLabel.textColor = colors.secondaryTextColor
        view.titleLabel.textColor = colors.secondaryTextColor
        view.titleLabel.text = method.name
        
        view.statusShutterButton.buttonColor = colors.systemGreenColor
        view.statusShutterButton.addTarget(view, action: #selector(view.startAction), for: .touchUpInside)
        view.cancelTMButton.setTitle(Localized("cancelTimeManager"), for: .normal)
        view.cancelTMButton.setTitleColor(colors.cloudColor, for: .normal)
        view.finishTaskButton.setTitle(Localized("finishTimeManager"), for: .normal)
        view.finishTaskButton.setTitleColor(colors.cloudColor, for: .normal)
        view.cancelTMButton.addTarget(view, action: #selector(view.finish), for: .touchUpInside)
        view.finishTaskButton.addTarget(view, action: #selector(view.finishTaskAndCancelTM), for: .touchUpInside)
        
        view.method = method
        view.task = task
        
        NotificationCenter.default
            .addObserver(view, selector: #selector(view.saveTimeManager),
                         name: NSNotification.Name.UIApplicationDidEnterBackground,
                         object: nil)
        NotificationCenter.default
            .addObserver(view, selector: #selector(view.saveTimeManager),
                         name: NSNotification.Name.UIApplicationWillTerminate,
                         object: nil)
        NotificationCenter.default
            .addObserver(view, selector: #selector(view.enterTimeManager),
                         name: NSNotification.Name.UIApplicationDidBecomeActive,
                         object: nil)
        
        return view
    }
    
    func configTimeManager(details: Array<Int>) {
        self.groupIndex = details[0]
        self.methodRepeatTimes = details[1]
        self.itemIndex = details[2]
        self.groupRepeatTimes = details[3]
        
        if self.methodRepeatTimes > 0 {
            self.loopLabel.text = "\(self.methodRepeatTimes) " + method.timeMethodAliase
        }
        
        self.startAction()
        AppUserDefault().remove(kUserDefaultTMDetailsKey)
        AppUserDefault().remove(kUserDefaultTMUUIDKey)
        AppUserDefault().remove(kUserDefaultTMTaskUUID)
    }
    
    func saveTimeManager() {
        self.countLabel.pause()

        AppUserDefault().write(kUserDefaultTMDetailsKey,
                               value: [groupIndex, methodRepeatTimes, itemIndex, groupRepeatTimes])
        AppUserDefault().write(kUserDefaultTMUUIDKey, value: self.method.uuid)
        AppUserDefault().write(kUserDefaultTMTaskUUID, value: self.task.uuid)
    }
    
    func enterTimeManager() {
        self.countLabel.start()
        
        AppUserDefault().remove(kUserDefaultTMDetailsKey)
        AppUserDefault().remove(kUserDefaultTMUUIDKey)
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
    
    func startAction() {
        // 点击以后开始计时
        let colors = Colors()
        if self.currentStatusRunning == false {
            self.statusShutterButton.buttonState = .recording
            self.statusShutterButton.buttonColor = colors.systemRedColor
            self.countLabel.textColor = colors.cloudColor
            if self.startType == .Init {
                self.nextStatus()
                self.startType = .Start
            } else {
                self.countLabel.start()
            }
        } else {
            self.countLabel.textColor = colors.secondaryTextColor
            self.statusShutterButton.buttonState = .normal
            self.statusShutterButton.buttonColor = Colors().systemGreenColor
            self.countLabel.pause()
        }
        
        self.currentStatusRunning = !self.currentStatusRunning
    }
    
    func finishTaskAndCancelTM() {
        RealmManager.shared.updateObject { [unowned self] in
            RealmManager.shared.updateTaskStatus(self.task, status: kTaskFinish)
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
            self.statusShutterButton.rotateAnimateDuration = Float(item.interval)
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
                        self.loopLabel.text = "\(self.methodRepeatTimes) " + method.timeMethodAliase
                    }
                }
            }
        }
    }
    
    func finish() {
        // 如果选择此工作法，那么使用次数 + 1
        RealmManager.shared.updateObject { [unowned self] in
            self.method.useTimes += 1
        }
        
        self.countLabel.pause()
        self.moveOut()
    }
}
