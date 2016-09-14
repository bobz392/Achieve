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
    
    //    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    
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
        
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                         icon: backButtonIconString, color: colors.mainGreenColor,
                                         status: .Normal)
        
        self.exportButton.buttonColor(colors)
        self.exportButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                           icon: "fa-share", color: colors.mainGreenColor, status: .Normal)
    }
    
    private func initializeControl() {
        configTableView()
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), forControlEvents: .TouchUpInside)
        
        self.exportButton.addShadow()
        self.exportButton.layer.cornerRadius = kBackButtonCorner
        self.exportButton.addTarget(self, action: #selector(self.extportAction), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - actions
    func backAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func extportAction() {
        let activeViewController = UIActivityViewController(activityItems: [self.generateReport()], applicationActivities: nil)
        self.presentViewController(activeViewController, animated: true) {
            
        }
        
        let myblock: UIActivityViewControllerCompletionWithItemsHandler = {(activityType: String?, completed: Bool , returnedItems: Array?, activityError: NSError?) -> Void in
            debugPrint(activityType)
            debugPrint(completed)
            debugPrint(returnedItems)
            debugPrint(activityError)
        }
        activeViewController.completionWithItemsHandler = myblock
    }
    
    private func generateReport() -> String {
        let string = self.taskList?.reduce("", combine: { (content, task) -> String in
            return content + task.getNormalDisplayTitle() + "\n"
        })
        guard let report = string else {
            return "No report today"
        }
        return report
    }
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configTableView() {
        self.scheduleTableView.clearView()
        self.scheduleTableView.registerNib(ScheduleTableViewCell.nib, forCellReuseIdentifier: ScheduleTableViewCell.reuseId)
        
        self.scheduleTableView.tableFooterView = UIView()
        guard let headerView = ScheduleHeaderView.loadNib(self) else { return }
        
        headerView.frame = CGRect(origin: CGPointZero, size: CGSize(width: screenBounds.width, height: 50))
        if checkInDate.isToday() {
            headerView.titleLableView.text = Localized("schedule") + Localized("today")
        } else if checkInDate.isTomorrow() {
            headerView.titleLableView.text = Localized("schedule") + Localized("tomorrow")
        } else if checkInDate.isYesterday() {
            headerView.titleLableView.text = Localized("schedule") + Localized("yesterday")
        } else {
            headerView.titleLableView.text = Localized("schedule") + " "
                + checkInDate.formattedDateWithStyle(.MediumStyle)
        }
        self.scheduleTableView.tableHeaderView = headerView
        self.scheduleTableView.tableHeaderView?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(self.scheduleTableView)
            make.height.equalTo(50)
            make.leading.equalTo(self.scheduleTableView)
        })
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