//
//  HomeViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

typealias TaskSettingBlock = (String) -> Void

class HomeViewController: BaseViewController {
    // MARK: - props
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var newTaskButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
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
    
    fileprivate var finishTasks: Results<Task>?
    fileprivate var runningTasks: Results<Task>?
    
    fileprivate var finishToken: RealmSwift.NotificationToken?
    fileprivate var runningToken: RealmSwift.NotificationToken?
    
    fileprivate var isFullScreenSize = false
    fileprivate var selectedIndex: IndexPath? = nil
    
    fileprivate var timer: SecondTimer?
    fileprivate var repeaterManager = RepeaterManager()
    fileprivate let wormhole = MMWormhole.init(applicationGroupIdentifier: GroupIdentifier,
                                               optionalDirectory: nil)
    
    fileprivate var toViewControllerAnimationType = 0
    
    fileprivate weak var newTaskVC: NewTaskViewController? = nil
    
    // MARK: - life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        isFullScreenSize = AppUserDefault().readBool(kIsFullScreenSizeKey)
        
        self.configMainUI()
        self.initializeControl()
        self.configMainButton()
        
        self.finishTasks = RealmManager.shareManager.queryTodayTaskList(finished: true)
        self.runningTasks = RealmManager.shareManager.queryTodayTaskList(finished: false)
        self.realmNoticationToken()
        self.addNotification()
        
        self.initTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.delegate = nil
        guard let indexPath = self.selectedIndex else { return }
        self.taskTableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        finishToken?.stop()
        runningToken?.stop()
        NotificationCenter.default.removeObserver(self)
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
        self.tagButton.buttonColor(colors)
        self.searchButton.backgroundColor = colors.mainGreenColor
        
        let coffeeIcon = FAKFontAwesome.coffeeIcon(withSize: 60)
        coffeeIcon?.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.emptyCoffeeLabel.attributedText = coffeeIcon?.attributedString()
        
        let iconSize: CGFloat = 20
        self.settingButton.createIconButton(iconSize: iconSize, imageSize: iconSize,
                                            icon: "fa-cog", color: colors.mainGreenColor,
                                            status: .normal)
        
        self.newTaskButton.createIconButton(iconSize: 50, imageSize: 70,
                                            icon: "fa-plus", color: colors.mainGreenColor,
                                            status: .normal)
        
        self.calendarButton.createIconButton(iconSize: iconSize, imageSize: iconSize,
                                             icon: "fa-calendar", color: colors.mainGreenColor,
                                             status: .normal)
        
        self.tagButton.createIconButton(iconSize: iconSize, imageSize: iconSize,
                                        icon: "fa-tag", color: colors.mainGreenColor,
                                        status: .normal)
        
        self.searchButton.createIconButton(iconSize: iconSize, imageSize: iconSize,
                                           icon: "fa-search", color: colors.cloudColor,
                                           status: .normal)
        
        self.searchButton.tintColor = colors.mainGreenColor
        
        self.configFullSizeButton(colors)
        
