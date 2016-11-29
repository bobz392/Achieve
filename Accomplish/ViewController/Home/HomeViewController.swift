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
    @IBOutlet weak var statusSlideSegment: TwicketSegmentedControl!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var newTaskButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var taskTableView: HomeTableView!
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
    // 当前的 转场动画类型
    fileprivate var toViewControllerAnimationType = 0
    //
    fileprivate weak var newTaskVC: NewTaskViewController? = nil
    //
    fileprivate var icloudManager = CloudKitManager()
    fileprivate weak var timeManagementView: TimeManagementView? = nil
    
    // MARK: - life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let appDefault = AppUserDefault()
        self.isFullScreenSize = appDefault.readBool(kUserDefaultFullScreenKey)
        
        self.configMainUI()
        self.initializeControl()
        self.configMainButton()
        
        self.queryTodayTask()
        self.addNotification()
        self.initTimer()
        
        self.icloudManager.asyncFromCloudIfNeeded()
        if appDefault.readBool(kUserDefaultBuildInTMKey) != true {
            BuildInTimeMethodCreator().pomodoroCreator()
            appDefault.write(kUserDefaultBuildInTMKey, value: true)
        }
        //        TestManager().addAppStoreData()
        
        self.checkTimeMethodRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.taskTableView.homeRefreshControl.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.delegate = nil
        guard let indexPath = self.selectedIndex else { return }
        self.taskTableView.deselectRow(at: indexPath, animated: true)
        self.taskTableView.reloadRows(at: [indexPath], with: .none)
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
        
        self.statusSlideSegment.sliderBackgroundColor = colors.mainGreenColor
        self.statusSlideSegment.segmentsBackgroundColor = UIColor.white
        self.statusSlideSegment.clearView()
        
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
        //fa-cog
        self.settingButton.createIconButton(iconSize: iconSize, icon: "fa-cog",
                                            color: colors.mainGreenColor, status: .normal)
        
        //fa-plus
        self.newTaskButton.createIconButton(iconSize: 40, icon: "fa-plus",
                                            color: colors.mainGreenColor, status: .normal)
        //fa-calendar
        self.calendarButton.createIconButton(iconSize: iconSize, icon: "fa-calendar",
                                             color: colors.mainGreenColor, status: .normal)
        //fa-tag
        self.tagButton.createIconButton(iconSize: iconSize, icon: "fa-tag",
                                        color: colors.mainGreenColor, status: .normal)
        
        //fa-search
        self.searchButton.createIconButton(iconSize: 24, icon: "fa-search",
                                           color: colors.cloudColor, status: .normal)
        
        self.searchButton.tintColor = colors.mainGreenColor
        
        self.configFullSizeButton(colors)
        self.taskTableView.reloadData()
        
        self.taskTableView.homeRefreshControl.tintColor = colors.mainGreenColor
        self.taskTableView.homeRefreshControl.attributedTitle =
            NSAttributedString(string: Localized("search"),
                               attributes: [NSForegroundColorAttributeName : Colors().mainGreenColor])
    }
    
    fileprivate func configFullSizeButton(_ colors: Colors) {
        
        let iconSize: CGFloat = 20
        //fa-compress
        if self.isFullScreenSize {
            self.fullScreenButton.createIconButton(iconSize: iconSize, icon: "fa-compress",
                                                   color: colors.mainGreenColor, status: .normal)
        } else {
            //fa-expand
            self.fullScreenButton.createIconButton(iconSize: iconSize, icon: "fa-expand",
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
        
        let segTitles = [Localized("progess"), Localized("finished")]
        self.statusSlideSegment.setSegmentItems(segTitles)
        self.statusSlideSegment.delegate = self
        
        self.taskTableView.register(TaskTableViewCell.nib, forCellReuseIdentifier: TaskTableViewCell.reuseId)
        
        self.currentDateLabel.text = NSDate().formattedDate(with: .medium)
        self.emptyHintLabel.text = Localized("emptyTask")
        
        self.newTaskButton.addTarget(self, action:  #selector(self.newTaskAction),
                                     for: .touchUpInside)
        
        self.calendarButton.addTarget(self, action: #selector(self.calendarAction),
                                      for: .touchUpInside)
        
        self.fullScreenButton.addTarget(self, action: #selector(self.switchScreenAction),
                                        for: .touchUpInside)
        
        self.settingButton.addTarget(self, action: #selector(self.settingAction),
                                     for: .touchUpInside)
        
        self.tagButton.addTarget(self, action: #selector(self.tagAction), for: .touchUpInside)
        
        self.searchButton.addTarget(self, action: #selector(self.searchAction),
                                    for: .touchUpInside)
        
        self.taskTableView.getCurrentIndex = { [unowned self] () -> Int in
            return self.statusSlideSegment.selectedSegmentIndex
        }
        
        self.taskTableView.changeCallBack = { [unowned self] (changeIndex) -> Void in
            self.statusSlideSegment.move(to: changeIndex)
            self.taskTableView.reloadData()
        }
        
        self.taskTableView.searchCallBack = { [unowned self] () -> Void in
            self.searchAction()
        }
    }
    
    /**
     - 在app 进入前台的时候需要检查三种种状态
     - 第一种就是 today 中是否有勾选完成的任务
     - 然后就是 timer
     - 最后就是 new day 处理
     */
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil,
            queue: OperationQueue.main) { [unowned self] notification in
                self.handelTodayExtensionFinish()
                self.checkNewDay()
                self.timer?.resume()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil,
            queue: OperationQueue.main) { [unowned self] notification in
                self.timer?.suspend()
                self.newTaskVC?.removeFromParentViewController()
        }
    }
    
    /**
     检查上次退出 app 的时候是否还有在运行中的 time method
     */
    fileprivate func checkTimeMethodRunning() {
        // 如果 time manager view 还存在则之前未退出 app， 则直接交给 view 内部通知处理
        if let _ = self.timeManagementView { return }
        let app = AppUserDefault()
        guard let uuid = app.readString(kUserDefaultTMUUIDKey),
            let taskUUID = app.readString(kUserDefaultTMTaskUUID),
            let task = RealmManager.shared.queryTask(taskUUID),
            let details = app.readArray(kUserDefaultTMDetailsKey) as? Array<Int>,
            let tm = RealmManager.shared.queryTimeMethod(uuid: uuid) else { return }
        
        if details.count == 4 {
            guard let view = TimeManagementView.loadNib(self, method: tm, task: task) else { return }
            self.timeManagementView = view
            view.moveIn(view: self.view)
            view.configTimeManager(details: details)
        }
    }
    
    /**
     在进入 app 的时候检查是否是新的一天
     */
    fileprivate func checkNewDay() {
        if self.repeaterManager.isNewDay() {
            self.handleNewDay()
            self.selectedIndex = nil
            self.currentDateLabel.text = NSDate().formattedDate(with: .medium)
            
            self.checkNeedMoveUnfinishTaskToday()
        }
    }
    
    fileprivate func initTimer() {
        self.timer = SecondTimer(handle: { [weak self] () -> Void in
            guard let ws = self else { return }
            dispatch_async_main {
                ws.checkNewDay()
                ws.taskTableView.reloadData()
            }
        })
        
        self.timer?.start()
    }
    
    /**
     处理 today extension 中完成的任务
     */
    fileprivate func handelTodayExtensionFinish() {
        guard let group = GroupUserDefault() else { return }
        let finishTasks = group.getAllFinishTask()
        
        let manager = RealmManager.shared
        
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
        
        self.doSwitchScreen(false)
    }
    
    fileprivate func realmNoticationToken() {
        self.finishToken = finishTasks?.addNotificationBlock({ [unowned self] (changes: RealmCollectionChange) in
            if self.statusSlideSegment.selectedSegmentIndex == kRunningSegmentIndex {
                return
            }
            switch changes {
            case .initial(_):
                self.taskTableView.reloadData()
                
            case .update(_, let deletions, let insertions, let modifications):
                self.handleUpdate(deletions, insertions: insertions, modifications: modifications)
                self.handleUpdateTodayGroup()
                
            case .error(let error):
                Logger.log("finishToken realmNoticationToken error = \(error)")
                break
            }
        })
        
        self.runningToken = runningTasks?.addNotificationBlock({ [unowned self] (changes: RealmCollectionChange) in
            if self.statusSlideSegment.selectedSegmentIndex == kFinishSegmentIndex {
                return
            }
            switch changes {
            case .initial(_):
                self.taskTableView.reloadData()
                self.handleUpdateTodayGroup()
                
            case .update(_, let deletions, let insertions, let modifications):
                self.handleUpdate(deletions, insertions: insertions, modifications: modifications)
                self.handleUpdateTodayGroup()
                
                guard let deletion = deletions.first,
                    let selectedRow = self.selectedIndex?.row else { break }
                if deletion == selectedRow {
                    self.selectedIndex = nil
                }
                
            case .error(let error):
                Logger.log("runningToken realmNoticationToken error = \(error)")
                break
            }
            
        })
    }
    
    fileprivate func handleUpdate(_ deletions: [Int], insertions: [Int], modifications: [Int]) {
        self.taskTableView.beginUpdates()
        if insertions.count > 0 {
            self.taskTableView
                .insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        
        if modifications.count > 0 {
            self.taskTableView
                .reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        
        if deletions.count > 0 {
            self.taskTableView
                .deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        self.taskTableView.endUpdates()
    }
    
    /**
     - 当新的一天到来的时候调用， 来处理新的数据
     - 首先查询今天的任务，可能是重复任务，可能是分配到今天的任务
     - 添加今天的任务到索引
     */
    func handleNewDay() {
        self.queryTodayTask()
        self.handleUpdateTodayGroup()
        if #available(iOS 9.0, *) {
            SpotlightManager().addDateTaskToIndex()
        }
    }
    
    /**
     如果开启的移动未完成的任务到今天
     */
    fileprivate func checkNeedMoveUnfinishTaskToday() {
        let appUD = AppUserDefault()
        if !appUD.readBool(kUserDefaultCloseDueTodayKey)
            && appUD.readBool(kUserDefaultMoveUnfinishTaskKey) {
            self.handleMoveUnfinishTaskToToday()
        } else {
            self.uploadToiCloud()
        }
        
        appUD.write(kUserDefaultMoveUnfinishTaskKey, value: false)
    }
    
    /**
     上传用户数据到iCloud
     -TODO 目前没有利用到 background fetch
     */
    fileprivate func uploadToiCloud() {
        self.icloudManager.iCloudEnable { [unowned self] (enable) in
            if enable {
                // 未上传的 checkIn 在这里全部上传
                let waitForUploadCheckIns = RealmManager.shared.waitForUploadCheckIns()
                for checkIn in waitForUploadCheckIns {
                    if let date = checkIn.checkInDate {
                        let taskCount = RealmManager.shared.queryTaskCount(date: date)
                        RealmManager.shared.updateObject {
                            checkIn.createdCount = taskCount.created
                            checkIn.completedCount = taskCount.completed
                        }
                        
                        self.icloudManager.uploadTasks(date: date)
                    }
                }
            } else {
                // 每周提示一次 如果用户未登陆iCloud
                if NSDate().weekday() == 1 {
                    HUD.shared.showOnce(Localized("icloud"))
                }
            }
        }
    }
    
    fileprivate func queryTodayTask(tagUUID: String? = nil) {
        let shareManager = RealmManager.shared
        let tagUUID: String? = tagUUID ?? AppUserDefault().readString(kUserDefaultCurrentTagUUIDKey)
        self.finishTasks = shareManager.queryTodayTaskList(finished: true, tagUUID: tagUUID)
        self.runningTasks = shareManager.queryTodayTaskList(finished: false, tagUUID: tagUUID)
        self.realmNoticationToken()
    }
    
    fileprivate func handleMoveUnfinishTaskToToday() {
        let shareManager = RealmManager.shared
        let movetasks = shareManager.hasUnfinishTaskMoveToday()
        if movetasks.count > 0 {
            let alert = UIAlertController(title: nil, message: Localized("detailIncomplete"), preferredStyle: .alert)
            let moveAction = UIAlertAction(title: Localized("move"), style: .default) { (action) in
                shareManager.moveYesterdayTaskToToday(movedtasks: movetasks)
                self.uploadToiCloud()
            }
            let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.uploadToiCloud()
            }
            
            alert.addAction(moveAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.uploadToiCloud()
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
    fileprivate func animationNavgationTo(vc: UIViewController) {
        self.navigationController?.delegate = self
        self.toViewControllerAnimationType = 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func settingAction() {
        self.animationNavgationTo(vc: SettingsViewController())
    }
    
    func switchScreenAction() {
        self.doSwitchScreen(true)
        //        CloudKitManager().fetchTestData()
        //        TestManager().addTestCheckIn()
        
        RealmManager.shared.queryAll(clz: TimeMethod.self)
        RealmManager.shared.queryAll(clz: TimeMethodItem.self)
        RealmManager.shared.queryAll(clz: TimeMethodGroup.self)
    }
    
    func calendarAction() {
        self.animationNavgationTo(vc: CalendarViewController())
    }
    
    func searchAction() {
        self.animationNavgationTo(vc: SearchViewController())
    }
    
    func tagAction() {
        let tagVC = TagViewController()
        tagVC.delegate = self
        self.animationNavgationTo(vc: tagVC)
        
        #if debug
            if #available(iOS 10.0, *) {
                LocalNotificationManager.shared.testClearUNNoitifcation()
                UIApplication.shared.applicationIconBadgeNumber = 0
            } else {
                UIApplication.shared.cancelAllLocalNotifications()
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        #endif
    }
    
    fileprivate func doSwitchScreen(_ animation: Bool) {
        if !self.isFullScreenSize {
            self.cardViewLeftConstraint.constant = 20
            self.cardViewRightConstraint.constant = 20
            self.cardViewBottomConstraint.constant = 10
            self.cardViewTopConstraint.constant = 70
            self.addTaskWidthConstraint.constant = 70
            self.addTaskHeightConstraint.constant = 70
            self.addTaskBottomConstraint.constant = 10
            if (animation) {
                self.newTaskButton.addCornerRadiusAnimation(20, to: 35, duration: kNormalAnimationDuration)
                
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
            
            self.newTaskButton.createIconButton(iconSize: 40, icon: "fa-plus",
                                                color: Colors().mainGreenColor, status: .normal)
        } else {
            self.cardViewLeftConstraint.constant = 5
            self.cardViewRightConstraint.constant = 5
            self.cardViewBottomConstraint.constant = 5
            self.cardViewTopConstraint.constant = 25
            self.addTaskWidthConstraint.constant = 40
            self.addTaskHeightConstraint.constant = 40
            self.addTaskBottomConstraint.constant = 5
            
            if (animation) {
                self.newTaskButton.addCornerRadiusAnimation(35, to: 20, duration: kNormalAnimationDuration)
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
            self.newTaskButton.createIconButton(iconSize: 30, icon: "fa-plus",
                                                color: Colors().mainGreenColor, status: .normal)
        }
        
        self.configFullSizeButton(Colors())
        AppUserDefault().write(kUserDefaultFullScreenKey, value: isFullScreenSize)
        self.isFullScreenSize = !self.isFullScreenSize
    }
    
    func newTaskAction() {
        let newTaskVC = NewTaskViewController()
        self.addChildViewController(newTaskVC)
        newTaskVC.didMove(toParentViewController: self)
        
        self.newTaskVC = newTaskVC
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

extension HomeViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        self.taskTableView.reloadData()
    }
}

// MARK: - table view
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.inRunningTasksTable() {
            self.showEmptyHint(self.runningTasks?.count ?? 0 <= 0)
            return self.runningTasks?.count ?? 0
        } else {
            self.showEmptyHint(self.finishTasks?.count ?? 0 <= 0)
            return self.finishTasks?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let _ = AppUserDefault().readString(kUserDefaultCurrentTagUUIDKey) else { return 0 }
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tagUUID = AppUserDefault().readString(kUserDefaultCurrentTagUUIDKey) else { return nil }
        guard let tag = RealmManager.shared.queryTag(usingName: false, query: tagUUID)
            else { return nil }
        
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: 25)))
        view.backgroundColor = UIColor(red:0.91, green:0.92, blue:0.93, alpha:1.00)
        
        let label = UILabel()
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.leading.equalTo(view).offset(5)
        }
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = Colors().mainTextColor
        label.text = tag.name
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        
        let task: Task?
        let canChange: Bool
        if self.inRunningTasksTable() {
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
        self.animationNavgationTo(vc: taskVC)
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
        return self.statusSlideSegment.selectedSegmentIndex == 0
    }
    
    /**
     打开 settings 页面，例如删除 或者 工作法
     */
    fileprivate func showSettings(taskUUID: String) {
        guard let task =
            RealmManager.shared.queryTask(taskUUID) else { return }
        
        let alert = UIAlertController(title: task.getNormalDisplayTitle(), message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: Localized("deleteTask"), style: .destructive) { (action) in
            
            if #available(iOS 9.0, *) {
                SpotlightManager().removeFromIndex(task: task)
            }
            
            RealmManager.shared.deleteTask(task)
        }
        alert.addAction(deleteAction)
        
        if let _ = task.notifyDate {
            let deleteReminderAction = UIAlertAction(title: Localized("deleteReminder"), style: .destructive, handler: { (action) in
                RealmManager.shared.deleteTaskReminder(task)
                
            })
            alert.addAction(deleteReminderAction)
        }
        
        if task.taskType == kCustomTaskType {
            let workflowAction = UIAlertAction(title: Localized("timeManagement"), style: .default) { [unowned self] (action) in
                let selectVC = TimeManagementViewController(isSelectTM: true, selectTMBlock: { [unowned self] (tm) in
                    dispatch_delay(0.35, closure: {
                        guard let view =
                            TimeManagementView.loadNib(self, method: tm, task: task) else { return }
                        self.timeManagementView = view
                        view.moveIn(view: self.view)
                    })
                })
                
                self.navigationController?.pushViewController(selectVC, animated: true)
            }
            alert.addAction(workflowAction)
        }
        
        let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - switch tag delegate
extension HomeViewController: SwitchTagDelegate {
    func switchTagTo(tag: Tag?) {
        self.queryTodayTask(tagUUID: tag?.tagUUID)
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
