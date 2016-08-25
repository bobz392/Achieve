//
//  HomeViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    private var finishTasks: Results<Task>?
    private var runningTasks: Results<Task>?
    
    private var finishToken: RealmSwift.NotificationToken?
    private var runningToken: RealmSwift.NotificationToken?
    
    private var isFullScreenSize = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        isFullScreenSize = UserDefault().readBool(kIsFullScreenSizeKey)
        
        self.configMainUI()
        self.initializeControl()
        self.configMainButton()
        
        self.finishTasks = RealmManager.shareManager.queryTodayTaskList(true)
        self.runningTasks = RealmManager.shareManager.queryTodayTaskList(false)
        self.realmNoticationToken()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        finishToken?.stop()
        runningToken?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - ui config
    private func configMainUI() {
        let colors = Colors()
        self.currentDateLabel.textColor = colors.cloudColor
        self.taskTableView.backgroundColor = colors.cloudColor
        self.taskTableView.separatorColor = colors.separatorColor
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.statusSegment.tintColor = colors.mainGreenColor
        
        self.emptyHintLabel.textColor = colors.secondaryTextColor
        
        self.settingButton.tintColor = colors.mainGreenColor
        self.settingButton.backgroundColor = colors.cloudColor
        
        self.newTaskButton.tintColor = colors.mainGreenColor
        self.newTaskButton.backgroundColor = colors.cloudColor
        self.calendarButton.tintColor = colors.mainTextColor
        self.calendarButton.backgroundColor = colors.cloudColor
        self.fullScreenButton.tintColor = colors.mainGreenColor
        self.fullScreenButton.backgroundColor = colors.cloudColor
        
        let coffeeIcon = FAKFontAwesome.coffeeIconWithSize(60)
        coffeeIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.emptyCoffeeLabel.attributedText = coffeeIcon.attributedString()
        
        let cogIcon = FAKFontAwesome.cogIconWithSize(20)
        cogIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let cogImage = cogIcon.imageWithSize(CGSize(width: 20, height: 20))
        self.settingButton.setImage(cogImage, forState: .Normal)
        
        let newIcon = FAKFontAwesome.plusIconWithSize(50)
        newIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let newImage = newIcon.imageWithSize(CGSize(width: 70, height: 70))
        self.newTaskButton.setImage(newImage, forState: .Normal)
        
        let calendarIcon = FAKFontAwesome.calendarIconWithSize(20)
        calendarIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let calendarImage = calendarIcon.imageWithSize(CGSize(width: 20, height: 20))
        self.calendarButton.setImage(calendarImage, forState: .Normal)
        
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
        self.newTaskButton.addTarget(self, action: #selector(self.buttonAnimationStartAction(_:)), forControlEvents: .TouchDown)
        self.newTaskButton.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), forControlEvents: .TouchUpOutside)
        
        self.calendarButton.addTarget(self, action: #selector(self.calendarAction), forControlEvents: .TouchUpInside)
        
        self.fullScreenButton.addTarget(self, action: #selector(self.switchScreenAction), forControlEvents: .TouchUpInside)
    }
    
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
                self.taskTableView.beginUpdates()
                if insertions.count > 0 {
                    self.taskTableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                }
                
                if modifications.count > 0 {
                    self.taskTableView.reloadRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                }
                
                if deletions.count > 0 {
                    self.taskTableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) },
                        withRowAnimation: .Automatic)
                    
                    dispatch_delay(0.25, closure: { [unowned self] in
                        self.taskTableView.reloadData()
                        })
                }
                
                self.taskTableView.endUpdates()

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
                
            case .Update(_, let deletions, let insertions, let modifications):
                self.taskTableView.beginUpdates()
                if insertions.count > 0 {
                    self.taskTableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                }
                
                if modifications.count > 0 {
                    self.taskTableView.reloadRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                }
                
                if deletions.count > 0 {
                    self.taskTableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) },
                        withRowAnimation: .Automatic)
                    
                    dispatch_delay(0.25, closure: { [unowned self] in
                        self.taskTableView.reloadData()
                        })
                }
                self.taskTableView.endUpdates()
                
                
                
            case .Error(let error):
                print(error)
                break
            }
            })
        
    }
    
    // MARK: - actions
    func switchScreenAction() {
        doSwitchScreen(true)
    }
    
    func calendarAction() {
        print(finishTasks?.count)
        print(runningTasks?.count)
        
        print(finishTasks?.first)
        print(runningTasks?.first)
    }
    
    private func doSwitchScreen(animation: Bool) {
        if !isFullScreenSize {
            self.cardViewLeftConstraint.constant = 20
            self.cardViewRightConstraint.constant = 20
            self.cardViewBottomConstraint.constant = 20
            self.cardViewTopConstraint.constant = 70
            self.addTaskWidthConstraint.constant = 70
            self.addTaskHeightConstraint.constant = 70
            self.addTaskBottomConstraint.constant = 15
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
            self.cardViewTopConstraint.constant = 35
            self.addTaskWidthConstraint.constant = 32
            self.addTaskHeightConstraint.constant = 32
            self.addTaskBottomConstraint.constant = 10
            if (animation) {
                self.newTaskButton.addCornerRadiusAnimation(35, to: 16, duration: kNormalAnimationDuration)
                UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                    self.currentDateLabel.alpha = 0
                    })
            } else {
                self.newTaskButton.layer.cornerRadius = 16
                self.currentDateLabel.alpha = 0
            }
        }
        
        configFullSizeButton(Colors())
        UserDefault().write(kIsFullScreenSizeKey, value: isFullScreenSize)
        isFullScreenSize = !isFullScreenSize
    }
    
    func newTaskAction() {
        let alertController = UIAlertController(title: Localized("newTask"), message: nil, preferredStyle: .ActionSheet)
        let customAction = UIAlertAction(title: Localized("customTask"), style: .Destructive) { [unowned self] (action) in
            let vc = NewTaskViewController()
            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
        }
        alertController.addAction(customAction)
        
        let systemAction = UIAlertAction(title: Localized("dependTask"), style: .Destructive) { (action) in
            
        }
        alertController.addAction(systemAction)
        
        let dependAction = UIAlertAction(title: Localized("systemTask"), style: .Destructive) { (action) in
            
        }
        alertController.addAction(dependAction)
        
        let cancelAction = UIAlertAction(title: Localized("cancel"), style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            
        }
        buttonAnimationEndAction(newTaskButton)
    }
    
    func buttonAnimationStartAction(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
            btn.transform = CGAffineTransformScale(btn.transform, 0.8, 0.8)
        }) { (finish) in }
    }
    
    func buttonAnimationEndAction(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .LayoutSubviews, animations: {
            btn.transform = CGAffineTransformMakeScale(1, 1)
        }) { (finish) in }
    }
    
    func segmentValueChangeAction(seg: UISegmentedControl) {
        self.taskTableView.reloadData()
    }
    
    func markTaskFinish(btn: UIButton) {
        guard let task = self.runningTasks?[btn.tag] else {
            return
        }
        RealmManager.shareManager.updateTaskStatus(task, status: kTaskFinish)
    }
    
    func markTaskRunning(btn: UIButton) {
        guard let task = self.finishTasks?[btn.tag] else {
            return
        }
        RealmManager.shareManager.updateTaskStatus(task, status: kTaskRunning)
    }
    
    // MARK: - table view
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TaskTableViewCell.reuseId, forIndexPath: indexPath) as! TaskTableViewCell
        cell.taskStatusButton.tag = indexPath.row
        cell.taskStatusButton.removeTarget(self, action: #selector(self.markTaskFinish(_:)), forControlEvents: .TouchUpInside)
        cell.taskStatusButton.removeTarget(self, action: #selector(self.markTaskRunning(_:)), forControlEvents: .TouchUpInside)
        
        var task: Task?
        if self.inRunningTasksTable() {
            task = self.runningTasks?[indexPath.row]
            
            cell.taskStatusButton.addTarget(self, action: #selector(self.markTaskFinish(_:)), forControlEvents: .TouchUpInside)
        } else {
            task = self.finishTasks?[indexPath.row]
            cell.taskStatusButton.addTarget(self, action: #selector(self.markTaskRunning(_:)), forControlEvents: .TouchUpInside)
        }
        
        if let t = task {
            cell.configCellUse(t)
        }
        return cell
    }
    
    private func inRunningTasksTable() -> Bool {
        return self.statusSegment.selectedSegmentIndex == 0
    }
    
    @IBOutlet weak var cardViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTaskWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
}
