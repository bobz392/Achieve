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

class TMView: UIView {
    
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loopLabel: UILabel!
    @IBOutlet weak var countLabel: MZTimerLabel!
    @IBOutlet weak var circleView: CircleProgressView!
    
    @IBOutlet weak var cancelTMButton: TouchButton!
    
    fileprivate var method: TimeMethod!
    // 当前所在的 group 的 index
    fileprivate var groupIndex = 0
    // 当前 method 的 repeat 的数量
    fileprivate var methodRepeatTimes = 0
    // 当前所在的 item 的 index
    fileprivate var itemIndex = -1
    // 当前 group 的 repeat 的数量
    fileprivate var groupRepeatTimes = 0
    
    fileprivate var currentStatusRunning = false
    fileprivate var foucustime: Int = 0
    
    var startType = StartTimeStatuType.Init
    var task: Task!
    weak var baseVC: BaseViewController!
    
    fileprivate let soundManager = SoundManager()
    
    class func loadNib(_ target: AnyObject, method: TimeMethod, task: Task) -> TMView? {
        guard let view =
            Bundle.main.loadNibNamed("TMView", owner: target, options: nil)?
                .first as? TMView else {
                    return nil
        }
        
        view.countLabel.timerType = MZTimerLabelType.init(1)
        view.countLabel.timeFormat = "HH:mm:ss"
        view.countLabel.text = "         "
        view.countLabel.font = UIFont(name: "Courier",
                                      size: DeviceSzie.isSmallDevice() ? 50 : 70 )
        view.countLabel.adjustsFontSizeToFitWidth = true
        view.countLabel.textColor = Colors.mainTextColor
        view.countLabel.highlightedTextColor = Colors.secondaryTextColor
        view.countLabel.delegate = view
        
        view.statusLabel.textColor = Colors.secondaryTextColor
        view.statusLabel.text = Localized("timeMethodPrepar")
        
        view.loopLabel.textColor = Colors.secondaryTextColor
        view.titleLabel.textColor = Colors.secondaryTextColor
        view.titleLabel.text = method.name
        
        let side: CGFloat = DeviceSzie.isSmallDevice() ? 50 : 70
        view.buttonWidthConstraint.constant = side
        view.buttonHeightConstraint.constant = side
        
