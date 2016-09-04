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
    
    private var alltasks = [[String]]()
    private let bottomHeight: CGFloat = 73
    private let maxShowTaskCount = 5
    
    private let wormhole = MMWormhole.init(applicationGroupIdentifier: group, optionalDirectory: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        let colors = Colors()
        
        self.todayTableView.registerNib(TodayTableViewCell.nib, forCellReuseIdentifier: TodayTableViewCell.reuseId)
        self.todayTableView.separatorColor = colors.separatorColor
        self.todayTableView.tableFooterView = UIView()
        
        self.infoLabel.textColor = colors.cloudColor
        
        self.allButton.backgroundColor = UIColor(red:0.50, green:0.55, blue:0.55, alpha:1.00)//colors.cloudColor
        self.allButton.setTitleColor(colors.cloudColor, forState: .Normal)
        self.allButton.tintColor = colors.secondaryTextColor
        self.allButton.setTitle(Localized("showAll"), forState: .Normal)
        self.allButton.addTarget(self, action: #selector(self.enterApp), forControlEvents: .TouchUpInside)
        self.allButton.layer.cornerRadius = 4
        
        self.wormhole.listenForMessageWithIdentifier(wormholeIdentifier) { (any) in
            self.updateTask()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        guard let group = GroupUserDefault() else {
            completionHandler(.Failed)
            return
        }
        
        self.alltasks = group.allTasks()
        self.todayTableView.reloadData()
        completionHandler(.NoData)
        
        if group.taskHasChanged() {
            self.alltasks = group.allTasks()
            self.todayTableView.reloadData()
            
            let taskCount = self.alltasks.count
            //            if taskCount == 1
            self.infoLabel.text = String(format: Localized("taskTody"), taskCount)
            
            
            if taskCount > maxShowTaskCount {
                self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(maxShowTaskCount) + bottomHeight)
            } else {
                self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(taskCount) + bottomHeight)
            }
            group.setTaskChanged(false)
            completionHandler(.NewData)
        } else {
            //            self.alltasks = group.allTasks()
            //            self.todayTableView.reloadData()
            completionHandler(.NoData)
        }
    }
    
    func enterApp() {
        guard let url = NSURL(string: kMyRootUrlScheme) else { return }
        self.extensionContext?.openURL(url, completionHandler: nil)
    }
    
    func updateTask() {
        print("update")
        guard let group = GroupUserDefault() else {
            return
        }
        
        if group.taskHasChanged() {
            self.alltasks = group.allTasks()
            self.todayTableView.reloadData()
            
            self.updateContent()
            group.setTaskChanged(false)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    
    func updateContent() {
        let taskCount = self.alltasks.count
        
        if taskCount == 0 {
            self.infoLabel.text = String(format: Localized("noTaskToday"), taskCount)
        } else if taskCount == 1 {
            self.infoLabel.text = String(format: Localized("taskToday"), taskCount)
        } else {
            self.infoLabel.text = String(format: Localized("taskTodays"), taskCount)
        }
        
        if taskCount > maxShowTaskCount {
            self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(maxShowTaskCount) + bottomHeight)
        } else {
            self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * CGFloat(taskCount) + bottomHeight)
        }
    }
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alltasks.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TodayTableViewCell.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TodayTableViewCell.reuseId, forIndexPath: indexPath) as! TodayTableViewCell
        
        cell.task = alltasks[indexPath.row]
        cell.checkButton.tag = indexPath.row
        cell.titleLabel.text = alltasks[indexPath.row][GroupUserDefault.GroupTaskTitleIndex]
        cell.checkButton.addTarget(self, action: #selector(self.checkTask(_:)), forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func checkTask(btn: UIButton) {
        guard let group = GroupUserDefault() else {
            return
        }
        
        self.alltasks.removeAtIndex(btn.tag)
        self.todayTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: btn.tag, inSection: 0)], withRowAnimation: .Automatic)
        self.updateContent()
        group.moveTaskFinish(btn.tag)
        let reloadIndexs =
            (btn.tag..<self.alltasks.count).map( { NSIndexPath(forRow: $0, inSection: 0) } )
        self.todayTableView.reloadRowsAtIndexPaths(reloadIndexs, withRowAnimation: .None)
    }
}
