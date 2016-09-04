//
//  HomeViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: BaseViewController {
    // MARK: - props
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var newTaskButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var emptyHintLabel: UILabel!
    @IBOutlet weak var emptyCoffeeLabel: UILabel!
    
    @IBOutlet weak var cardViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    
    private var finishTasks: Results<Task>?
    private var runningTasks: Results<Task>?
    
    private var finishToken: RealmSwift.NotificationToken?
    private var runningToken: RealmSwift.NotificationToken?
    
    private let animation = LayerTransitioningAnimation()
    
    private var isFullScreenSize = false
    private var selectedIndex: NSIndexPath? = nil
    
    private var timer: SecondTimer?
    private var repeaterManager = RepeaterManager()
    private let wormhole = MMWormhole.init(applicationGroupIdentifier: group, optionalDirectory: nil)
    
    // MARK: - life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        isFullScreenSize = UserDefault().readBool(kIsFullScreenSizeKey)
        
        self.configMainUI()
        self.initializeControl()
        self.configMainButton()
        
        self.finishTasks = RealmManager.shareManager.queryTodayTaskList(finished: true)
        self.runningTasks = RealmManager.shareManager.queryTodayTaskList(finished: false)
        self.realmNoticationToken()
        self.addNotification()
        
        self.initTimer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let indexPath = self.selectedIndex else { return }
        self.taskTableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.taskTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.selectedIndex = nil
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        finishToken?.stop()
        runningToken?.stop()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ui config
    override func configMainUI() {
        let colors = Colors()
        
        self.navigationController?.view.backgroundColor = colors.mainGreenColor
        self.view.backgroundColor = colors.mainGreenColor
        self.currentDateLabel.textColor = colors.cloudColor
        self.taskTableView.backgroundColor = colors.cloudColor
        self.taskTableView.separatorColor = colors.separatorColor
        self.cardView.backgroundColor = colors.cloudColor
        
        self.statusSegment.tintColor = colors.mainGreenColor
        self.emptyHintLabel.textColor = colors.secondaryTextColor
        
        self.settingButton.buttonColor(colors)
        self.newTaskButton.buttonColor(colors)
        self.calendarButton.buttonColor(colors)
        self.fullScreenButton.buttonColor(colors)
        
        let coffeeIcon = FAKFontAwesome.coffeeIconWithSize(60)
        coffeeIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.emptyCoffeeLabel.attributedText = coffeeIcon.attributedString()
        
        let cogIcon = FAKFontAwesome.cogIconWithSize(20)
        cogIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.settingButton.setAttributedTitle(cogIcon.attributedString(), forState: .Normal)
        
        let newIcon = FAKFontAwesome.plusIconWithSize(50)
        newIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let newImage = newIcon.imageWithSize(CGSize(width: 70, height: 70))
        self.newTaskButton.setImage(newImage, forState: .Normal)
        
        let calendarIcon = FAKFontAwesome.calendarIconWithSize(20)
        calendarIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.calendarButton.setAttributedTitle(calendarIcon.attributedString(), forState: .Normal)
        
        self.configFullSizeButton(colors)
    }
    
    private func configFullSizeButton(colors: Colors) {
        if isFullScreenSize {
            let compressIcon = FAKFontAwesome.compressIconWithSize(20)
            compressIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
            let compressImage = compressIcon.imageWithSize(CGSize(width: 20, height: 20))
            self.fullScreenButton.setImage(compressImage, forState: .Normal)
        } else {
            let expandIcon = FAKFontAwesome.expandIconWithSize(20)
            expandIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
            let expandImage = expandIcon.imageWithSize(CGSize(width: 20, height: 20))
            self.fullScreenButton.setImage(expandImage, forState: .Normal)
        }
    }
    
    private func initializeControl() {
        self.taskTableView.tableFooterView = UIView()
        
        self.cardView.addShadow()
        self.newTaskButton.addShadow()
        self.settingButton.addShadow()
        self.fullScreenButton.addShadow()
        self.calendarButton.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        if #available(iOS 9, *) {
            self.taskTableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        self.statusSegment.setTitle(Localized("progess"), forSegmentAtIndex: 0)
        self.statusSegment.setTitle(Localized("finished"), forSegmentAtIndex: 1)
        self.statusSegment.addTarget(self, action: #selector(self.segmentValueChangeAction(_:)), forControlEvents: .ValueChanged)
        
        taskTableView.registerNib(TaskTableViewCell.nib, forCellReuseIdentifier: TaskTableViewCell.reuseId)
        
        self.currentDateLabel.text = NSDate().formattedDateWithStyle(.MediumStyle)
        self.emptyHintLabel.text = Localized("emptyTask")
        
        self.newTaskButton.addTarget(self, action:  #selector(self.newTaskAction), forControlEvents: .TouchUpInside)
        
        self.calendarButton.addTarget(self, action: #selector(self.calendarAction), forControlEvents: .TouchUpInside)
        
        self.fullScreenButton.addTarget(self, action: #selector(self.switchScreenAction), forControlEvents: .TouchUpInside)
        
        self.settingButton.addTarget(self, action: #selector(self.setting), forControlEvents: .TouchUpInside)
    }
    
    // 在app 进入前台的时候需要检查两种状态
    // 第一种就是 timer 
    // 然后就是 today 中是否有勾选完成的任务
    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIApplicationDidBecomeActiveNotification, object: nil,
            queue: NSOperationQueue.mainQueue()) { [unowned self] notification in
                self.timer?.resume()
                
                guard let group = GroupUserDefault() else { return }
                let finishTasks = group.getAllFinishTask()
                
                let manager = RealmManager.shareManager
      
                let _ = finishTasks.map({ (taskInfoArr) -> Void in
                    let uuid = taskInfoArr[GroupUserDefault.GroupTaskUUIDIndex]
                    let dateString = taskInfoArr[GroupUserDefault.GroupTaskFinishDateIndex]
                    let date = dateString.dateFromString(uuidFormat)
                    guard let task = self.runningTasks?.filter({ (t) -> Bool in
                        t.uuid == uuid
                    }).first else { return }
                    
                    manager.updateTaskStatus(task, status: kTaskFinish, updateDate: date)
                })
                
                group.clearTaskFinish()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIApplicationDidEnterBackgroundNotification, object: nil,
            queue: NSOperationQueue.mainQueue()) { [unowned self] notification in
                self.timer?.suspend()
        }
    }
    
    private func initTimer() {
        self.timer = SecondTimer(handle: { [weak self] () -> Void in
            guard let ws = self else { return }
            if ws.repeaterManager.isNewDay() {
                HUD.sharedHUD.showOnce(Localized("newDay"))
                ws.handleNewDay()
            }
            ws.taskTableView.reloadData()
            })
        
        self.timer?.start()
    }
    
    // 当 task list 为空的时候展示对应的 hint
    private func showEmptyHint(show: Bool) {
        self.emptyHintLabel.hidden = !show
        self.emptyCoffeeLabel.hidden = !show
        
        if self.inRunningTasksTable() {
            self.emptyHintLabel.text = Localized("emptyTask")
        } else {
            self.emptyHintLabel.text = Localized("emptyFinishTask")
        }
    }
    
    private func configMainButton() {
        self.settingButton.layer.cornerRadius = 16
        self.fullScreenButton.layer.cornerRadius = 16
        self.calendarButton.layer.cornerRadius = 16
        
        doSwitchScreen(false)
    }
    
    private func realmNoticationToken() {
        finishToken = finishTasks?.addNotificationBlock({ [unowned self] (changes: RealmCollectionChange) in
            if self.statusSegment.selectedSegmentIndex == 0 {
                return
            }
            switch changes {
            case .Initial:
                self.taskTableView.reloadData()
                
            case .Update(_, let deletions, let insertions, let modifications):
                self.handleUpdate(deletions, insertions: insertions, modifications: modifications)
                
            case .Error(let error):
                print(error)
                break
            }
            })
        
        runningToken = runningTasks?.addNotificationBlock({ [unowned self] (changes: RealmCollectionChange) in
            if self.statusSegment.selectedSegmentIndex == 1 {
                return
            }
            switch changes {
            case .Initial:
                self.taskTableView.reloadData()
                self.handleUpdateTodayGroup()
                
            case .Update(_, let deletions, let insertions, let modifications):
                self.handleUpdate(deletions, insertions: insertions, modifications: modifications)
                self.handleUpdateTodayGroup()
                
                guard let deletion = deletions.first,
                    let selectedRow = self.selectedIndex?.row else { break }
                if deletion == selectedRow {
                    self.selectedIndex = nil
                }
                
            case .Error(let error):
                debugPrint(error)
                break
            }
            
            })
    }
    
    private func handleUpdate(deletions: [Int], insertions: [Int], modifications: [Int]) {
        self.taskTableView.beginUpdates()
        if insertions.count > 0 {
            self.taskTableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
        }
        
        if modifications.count > 0 {
            self.taskTableView.reloadRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
        }
        
        if deletions.count > 0 {
            self.taskTableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
        }
        self.taskTableView.endUpdates()
    }
    
    // 当新的一天到来的时候调用， 来处理新的数据
    func handleNewDay() {
        self.finishTasks = RealmManager.shareManager.queryTodayTaskList(finished: true)
        self.runningTasks = RealmManager.shareManager.queryTodayTaskList(finished: false)
        
        handleUpdateTodayGroup()
    }
    
    private func handleUpdateTodayGroup() {
        guard let group = GroupUserDefault(),
            let tasks = self.runningTasks else {
                return
        }
        group.writeTasks(tasks)
        wormhole.passMessageObject(nil, identifier: wormholeIdentifier)
    }
    
    // MARK: - actions
    func setting() {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        print(notifications)
        
    }
    
    func switchScreenAction() {
        doSwitchScreen(true)
    }
    
    func calendarAction() {
        //        print(RealmManager.shareManager.queryAll(Subtask.self))
        print(RealmManager.shareManager.queryAll(Repeater.self))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    private func doSwitchScreen(animation: Bool) {
        if !isFullScreenSize {
            self.cardViewLeftConstraint.constant = 20
            self.cardViewRightConstraint.constant = 20
            self.cardViewBottomConstraint.constant = 15
            self.cardViewTopConstraint.constant = 70
            self.addTaskWidthConstraint.constant = 70
            self.addTaskHeightConstraint.constant = 70
            self.addTaskBottomConstraint.constant = 10
            if (animation) {
                self.newTaskButton.addCornerRadiusAnimation(16, to: 35, duration: kNormalAnimationDuration)
                UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                    self.currentDateLabel.alpha = 1
                    })
            } else {
                self.newTaskButton.layer.cornerRadius = 35
                self.currentDateLabel.alpha = 1
            }
        } else {
            self.cardViewLeftConstraint.constant = 5
            self.cardViewRightConstraint.constant = 5
            self.cardViewBottomConstraint.constant = 10
            self.cardViewTopConstraint.constant = 25
            self.addTaskWidthConstraint.constant = 40
            self.addTaskHeightConstraint.constant = 40
            self.addTaskBottomConstraint.constant = 10
            if (animation) {
                self.newTaskButton.addCornerRadiusAnimation(40, to: 20, duration: kNormalAnimationDuration)
                UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                    self.currentDateLabel.alpha = 0
                    })
            } else {
                self.newTaskButton.layer.cornerRadius = 20
                self.currentDateLabel.alpha = 0
            }
        }
        
        configFullSizeButton(Colors())
        UserDefault().write(kIsFullScreenSizeKey, value: isFullScreenSize)
        isFullScreenSize = !isFullScreenSize
    }
    
    func newTaskAction() {
        let newTaskVC = NewTaskViewController()
        self.addChildViewController(newTaskVC)
        newTaskVC.didMoveToParentViewController(self)
    }
    
    func segmentValueChangeAction(seg: UISegmentedControl) {
        self.taskTableView.reloadData()
    }
}