        view.circleView.circleButton
            .addTarget(view, action:  #selector(self.startAction), for: .touchUpInside)
        view.circleView.setPrecentLableEnable(enabel: false)
        view.circleView.backgroundColor = UIColor.clear
        
        view.cancelTMButton.buttonWithIcon(icon: Icons.bigClear.iconString())
        view.cancelTMButton.tintColor = Colors.cellLabelSelectedTextColor
        view.cancelTMButton.config()
        view.cancelTMButton.contentMode = .scaleAspectFill

        view.cancelTMButton.backgroundColor = UIColor.white
        view.cancelTMButton.layer.cornerRadius = 16
        view.cancelTMButton.addTarget(view, action: #selector(view.cancelAction), for: .touchUpInside)
        
        let swipe = UISwipeGestureRecognizer(target: view, action: #selector(blockGecognizer))
        view.addGestureRecognizer(swipe)
        let pan = UIPanGestureRecognizer(target: view, action: #selector(blockGecognizer))
        view.addGestureRecognizer(pan)
        let edgepan = UIScreenEdgePanGestureRecognizer(target: view, action: #selector(blockGecognizer))
        view.addGestureRecognizer(edgepan)
        
        view.method = method
        view.task = task
        view.baseVC = target as! BaseViewController
        
        NotificationCenter.default
            .addObserver(view, selector: #selector(view.saveTimeManager),
                         name: NSNotification.Name.UIApplicationDidEnterBackground,
                         object: nil)
        NotificationCenter.default
            .addObserver(view, selector: #selector(view.saveTimeManager),
                         name: NSNotification.Name.UIApplicationWillTerminate,
                         object: nil)
        NotificationCenter.default
            .addObserver(view, selector: #selector(view.clearTimeManagerUserDefault),
                         name: NSNotification.Name.UIApplicationDidBecomeActive,
                         object: nil)
        
        if let groupUserDefault = GroupUserDefault() {
            groupUserDefault.writeRunningTimeMethod(taskName: task.taskToDo)
        }
        
        return view
    }
    
    func blockGecognizer() {
        //do nothing
    }
    
    // 当从后台进入的时候，此时app已经完全退出，根据 usefdefault 来重新创建
    func configTimeManager(details: Array<Int>) {
        self.groupIndex = details[0]
        self.methodRepeatTimes = details[1]
        self.itemIndex = details[2]
        self.groupRepeatTimes = details[3]
        
        if self.methodRepeatTimes > 0 {
            self.loopLabel.text = "\(self.methodRepeatTimes) " + method.timeMethodAliase
        }
        
        self.nextStatus(false)
        self.startType = .Start
        self.clearTimeManagerUserDefault()
        
        self.statusLabel.text = Localized("timeMethodPrepar")
    }
    
    /**
     保存当前的信息，因为app即将进入后台，并且暂停当前count
     */
    func saveTimeManager() {
        if self.currentStatusRunning == true {
            self.startAction()
        }
        
        let appUserDefault = AppUserDefault()
        appUserDefault.write(kUserDefaultTMDetailsKey,
                               value: [groupIndex, methodRepeatTimes, itemIndex, groupRepeatTimes])
        appUserDefault.write(kUserDefaultTMUUIDKey, value: self.method.uuid)
        appUserDefault.write(kUserDefaultTMTaskUUID, value: self.task.uuid)
    }
    
    /**
     恢复之前保存的信息，此时仅仅用于当app没有彻底退出还在后台的时候
     */
    func clearTimeManagerUserDefault() {
        let appUserDefault = AppUserDefault()
        appUserDefault.remove(kUserDefaultTMDetailsKey)
        appUserDefault.remove(kUserDefaultTMUUIDKey)
        appUserDefault.remove(kUserDefaultTMTaskUUID)
    }
    
    func configBlurImageView(view: UIView) {
        let image = view.convertViewToImage()
        self.blurImageView.image =
            image.blurredImage(5, iterations: 3, ratio: 2.0, blendColor: nil, blendMode: .clear)
        self.frame = view.bounds
    }
    
    func moveIn(view: UIView) {
        UIApplication.shared.isIdleTimerDisabled = true
        // 进来的时候先隐藏
        let image = view.convertViewToImage()
        self.blurImageView.image =
            image.blurredImage(5, iterations: 3, ratio: 2.0, blendColor: nil, blendMode: .clear)
        self.blurImageView.alpha = 0
        self.frame = view.bounds
        view.addSubview(self)
        self.layoutIfNeeded()
        
        self.circleView.configButtonCorner()
        self.cancelTMButton.configButtonCorner()
        
        self.snp.makeConstraints({ (make) in
            make.top.equalTo(view)
            make.trailing.equalTo(view)
            make.leading.equalTo(view)
            make.height.equalTo(view)
        })
        
        UIApplication.shared.setStatusBarHidden(true, with: .slide)
        
        self.countLabel.isHighlighted = false
        
        UIView.animate(withDuration: kSmallAnimationDuration, animations: { [unowned self] in
            self.blurImageView.alpha = 1
        }) { [unowned self] (finish) in
            if let intv = self.method.groups.first?.items.first?.interval {
                self.countLabel.setCountDownTime(TimeInterval(intv))
            }
            
        }
    }
    
    func moveOut() {
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.removeObserver(self)
        
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
        
        UIView.animate(withDuration: kSmallAnimationDuration, animations: {
            self.alpha = 0
        }) { (finish) in
            self.removeFromSuperview()
            guard let groupUserDefault = GroupUserDefault() else { return }
            groupUserDefault.writeRunningTimeMethod(taskName: nil)
        }
    }
    
    func startAction() {
        // 点击以后开始计时
        if self.currentStatusRunning == false {
            self.countLabel.isHighlighted = false
            self.statusLabel.text = ""
            if self.startType == .Init {
                self.nextStatus()
                self.startType = .Start
            } else {
                self.countLabel.start()
                self.circleView.resume()
            }
        } else {
            self.countLabel.isHighlighted = true
            self.statusLabel.text = Localized("timeMethodPause")
            self.countLabel.pause()
            self.circleView.pause()
        }
        
        self.currentStatusRunning = !self.currentStatusRunning
    }
    
    func finishTaskAndCancelTM() {
        RealmManager.shared.updateTaskStatus(self.task, newStatus: .completed)
        self.finish()
    }
    
    /**
     弹出退出的选择 action sheet
     */
    func cancelAction() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: Localized("cancelTimeManager"), style: .default, handler: { [unowned self] (action) -> Void in
            self.finish()
            self.clearTimeManagerUserDefault()
        })
        alertVC.addAction(cancelAction)
        
        let finishTaskAction = UIAlertAction(title: Localized("finishTask"), style: .destructive, handler: { [unowned self] (action) -> Void in
            self.finishTaskAndCancelTM()
            self.clearTimeManagerUserDefault()
        })
        alertVC.addAction(finishTaskAction)
        
        let continueAction = UIAlertAction(title: Localized("continue"), style: .cancel, handler: { (action) -> Void in
            alertVC.dismiss(animated: true, completion: nil)
        })
        alertVC.addAction(continueAction)
        
        self.baseVC.present(alertVC, animated: true, completion: nil)
    }
}

extension TMView: MZTimerLabelDelegate {
    func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        Logger.log("finish")
        
        self.soundManager.systemDing()
        self.nextStatus()
        self.foucustime += Int(countTime)
    }
    
    fileprivate func nextStatus(_ start: Bool = true) {
        let group = self.method.groups[self.groupIndex]
        
        // 每次时间到了 itemIndex + 1
        // 如果 itemIndex 加一后，已经超过 group 中 item 的 count，那么 groupRepeatTimes + 1
        // 如果 groupRepeatTimes 超过了 group 的 repeat count 那么 groupIndex + 1
        // 如果 groupIndex 超过了 method 中 group count 那么 methodRepeatTimes + 1, 并且 index 都恢复为最初状态
        if start {
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
        } else {
            self.itemIndex = self.itemIndex < 0 ? 0 : self.itemIndex
        }
        
        let item = group.items[self.itemIndex]
        
        if self.methodRepeatTimes > 0 {
            self.loopLabel.text = "\(self.methodRepeatTimes) " + method.timeMethodAliase
        }
        self.titleLabel.text = item.name
//        #if debug
//            let countTime = TimeInterval(5)
//        #else
            let countTime = TimeInterval(item.interval * 60)
//        #endif
        
        self.countLabel.setCountDownTime(countTime)
        
        if start {
            self.countLabel.start()
            self.circleView.setCircleDuration(duration: countTime)
            self.circleView
                .start(completed: Int(countTime), created: Int(countTime), reset: true)
        } else {
            return
        }
    }
    
    func finish() {
        // 如果选择此工作法，那么使用次数 + 1
        RealmManager.shared.updateObject { [unowned self] in
            self.method.useTimes += 1
            self.task.foucustime += self.foucustime
        }
        
        self.countLabel.pause()
        self.moveOut()
    }
}
