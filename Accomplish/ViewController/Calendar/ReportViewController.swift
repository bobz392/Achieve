//
//  ReportViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/7.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

class ReportViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    private let checkInDate: NSDate
    private var taskList: Results<Task>? = nil
    
    init(checkInDate: NSDate) {
        self.checkInDate = checkInDate
        super.init(nibName: "ReportViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.checkInDate = NSDate()
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
        
        self.taskList = RealmManager.shareManager.queryTaskList(self.checkInDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = colors.cloudColor

        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        let cancelIcon = FAKFontAwesome.arrowLeftIconWithSize(kBackButtonCorner)
        cancelIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.backButton.setAttributedTitle(cancelIcon.attributedString(), forState: .Normal)

    }
    
    private func initializeControl() {
        configTableView()
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), forControlEvents: .TouchUpInside)
        
        if checkInDate.isToday() {
            self.titleLabel.text = Localized("schedule") + Localized("today")
        } else if checkInDate.isTomorrow() {
            self.titleLabel.text = Localized("schedule") + Localized("tomorrow")
        } else if checkInDate.isYesterday() {
            self.titleLabel.text = Localized("schedule") + Localized("yesterday")
        } else {
            self.titleLabel.text = Localized("schedule") + " "
                + checkInDate.formattedDateWithStyle(.MediumStyle)
        }
    }
    
    // MARK: - actions
    func backAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configTableView() {
        self.scheduleTableView.clearView()
        self.scheduleTableView.registerNib(ScheduleTableViewCell.nib, forCellReuseIdentifier: ScheduleTableViewCell.reuseId)
        
        self.scheduleTableView.tableFooterView = UIView()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ScheduleTableViewCell.reuseId, forIndexPath: indexPath) as! ScheduleTableViewCell
        
        cell.setTop(indexPath.row == 0)
        cell.setBottom(indexPath.row == (self.taskList?.count ?? 0) - 1)
        if let task = self.taskList?[indexPath.row] {
            cell.config(task)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ScheduleTableViewCell.rowHeight
    }
}