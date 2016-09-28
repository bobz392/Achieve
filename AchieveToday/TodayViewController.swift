//
//  TodayViewController.swift
//  AchieveToday
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var todayTableView: UITableView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    fileprivate var allGroupTasks = [GroupTask]()
    fileprivate let bottomHeight: CGFloat = 73
    fileprivate let maxShowTaskCount = 8
    
    fileprivate let wormhole = MMWormhole.init(applicationGroupIdentifier: GroupIdentifier, optionalDirectory: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        let cloudColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
        let secondaryTextColor = UIColor(red:0.58, green:0.65, blue:0.65, alpha:1.00)
        let mainTextColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.00)
        
        self.todayTableView.register(TodayTableViewCell.nib, forCellReuseIdentifier: TodayTableViewCell.reuseId)
        self.todayTableView.separatorColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.00)
        
        self.todayTableView.tableFooterView = UIView()
        
        if #available(iOS 10.0, *) {
            self.infoLabel.textColor = mainTextColor
            self.allButton.tintColor = cloudColor
            self.allButton.setTitleColor(mainTextColor, for: UIControlState())
        } else {
            self.infoLabel.textColor = cloudColor
            self.allButton.tintColor = secondaryTextColor
            
            self.allButton.setTitleColor(cloudColor, for: UIControlState())
        }
        
        self.allButton.setTitle(Localized("showAll"), for: UIControlState())
        self.allButton.addTarget(self, action: #selector(self.enterApp), for: .touchUpInside)
        self.allButton.clipsToBounds = true
        self.allButton.layer.cornerRadius = 4
        
        self.wormhole.listenForMessage(withIdentifier: WormholeNewTaskIdentifier) { (any) in
            self.updateTask()
        }
        
        self.allButton.addBlurEffect()
        self.updateTask()
    
        if #available(iOS 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
    }
    
    deinit {
        self.wormhole.stopListeningForMessage(withIdentifier: WormholeNewTaskIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    @available (iOS 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .expanded) {
            let taskCount = self.allGroupTasks.count
            if taskCount > maxShowTaskCount {
                self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(maxShowTaskCount) + bottomHeight)
            } else {
                self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(taskCount) + bottomHeight)
            }
        } else if (activeDisplayMode == .compact) {
            if self.allGroupTasks.count > 1 {
                self.preferredContentSize = maxSize
            } else {
                self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight + bottomHeight)
            }
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        guard let group = GroupUserDefault() else {
            completionHandler(.failed)
            self.updateContent()
            return
        }
        
        self.allGroupTasks = group.allTasksForTodayExtension()
        self.todayTableView.reloadData()
        
        if group.taskHasChanged() {
            let taskCount = self.allGroupTasks.count
            self.infoLabel.text = GroupTask.showTaskCountTitle(taskCount: taskCount)
            
            if taskCount > maxShowTaskCount {
                self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(maxShowTaskCount) + bottomHeight)
            } else {
                self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(taskCount) + bottomHeight)
            }
            group.setTaskChanged(false)
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    func enterApp() {
        guard let url = URL(string: kMyRootUrlScheme + kTaskAllPath) else { return }
        self.extensionContext?.open(url, completionHandler: nil)
    }
    
    func updateTask() {
        guard let group = GroupUserDefault() else {
            return
        }
        
        if group.taskHasChanged() {
            group.setTaskChanged(false)
        }
        
        self.allGroupTasks = group.allTasksForTodayExtension()
        self.todayTableView.reloadData()
        
        self.updateContent()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    
    func updateContent() {
        let taskCount = self.allGroupTasks.count
        
        self.infoLabel.text = GroupTask.showTaskCountTitle(taskCount: taskCount)
        
        if taskCount > maxShowTaskCount {
            self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(maxShowTaskCount) + bottomHeight)
        } else {
            self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(taskCount) + bottomHeight)
        }
    }
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allGroupTasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TodayTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodayTableViewCell.reuseId, for: indexPath) as! TodayTableViewCell
        
        cell.task = self.allGroupTasks[indexPath.row]
        cell.checkButton.tag = indexPath.row
        cell.titleLabel.text = cell.task?.taskTitle
        cell.checkButton.addTarget(self, action: #selector(self.checkTask(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = self.allGroupTasks[indexPath.row]
        let taskUUID = task.taskUUID
        
        guard let url = URL(string: kMyRootUrlScheme + kTaskDetailPath + taskUUID) else { return }
        self.extensionContext?.open(url, completionHandler: nil)
    }
    
    func checkTask(_ btn: UIButton) {
        guard let group = GroupUserDefault() else {
            return
        }
        
        self.allGroupTasks.remove(at: btn.tag)
        self.todayTableView.deleteRows(at: [IndexPath(row: btn.tag, section: 0)], with: .automatic)
        self.updateContent()
        group.todayExtensionMoveTaskFinish(btn.tag)
        let reloadIndexs =
            (btn.tag..<self.allGroupTasks.count).map( { IndexPath(row: $0, section: 0) } )
        self.todayTableView.reloadRows(at: reloadIndexs, with: .none)
    }
}