// MARK: - table view
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.inRunningTasksTable() {
            showEmptyHint(self.runningTasks?.count ?? 0 <= 0)
            return self.runningTasks?.count ?? 0
        } else {
            showEmptyHint(self.finishTasks?.count ?? 0 <= 0)
            return self.finishTasks?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        
        let task: Task?
        let change: Bool
        if inRunningTasksTable() {
            task = self.runningTasks?[indexPath.row]
            change = true
        } else {
            task = self.finishTasks?[indexPath.row]
            change = false
        }
        
        guard let t = task else { return }
        let taskVC = TaskDetailViewController(task: t, change: change)
        self.navigationController?.delegate = self
        self.navigationController?.pushViewController(taskVC, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TaskTableViewCell.reuseId, forIndexPath: indexPath) as! TaskTableViewCell
        
        var task: Task?
        if self.inRunningTasksTable() {
            task = self.runningTasks?[indexPath.row]
        } else {
            task = self.finishTasks?[indexPath.row]
        }
        
        if let t = task {
            cell.configCellUse(t)
        }
        return cell
    }
    
    private func inRunningTasksTable() -> Bool {
        return self.statusSegment.selectedSegmentIndex == 0
    }
}

// MARK: - UINavigationControllerDelegate
extension HomeViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animation.reverse = operation == UINavigationControllerOperation.Pop
        return animation
    }
}