        self.taskTableView.reloadData()
    }
    
    fileprivate func configFullSizeButton(_ colors: Colors) {
        if self.isFullScreenSize {
            self.fullScreenButton.createIconButton(iconSize: 20, imageSize: 20, icon: "fa-compress",
                                                   color: colors.mainGreenColor, status: .normal)
        } else {
            self.fullScreenButton.createIconButton(iconSize: 20, imageSize: 20, icon: "fa-expand",
                                                   color: colors.mainGreenColor, status: .normal)
        }
    }
    
    fileprivate func initializeControl() {
        self.taskTableView.tableFooterView = UIView()
        
        self.cardView.addShadow()
        self.newTaskButton.addShadow()
        self.settingButton.addShadow()
        self.fullScreenButton.addShadow()
        self.calendarButton.addShadow()
        self.tagButton.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        if #available(iOS 9, *) {
            self.taskTableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        self.statusSegment.setTitle(Localized("progess"), forSegmentAt: 0)
        self.statusSegment.setTitle(Localized("finished"), forSegmentAt: 1)
        self.statusSegment.addTarget(self, action: #selector(self.segmentValueChangeAction(_:)), for: .valueChanged)
        
        taskTableView.register(TaskTableViewCell.nib, forCellReuseIdentifier: TaskTableViewCell.reuseId)
        
        self.currentDateLabel.text = (Date() as NSDate).formattedDate(with: .medium)
        self.emptyHintLabel.text = Localized("emptyTask")
        
        self.newTaskButton.addTarget(self, action:  #selector(self.newTaskAction), for: .touchUpInside)
        
        self.calendarButton.addTarget(self, action: #selector(self.calendarAction), for: .touchUpInside)
        
        self.fullScreenButton.addTarget(self, action: #selector(self.switchScreenAction), for: .touchUpInside)
        
        self.settingButton.addTarget(self, action: #selector(self.settingAction), for: .touchUpInside)
        
        self.tagButton.addTarget(self, action: #selector(self.tagAction), for: .touchUpInside)
    }
    
    // 在app 进入前台的时候需要检查三种种状态
    // 第一种就是 today 中是否有勾选完成的任务
    // 然后就是 timer
    // 最后就是 new day 处理
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil,
            queue: OperationQueue.main) { [unowned self] notification in
                
                self.handelTodayFinish()
                
                if self.repeaterManager.isNewDay() {
                    self.handleNewDay()
                    self.handleUpdateTodayGroup()
                }
                self.timer?.resume()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil,
            queue: OperationQueue.main) { [unowned self] notification in
                self.timer?.suspend()
                self.newTaskVC?.removeFromParentViewController()
        }
    }
    
    fileprivate func initTimer() {
        self.timer = SecondTimer(handle: { [weak self] () -> Void in
            guard let ws = self else { return }
            if ws.repeaterManager.isNewDay() {
//                if NSDate().isMorning() {
//                    HUD.sharedHUD.showOnce(Localized("newDay"))
//                }
                ws.handleNewDay()
            }
            ws.taskTableView.reloadData()
            })
        
        self.timer?.start()
    }
    
    fileprivate func handelTodayFinish() {
        guard let group = GroupUserDefault() else { return }
        let finishTasks = group.getAllFinishTask()
        
        let manager = RealmManager.shareManager
        
        let _ = finishTasks.map({ (taskInfoArr) -> Void in
            let uuid = taskInfoArr[GroupTaskUUIDIndex]
            let dateString = taskInfoArr[GroupTaskFinishDateIndex]
            let date = dateString.dateFromString(UUIDFormat)
            guard let task = self.runningTasks?.filter({ (t) -> Bool in
                t.uuid == uuid
            }).first else { return }
            
            manager.updateTaskStatus(task, status: kTaskFinish, updateDate: date)
        })
        
        group.clearTaskFinish()
    }
    
    // 当 task list 为空的时候展示对应的 hint
    fileprivate func showEmptyHint(_ show: Bool) {
        self.emptyHintLabel.isHidden = !show
        self.emptyCoffeeLabel.isHidden = !show
        
        if self.inRunningTasksTable() {
            self.emptyHintLabel.text = Localized("emptyTask")
        } else {
            self.emptyHintLabel.text = Localized("emptyFinishTask")
        }
    }
    
    fileprivate func configMainButton() {
        self.settingButton.layer.cornerRadius = 16
        self.fullScreenButton.layer.cornerRadius = 16
        self.calendarButton.layer.cornerRadius = 16
        self.tagButton.layer.cornerRadius = 16
        
        doSwitchScreen(false)
    }
    
    fileprivate func realmNoticationToken() {
        finishToken = finishTasks?.addNotificationBlock(block: { [unowned self] (changes: RealmCollectionChange) in
            if self.statusSegment.selectedSegmentIndex == 0 {
                return
            }
            switch changes {
            case .Initial:
                self.taskTableView.reloadData()
                
            case .Update(_, let deletions, let insertions, let modifications):
                self.handleUpdate(deletions, insertions: insertions, modifications: modifications)
                self.handleUpdateTodayGroup()
                
            case .Error(let error):
                debugPrint("finishToken realmNoticationToken error = \(error)")
                break
            }
            })
        
        runningToken = runningTasks?.addNotificationBlock(block: { [unowned self] (changes: RealmCollectionChange) in
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
                debugPrint("runningToken realmNoticationToken error = \(error)")
                break
            }
            
            })
    }
    
    fileprivate func handleUpdate(_ deletions: [Int], insertions: [Int], modifications: [Int]) {
        self.taskTableView.beginUpdates()
        if insertions.count > 0 {
            self.taskTableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        
        if modifications.count > 0 {
            self.taskTableView.reloadRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        
        if deletions.count > 0 {
            self.taskTableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        self.taskTableView.endUpdates()
    }
    
    // 当新的一天到来的时候调用， 来处理新的数据
    // TODO - handle due today
    func handleNewDay() {
        let shareManager = RealmManager.shareManager
        self.finishTasks = shareManager.queryTodayTaskList(finished: true)
        self.runningTasks = shareManager.queryTodayTaskList(finished: false)
        self.realmNoticationToken()
        
        self.handleUpdateTodayGroup()
        if !AppUserDefault().readBool(kCloseDueTodayKey) {
            self.handleMoveTaskToToday()
        }
    }
    
    fileprivate func handleMoveTaskToToday() {
        let shareManager = RealmManager.shareManager
        let s = shareManager.queryTaskCount(date: NSDate().subtractingDays(1) as NSDate)
        if (s.created - s.complete) > 0 {
            let alert = UIAlertController(title: nil, message: Localized("detailIncomplete"), preferredStyle: .alert)
            let moveAction = UIAlertAction(title: Localized("move"), style: .default) { (action) in
                shareManager.moveYesterdayTaskToToday()
            }
            let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(moveAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func handleUpdateTodayGroup() {
        guard let group = GroupUserDefault(),
            let tasks = self.runningTasks else {
                return
        }
        group.writeTasks(tasks)
        
        self.wormhole.passMessageObject(nil, identifier: WormholeNewTaskIdentifier)
    }
    
    // MARK: - actions
    func settingAction() {
        let notifications = UIApplication.shared.scheduledLocalNotifications
        print(notifications)
        
        let settingVC = SettingsViewController()
        self.navigationController?.delegate = self
        self.toViewControllerAnimationType = 0
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    func switchScreenAction() {
        print(RealmManager.shareManager.queryAll(clz: Repeater.self))
        UIApplication.shared.cancelAllLocalNotifications()
        doSwitchScreen(true)
    }
    
    func calendarAction() {
        let calendarVC = CalendarViewController()
        self.navigationController?.delegate = self
        self.toViewControllerAnimationType = 0
        self.navigationController?.pushViewController(calendarVC, animated: true)
    }
    
    func tagAction() {
        let tagVC = TagViewController()
        self.navigationController?.pushViewController(tagVC, animated: true)
    }
    
    fileprivate func doSwitchScreen(_ animation: Bool) {
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
                UIView.animate(withDuration: kNormalAnimationDuration, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                    self.currentDateLabel.alpha = 1
                    self.searchButton.alpha = 1
                    })
            } else {
                self.newTaskButton.layer.cornerRadius = 35
                self.currentDateLabel.alpha = 1
                self.searchButton.alpha = 1
            }
        } else {
            self.cardViewLeftConstraint.constant = 5
            self.cardViewRightConstraint.constant = 5
            self.cardViewBottomConstraint.constant = 5
            self.cardViewTopConstraint.constant = 25
            self.addTaskWidthConstraint.constant = 40
            self.addTaskHeightConstraint.constant = 40
            self.addTaskBottomConstraint.constant = 5
            if (animation) {
                self.newTaskButton.addCornerRadiusAnimation(40, to: 20, duration: kNormalAnimationDuration)
                UIView.animate(withDuration: kNormalAnimationDuration, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                    self.currentDateLabel.alpha = 0
                    self.searchButton.alpha = 0
                    })
            } else {
                self.newTaskButton.layer.cornerRadius = 20
                self.currentDateLabel.alpha = 0
                self.searchButton.alpha = 0
            }
        }
        
        configFullSizeButton(Colors())
        AppUserDefault().write(kIsFullScreenSizeKey, value: isFullScreenSize)
        isFullScreenSize = !isFullScreenSize
    }
    
    func newTaskAction() {
        let newTaskVC = NewTaskViewController()
        self.addChildViewController(newTaskVC)
        newTaskVC.didMove(toParentViewController: self)
        
        self.newTaskVC = newTaskVC
    }
    
    func segmentValueChangeAction(_ seg: UISegmentedControl) {
        self.taskTableView.reloadData()
    }
    
    // 从today 点击一个 task 进入 detail
    func enterTaskFromToday(_ uuid: String) {
        guard let t = self.runningTasks?.filter({ (task) -> Bool in
            task.uuid == uuid
        }).first else { return }
        
        // 系统消息的时候，并且系统消息type 中有回调的block， 那么执行
        if let actionContent = TaskManager().parseTaskToDoText(t.taskToDo),
            let action = actionContent.type.actionBlockWithType() {
            dispatch_delay(0.1, closure: {
                action(actionContent.urlSchemeInfo)
            })
        } else {
            self.enterTask(t, canChange: true)
        }
    }
}

// MARK: - table view
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.inRunningTasksTable() {
            showEmptyHint(self.runningTasks?.count ?? 0 <= 0)
            return self.runningTasks?.count ?? 0
        } else {
            showEmptyHint(self.finishTasks?.count ?? 0 <= 0)
            return self.finishTasks?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        
        let task: Task?
        let canChange: Bool
        if inRunningTasksTable() {
            task = self.runningTasks?[indexPath.row]
            canChange = true
        } else {
            task = self.finishTasks?[indexPath.row]
            canChange = false
        }
        
        guard let t = task else { return }
        self.enterTask(t, canChange: canChange)
    }
    
    fileprivate func enterTask(_ task: Task, canChange: Bool) {
        let taskVC = TaskDetailViewController(task: task, canChange: canChange)
        self.navigationController?.delegate = self
        self.toViewControllerAnimationType = 0
        self.navigationController?.pushViewController(taskVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseId, for: indexPath) as! TaskTableViewCell
        
        var task: Task?
        if self.inRunningTasksTable() {
            task = self.runningTasks?[indexPath.row]
        } else {
            task = self.finishTasks?[indexPath.row]
        }
        
        if let t = task {
            cell.configCellUse(t)
            
            cell.settingBlock = { [unowned self] (uuid) -> Void in
                self.showSettings(taskUUID: uuid)
            }
        }
        return cell
    }
    
    fileprivate func inRunningTasksTable() -> Bool {
        return self.statusSegment.selectedSegmentIndex == 0
    }
    
    fileprivate func showSettings(taskUUID: String) {
        guard  let task = RealmManager.shareManager.queryTask(taskUUID) else {
            return
        }
        
        let alert = UIAlertController(title: task.getNormalDisplayTitle(), message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: Localized("deleteTask"), style: .destructive) { (action) in
            RealmManager.shareManager.deleteTask(task)
        }
        alert.addAction(deleteAction)
        
        if let _ = task.notifyDate {
            let deleteReminderAction = UIAlertAction(title: Localized("deleteReminder"), style: .default, handler: { (action) in
                RealmManager.shareManager.deleteTaskReminder(task)
                
            })
            alert.addAction(deleteReminderAction)
        }
        
        let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate
extension HomeViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch toViewControllerAnimationType {
        case 0:
            let animation = LayerTransitioningAnimation()
            animation.reverse = operation == UINavigationControllerOperation.pop
            return animation
            
        default:
            let animation = CircleTransitionAnimator()
            animation.reverse = operation == UINavigationControllerOperation.pop
            animation.buttonFrame = self.calendarButton.frame
            return animation
        }
        
    }
}
