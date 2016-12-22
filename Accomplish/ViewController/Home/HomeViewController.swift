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
    //    @IBOutlet weak var cardView: UIView!
    //    @IBOutlet weak var statusSlideSegment: TwicketSegmentedControl!
    //    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var newTaskButton: UIButton!
    //    @IBOutlet weak var calendarButton: UIButton!
    //    @IBOutlet weak var searchButton: UIButton!
    //    @IBOutlet weak var tagButton: UIButton!
    //    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    //    @IBOutlet weak var currentDateLabel: UILabel!
    //    @IBOutlet weak var emptyHintLabel: UILabel!
    //    @IBOutlet weak var emptyCoffeeLabel: UILabel!
    
    fileprivate var showFinishTask = false
    fileprivate var taskListManager = TaskListManager()
    
    fileprivate var selectedIndex: IndexPath? = nil
    // 用于缓存当前已经划开的 cell 的 index
    fileprivate var cacheSwipedIndex: IndexPath? = nil
    
    fileprivate var timer: SecondTimer?
    fileprivate var repeaterManager = RepeaterManager()
    
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
        
        self.configMainUI()
        self.initializeControl()
        self.taskListManager.datasource = self
        //        self.configMainButton()
        
        //        self.queryTodayTask()
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ui config
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        
        let bar = self.createCustomBar()
        let menuButton = UIButton(type: .custom)
        menuButton.buttonWithIcon(icon: Icons.barMenu.iconString())
        bar.addSubview(menuButton)
        menuButton.snp.makeConstraints { (make) in
            make.width.equalTo(barIconSize)
            make.height.equalTo(barIconSize)
            make.bottom.equalTo(bar).offset(-6)
            make.left.equalToSuperview().offset(12)
        }
        menuButton.addTarget(self, action: #selector(self.openMenuAction), for: .touchUpInside)
        
        let searchButton = UIButton(type: .custom)
        searchButton.buttonWithIcon(icon: Icons.search.iconString())
        bar.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.width.equalTo(barIconSize)
            make.height.equalTo(barIconSize)
            make.centerY.equalTo(menuButton)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        self.taskTableView.clearView()
        self.taskTableView.tableFooterView = UIView()
        self.taskTableView.register(TaskTableViewCell.nib, forCellReuseIdentifier: TaskTableViewCell.reuseId)
        
        self.newTaskButton.addShadow()
        self.newTaskButton.layer.cornerRadius = 35
        self.newTaskButton.buttonWithIcon(icon: Icons.plus.iconString())
        self.newTaskButton.addTarget(self, action:  #selector(self.newTaskAction), for: .touchUpInside)
        
        //        self.currentDateLabel.text = NSDate().formattedDate(with: .medium)
        //        self.emptyHintLabel.text = Localized("emptyTask")
        //        self.currentDateLabel.textColor = colors.cloudColor
        //.backgroundColor = colors.cloudColor
        //        self.taskTableView.separatorColor = colors.separatorColor
        //        self.cardView.backgroundColor = colors.cloudColor
        //
        //        self.statusSlideSegment.sliderBackgroundColor = colors.mainGreenColor
        //        self.statusSlideSegment.segmentsBackgroundColor = UIColor.white
        //        self.statusSlideSegment.clearView()
        //
        //        self.emptyHintLabel.textColor = colors.secondaryTextColor
        //        self.settingButton.buttonColor(colors)
        
        
        //        self.calendarButton.buttonColor(colors)
        //        self.fullScreenButton.buttonColor(colors)
        //        self.tagButton.buttonColor(colors)
        //        self.searchButton.backgroundColor = colors.mainGreenColor
        
        //        let coffeeIcon = FAKFontAwesome.coffeeIcon(withSize: 60)
        //        coffeeIcon?.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        //        self.emptyCoffeeLabel.attributedText = coffeeIcon?.attributedString()
        //
        //        let iconSize: CGFloat = 20
        //        //fa-cog
        //        self.settingButton.createIconButton(iconSize: iconSize, icon: "fa-cog",
        //                                            color: colors.mainGreenColor, status: .normal)
        //        //fa-plus
        //
        //        //fa-calendar
        //        self.calendarButton.createIconButton(iconSize: iconSize, icon: "fa-calendar",
        //                                             color: colors.mainGreenColor, status: .normal)
        //        //fa-tag
        //        self.tagButton.createIconButton(iconSize: iconSize, icon: "fa-tag",
        //                                        color: colors.mainGreenColor, status: .normal)
        //        //fa-search
        //        self.searchButton.createIconButton(iconSize: 24, icon: "fa-search",
        //                                           color: colors.cloudColor, status: .normal)
        //        self.searchButton.tintColor = colors.mainGreenColor
        //
        //        self.configFullSizeButton(colors)
        
        
        //        self.taskTableView.homeRefreshControl.tintColor = colors.mainGreenColor
        //        self.taskTableView.homeRefreshControl.attributedTitle =
        //            NSAttributedString(string: Localized("search"),
        //                               attributes: [NSForegroundColorAttributeName : colors.mainGreenColor])
    }
    
    fileprivate func initializeControl() {
        self.taskTableView.tableFooterView = UIView()
        
        //        self.cardView.addShadow()
        self.newTaskButton.addShadow()
        self.newTaskButton.layer.cornerRadius = 35
        //        self.settingButton.addShadow()
        //        self.fullScreenButton.addShadow()
        //        self.calendarButton.addShadow()
        //        self.tagButton.addShadow()
        //        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        //
        //        let segTitles = [Localized("progess"), Localized("finished")]
        //        self.statusSlideSegment.setSegmentItems(segTitles)
        //        self.statusSlideSegment.delegate = self
        
        self.taskTableView.register(TaskTableViewCell.nib, forCellReuseIdentifier: TaskTableViewCell.reuseId)
        
        //        self.currentDateLabel.text = NSDate().formattedDate(with: .medium)
        //        self.emptyHintLabel.text = Localized("emptyTask")
        //
        self.newTaskButton.addTarget(self, action:  #selector(self.newTaskAction),
                                     for: .touchUpInside)
        //
        //        self.calendarButton.addTarget(self, action: #selector(self.calendarAction),
        //                                      for: .touchUpInside)
        //
        //        self.fullScreenButton.addTarget(self, action: #selector(self.switchScreenAction),
        //                                        for: .touchUpInside)
        //
        //        self.settingButton.addTarget(self, action: #selector(self.settingAction),
        //                                     for: .touchUpInside)
        //
        //        self.tagButton.addTarget(self, action: #selector(self.tagAction), for: .touchUpInside)
        //
        //        self.searchButton.addTarget(self, action: #selector(self.searchAction),
        //                                    for: .touchUpInside)
        
        //        self.taskTableView.getCurrentIndex = { [unowned self] () -> Int in
        //            return self.statusSlideSegment.selectedSegmentIndex
        //        }
        //
        //        self.taskTableView.changeCallBack = { [unowned self] (changeIndex) -> Void in
        //            self.statusSlideSegment.move(to: changeIndex)
        //            self.taskTableView.reloadData()
        //        }
        //
        //        self.taskTableView.searchCallBack = { [unowned self] () -> Void in
        //            self.searchAction()
        //        }
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
                self.taskListManager.handelTodayExtensionFinish()
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
     检测上次退出 app 的时候是否还有在运行中的 time method
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
     在进入 app 的时候检查是否是新的一天，处理内容顺序为：
     - 先处理新的一天，切换查询条件为今天，并且把选中的缓存 index 清空
     - 设置 label 为今天的时间
     - 检查是否需要移动到今天，并且上传所有未上传的 checkin 的数据到 icloud
     */
    fileprivate func checkNewDay() {
        if self.repeaterManager.isNewDay() {
            self.handleNewDay()
            self.selectedIndex = nil
            //            self.currentDateLabel.text = NSDate().formattedDate(with: .medium)
            
            self.checkNeedMoveUnfinishTaskToday()
        }
    }
    
    fileprivate func initTimer() {
        self.timer = SecondTimer(handle: { [weak self] () -> Void in
            guard let ws = self else { return }
            dispatch_async_main {
                ws.checkNewDay()
                ws.cacheSwipedIndexBeforReload()
                ws.taskTableView.reloadData()
            }
        })
        
        self.timer?.start()
    }
    
    /**
     - 当新的一天到来的时候调用，来处理新的数据
     - 首先查询今天的任务，可能是重复任务，可能是分配到今天的任务
     - 添加今天的任务到索引
     */
    func handleNewDay() {
        self.taskListManager.queryTodayTask()
        self.taskListManager.handleUpdateTodayGroup()
        if #available(iOS 9.0, *) {
            SpotlightManager().addDateTaskToIndex()
        }
    }
    
    /**
     如果开启的移动未完成的任务到今天，完成后上传 icloud
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
        self.handleNewDay()
        
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
    
    fileprivate func handleMoveUnfinishTaskToToday() {
        let shareManager = RealmManager.shared
        let movetasks = shareManager.hasUnfinishTaskMoveToday()
        if movetasks.count > 0 {
            let alert = UIAlertController(title: nil, message: Localized("detailIncomplete"), preferredStyle: .alert)
            let moveAction = UIAlertAction(title: Localized("move"), style: .default) { [unowned self] (action) in
                shareManager.moveYesterdayTaskToToday(movedtasks: movetasks)
                self.uploadToiCloud()
            }
            let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel) { [unowned self] (action) in
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
    
    // MARK: - actions
    fileprivate func animationNavgationTo(vc: UIViewController) {
        //        self.navigationController?.delegate = self
        //        self.toViewControllerAnimationType = 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openMenuAction() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.drawer?.open(MMDrawerSide.left, animated: true, completion: nil)
    }
    
    func settingAction() {
        self.animationNavgationTo(vc: SettingsViewController())
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
    
    /**
     在新建任务之前先把滑动开的 cell 关闭
     */
    func newTaskAction() {
        let newTaskBlock = { [unowned self] in
            let newTaskVC = NewTaskViewController()
            self.addChildViewController(newTaskVC)
            newTaskVC.didMove(toParentViewController: self)
            
            self.newTaskVC = newTaskVC
        }
        
        if let swiped = self.cacheSwipedIndex,
            let cell = self.taskTableView.cellForRow(at: swiped) as? MGSwipeTableCell {
            cell.hideSwipe(animated: true, completion: { (completion) in
                newTaskBlock()
            })
            self.cacheSwipedIndex = nil
        } else {
            newTaskBlock()
        }
        
    }
    
    // 从today 点击一个 task 进入 detail
    func enterTaskFromToday(_ uuid: String) {
        guard let t = self.taskListManager.preceedTasks.filter({ (task) -> Bool in
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
 
 extension HomeViewController: RealmNotificationDataSource {
    func initial(status: TaskStatus) {
        self.taskTableView.reloadData()
    }
    
    /**
     由于刷新的通知时间问题，会导致 section 0 删除以后 section 1 里面的数据马上被添加，
     导致的 uitableview cell assert 失败而崩溃，所以由 preceed list begin update，
     并且统一延迟0.1秒来 end update。
     
     有2点要注意
     - 在 preceed list 中要注意 count 从 0 到 1之间的变化需要reload section 来重载 header
     */
    func update(deletions: [Int], insertions: [Int], modifications: [Int], status: TaskStatus) {
        let update = { [unowned self] (section: Int) -> Void in
            if insertions.count > 0 {
                if self.taskListManager.preceedTasks.count == 1 && status == .preceed {
                    self.taskTableView.reloadSections(IndexSet([0]), with: .automatic)
                } else {
                    self.taskTableView.insertRows(
                        at: insertions.map { IndexPath(row: $0, section: section) },
                        with: .automatic)
                }
            } else if modifications.count > 0 {
                self.taskTableView
                    .reloadRows(at: modifications.map { IndexPath(row: $0, section: section) }, with: .automatic)
            } else if deletions.count > 0 {
                if self.taskListManager.preceedTasks.count == 0 && status == .preceed {
                    self.taskTableView.reloadSections(IndexSet([0]), with: .automatic)
                } else {
                    self.taskTableView
                        .deleteRows(at: deletions.map { IndexPath(row: $0, section: section) }, with: .automatic)
                }
            }
        }
        
        if status == .preceed {
            self.taskTableView.beginUpdates()
            update(0)
            // 如果当前不是完成任务或者取消完成任务的情况，则直接 update
            if TaskListManager.currentStatus() != .move {
                self.taskTableView.endUpdates()
            }
            guard let deletion = deletions.first,
                let selectedRow = self.selectedIndex?.row else { return }
            if deletion == selectedRow {
                self.selectedIndex = nil
            }
        } else {
            if self.showFinishTask {
                update(1)
            }
            self.taskTableView.endUpdates()
            TaskListManager.updateStatus(newStatues: .none)
        }
        
    }
 }
 
 // MARK: - table view
 extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskListManager
            .numberOfRows(section: section, showFinishTask: self.showFinishTask)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.taskListManager.heightForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.taskListManager.heightForHeaderInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.taskListManager.viewForHeaderIn(section: section, target: self)
        
        if section == 0 {
            return headerView
        } else if section == 1 {
            if let header = headerView as? TaskTableHeaderView {
                let showTitle = Localized("show")
                let hideTitle = Localized("hide")
                let initialTitle = self.showFinishTask ? showTitle : hideTitle
                header.configAdditionButton(title: initialTitle
                    , buttonBlock: { [unowned self] (additionButton) in
                        self.showFinishTask = !self.showFinishTask
                        let newTitle = self.showFinishTask ? showTitle : hideTitle
                        additionButton.setTitle(newTitle, for: .normal)
                        self.taskTableView.reloadSections(IndexSet([1]), with: .automatic)
                })
            }
            return headerView
        } else {
            return nil
        }
        
        //        guard let tagUUID = AppUserDefault().readString(kUserDefaultCurrentTagUUIDKey) else { return nil }
        //        guard let tag = RealmManager.shared.queryTag(usingName: false, query: tagUUID)
        //            else { return nil }
        //
        //        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.width, height: 25)))
        //        view.backgroundColor = UIColor(red:0.91, green:0.92, blue:0.93, alpha:1.00)
        //
        //        let label = UILabel()
        //        view.addSubview(label)
        //        label.snp.makeConstraints { (make) in
        //            make.centerY.equalTo(view)
        //            make.leading.equalTo(view).offset(5)
        //        }
        //        label.font = UIFont.systemFont(ofSize: 14)
        //        label.textColor = Colors.mainTextColor
        //        label.text = tag.name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        
        let task = self.taskListManager.taskForIndexPath(indexPath: indexPath)
        var canChange = true
        if indexPath.section == 0 {
            canChange = true
        } else if indexPath.section == 1 {
            canChange = false
        }
        self.enterTask(task, canChange: canChange)
    }
    
    fileprivate func enterTask(_ task: Task, canChange: Bool) {
        let taskVC = TaskDetailViewController(task: task, canChange: canChange)
        self.animationNavgationTo(vc: taskVC)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseId, for: indexPath) as! TaskTableViewCell
        
        let task = self.taskListManager.taskForIndexPath(indexPath: indexPath)
        
        cell.configCellUse(task)
       
        if task.typeOfTask() == .custom {
            cell.timeManagementBlock = { [unowned self] in
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
        } else {
            cell.timeManagementBlock = nil
        }
        
        if let swipedIndex = self.cacheSwipedIndex,
            swipedIndex == indexPath {
            cell.showSwipe(.rightToLeft, animated: false)
            self.cacheSwipedIndex = nil
        }
        
        return cell
    }
    
    fileprivate func cacheSwipedIndexBeforReload() {
        guard let visibleCells =
            self.taskTableView.visibleCells as? [MGSwipeTableCell] else { return }
        
        for cell in visibleCells {
            if cell.swipeOffset != 0.0 {
                let index = self.taskTableView.indexPath(for: cell)
                self.cacheSwipedIndex = index
            }
        }
    }
    
    /**
     打开 settings 页面，例如删除 或者 工作法
     */
//    fileprivate func showSettings(taskUUID: String) {
//        guard let task =
//            RealmManager.shared.queryTask(taskUUID) else { return }
//        
//        let alert = UIAlertController(title: task.getNormalDisplayTitle(), message: nil, preferredStyle: .actionSheet)
//        
//        let deleteAction = UIAlertAction(title: Localized("deleteTask"), style: .destructive) { (action) in
//            
//            if #available(iOS 9.0, *) {
//                SpotlightManager().removeFromIndex(task: task)
//            }
//            
//            RealmManager.shared.deleteTask(task)
//        }
//        alert.addAction(deleteAction)
//        
//        if let _ = task.notifyDate {
//            let deleteReminderAction = UIAlertAction(title: Localized("deleteReminder"), style: .destructive, handler: { (action) in
//                RealmManager.shared.deleteTaskReminder(task)
//                
//            })
//            alert.addAction(deleteReminderAction)
//        }
//        
//        if task.typeOfTask() == .custom {
//            let workflowAction = UIAlertAction(title: Localized("timeManagement"), style: .default) { [unowned self] (action) in
//                let selectVC = TimeManagementViewController(isSelectTM: true, selectTMBlock: { [unowned self] (tm) in
//                    dispatch_delay(0.35, closure: {
//                        guard let view =
//                            TimeManagementView.loadNib(self, method: tm, task: task) else { return }
//                        self.timeManagementView = view
//                        view.moveIn(view: self.view)
//                    })
//                })
//                
//                self.navigationController?.pushViewController(selectVC, animated: true)
//            }
//            alert.addAction(workflowAction)
//        }
//        
//        let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel) { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }
//        alert.addAction(cancelAction)
//        
//        self.present(alert, animated: true, completion: nil)
//    }
 }
 
 // MARK: - switch tag delegate
 extension HomeViewController: SwitchTagDelegate {
    func switchTagTo(tag: Tag?) {
        self.taskListManager.queryTodayTask(tagUUID: tag?.tagUUID)
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
            return nil
        }
    }
 }
