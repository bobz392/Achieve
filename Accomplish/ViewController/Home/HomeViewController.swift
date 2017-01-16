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
    let taskTableView = UITableView()
    
    fileprivate var showFinishTask = false
    fileprivate var taskListManager = TaskListManager()
    fileprivate var selectedIndex: IndexPath? = nil
    // 改变日期后移动的 index， 从这个 index 到 selected index
    fileprivate var atIndex: IndexPath? = nil
    // 用于缓存当前已经划开的 cell 的 index
    fileprivate var cacheSwipedIndex: IndexPath? = nil
    fileprivate var timer: SecondTimer?
    fileprivate var repeaterManager = RepeaterManager()
    fileprivate weak var newTaskVC: NewTaskViewController? = nil
    fileprivate lazy var icloudManager = CloudKitManager()
    fileprivate weak var tmView: TMView? = nil
    
    // MARK: - life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDefault = AppUserDefault()
        self.configMainUI()
        self.taskListManager.datasource = self
        self.addNotification()
        self.initTimer()
        
//        TestManager().addAppStoreData()
        
        dispatch_delay(0.5) { [unowned self] in
            if appDefault.readBool(kUserDefaultBuildInTMKey) != true {
                self.icloudManager.asyncFromCloudIfNeeded()
                BuildInTimeMethodCreator().pomodoroCreator()
                BuildInTaskCreator().create()
                appDefault.write(kUserDefaultBuildInTMKey, value: true)
            }
            
            self.checkTimeMethodRunning()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let select = self.selectedIndex {
            if let at = self.atIndex {
                self.taskTableView.moveRow(at: at, to: select)
                self.atIndex = nil
            }
            
            self.taskTableView.deselectRow(at: select, animated: true)
            self.selectedIndex = nil
        }
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
        
        let bar = self.createCustomBar(height: kBarHeight)
        let menuButton = self.congfigMenuButton()
        
        let searchButton = UIButton(type: .custom)
        searchButton.buttonWithIcon(icon: Icons.search.iconString())
        searchButton.addTarget(self, action: #selector(self.searchAction), for: .touchUpInside)
        bar.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.width.equalTo(kBarIconSize)
            make.height.equalTo(kBarIconSize)
            make.centerY.equalTo(menuButton)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        self.configHomeTableView(bar: bar)
        
        let createTaskButton = self.createPlusButton()
        createTaskButton.addTarget(self, action:  #selector(self.newTaskAction), for: .touchUpInside)
        
        if #available(iOS 9.0, *) {
            self.registerPerview(sourceViewBlock: { [unowned self] () -> UIView in
                return self.taskTableView
                }, previewViewControllerBlock: { [unowned self] (previewingContext: UIViewControllerPreviewing, location: CGPoint) -> UIViewController? in
                guard let index = self.taskTableView.indexPathForRow(at: location),
                    let cell = self.taskTableView.cellForRow(at: index) else { return nil }
                let task = self.taskListManager.taskForIndexPath(indexPath: index)
                let taskVC = TaskDetailViewController(task: task, canChange: index.section == 0)
                previewingContext.sourceRect = cell.frame
                return taskVC
            })
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
        if let _ = self.tmView { return }
        let app = AppUserDefault()
        guard let uuid = app.readString(kUserDefaultTMUUIDKey),
            let taskUUID = app.readString(kUserDefaultTMTaskUUID),
            let task = RealmManager.shared.queryTask(taskUUID),
            let details = app.readArray(kUserDefaultTMDetailsKey) as? Array<Int>,
            let tm = RealmManager.shared.queryTimeMethod(uuid: uuid) else { return }
        
        if details.count == 4 {
            guard let view = TMView.loadNib(self, method: tm, task: task) else { return }
            self.tmView = view
            view.moveIn(view: self.view)
            view.configBlurImageView(view: self.view)
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
            let moveAction = UIAlertAction(title: Localized("ok"), style: .default) { [unowned self] (action) in
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
        self.navigationController?.pushViewController(vc, animated: true)
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
        let newTaskVC = NewTaskViewController()
        self.addChildViewController(newTaskVC)
        newTaskVC.didMove(toParentViewController: self)
        
        self.newTaskVC = newTaskVC
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
 
 // MARK: - realm token data source
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
            // 如果是改变了顺序，例如更新了 created date
            if TaskListManager.currentStatus() == .resort {
                if let insert = insertions.first, let delete = deletions.first {
                    self.atIndex = IndexPath(row: delete, section: 0)
                    self.selectedIndex = IndexPath(row: insert, section: 0)
                } else {
                    self.taskTableView.reloadSections(IndexSet([0]), with: .none)
                }
                TaskListManager.updateCurrentStatus(newStatues: .none)
                return
            } else {
                update(0)
                guard let deletion = deletions.first,
                    let selectedRow = self.selectedIndex?.row else { return }
                if deletion == selectedRow {
                    self.selectedIndex = nil
                }
            }
            // 结束任务的动画
        } else {
            if self.showFinishTask {
                update(1)
            }
        }
    }
    
    func updating(begin: Bool) {
        if begin {
            self.taskTableView.beginUpdates()
        } else {
            self.taskTableView.endUpdates()
        }
    }
    
 }
 
 // MARK: - table view
 extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate func configHomeTableView(bar: UIView) {
        self.view.addSubview(self.taskTableView)
        self.taskTableView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.taskTableView.delegate = self
        self.taskTableView.dataSource = self
        self.taskTableView.clearView()
        self.taskTableView.separatorStyle = .none
        self.taskTableView.tableFooterView = UIView()
        self.taskTableView.register(TaskTableViewCell.nib,
                                    forCellReuseIdentifier: TaskTableViewCell.reuseId)
    }
    
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
            guard let header = headerView as? TaskTableHeaderView else { return headerView }
            let userDefault = AppUserDefault()
            if let tagUUID = userDefault.readString(kUserDefaultCurrentTagUUIDKey),
                let tag = RealmManager.shared.queryTag(usingName: false, query: tagUUID) {
                header.updateTitle(newTitle: Localized("progess") + "-" + tag.name)
                header.configAdditionButton(title: Localized("backToAllTask"), buttonBlock: { (button) in
                    userDefault.remove(kUserDefaultCurrentTagUUIDKey)
                    self.switchTagTo(tag: nil)
                })
            } else {
                userDefault.remove(kUserDefaultCurrentTagUUIDKey)
                header.removeAdditionButton()
            }
            
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
                            TMView.loadNib(self, method: tm, task: task) else { return }
                        self.tmView = view
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
    
 }
 
 // MARK: - switch tag delegate
 extension HomeViewController: SwitchTagDelegate {
    func switchTagTo(tag: Tag?) {
        self.taskListManager.queryTodayTask(tagUUID: tag?.tagUUID)
        self.taskTableView.reloadData()
    }
 }
 
 // MAKR: - drawer open close call back -- not prefect
 extension HomeViewController: MenuDrawerSlideStatusDelegate {
    func slideOpen(open: Bool) {
        self.leftBarButton?.isSelected = open
    }
 }
