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
    
    var alltasks = [[String]]()
    let bottomHeight: CGFloat = 73
    
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
        self.allButton.layer.cornerRadius = 4
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
            self.infoLabel.text = String(format: Localized("taskTody"), taskCount)
            
            
            if taskCount > 5 {
                self.preferredContentSize = CGSize(width: 0, height: TodayTableViewCell.rowHeight * 5.0 + bottomHeight)
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
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
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
        
        cell.titleLabel.text = alltasks[indexPath.row][GroupUserDefault.taskTitleIndex]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
