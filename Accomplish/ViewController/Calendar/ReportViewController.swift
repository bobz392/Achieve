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
    
    fileprivate let checkInDate: NSDate
    fileprivate var taskList: Results<Task>? = nil
    fileprivate var cellHeightCache = Array<CGFloat>()
    
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
        
        let tasks = RealmManager.shareManager.queryTaskList(self.checkInDate)
        self.taskList = tasks
        self.cellHeightCache = Array(repeating: 0, count: tasks.count)
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
                                         status: .normal)
        
        self.exportButton.buttonColor(colors)
        self.exportButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                           icon: "fa-share", color: colors.mainGreenColor,
                                           status: .normal)
    }
    
    fileprivate func initializeControl() {
        configTableView()
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.exportButton.addShadow()
        self.exportButton.layer.cornerRadius = kBackButtonCorner
        self.exportButton.addTarget(self, action: #selector(self.extportAction), for: .touchUpInside)
    }
    
    // MARK: - actions
    func backAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    func extportAction() {
        let activeViewController = UIActivityViewController(activityItems: [self.generateReport()], applicationActivities: nil)
        
        self.present(activeViewController, animated: true) {
            
        }
        
        let activeBlock: UIActivityViewControllerCompletionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error:Swift.Error?) -> Swift.Void in
                SystemInfo.log("returnedItems = \(returnedItems)")
                SystemInfo.log("activityType = \(activityType?.rawValue)")
                SystemInfo.log("completed = \(completed)")
        }
        
        activeViewController.completionWithItemsHandler = activeBlock
    }
    
    fileprivate func generateReport() -> String {
        let string = self.taskList?.reduce("", { (content, task) -> String in
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
        self.scheduleTableView.register(ScheduleTableViewCell.nib, forCellReuseIdentifier: ScheduleTableViewCell.reuseId)
        
        self.scheduleTableView.tableFooterView = UIView()
        guard let headerView = ScheduleHeaderView.loadNib(self) else { return }
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: screenBounds.width, height: 50))
        if checkInDate.isToday() {
            headerView.titleLableView.text = Localized("schedule") + Localized("today")
        } else if checkInDate.isTomorrow() {
            headerView.titleLableView.text = Localized("schedule") + Localized("tomorrow")
        } else if checkInDate.isYesterday() {
            headerView.titleLableView.text = Localized("schedule") + Localized("yesterday")
        } else {
            headerView.titleLableView.text = Localized("schedule") + " "
                + checkInDate.formattedDate(with: .medium)
        }
        self.scheduleTableView.tableHeaderView = headerView
        self.scheduleTableView.tableHeaderView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.scheduleTableView)
            make.height.equalTo(50)
            make.trailing.equalTo(self.scheduleTableView)
            make.leading.equalTo(self.scheduleTableView)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseId, for: indexPath) as! ScheduleTableViewCell
        
        cell.setTop(indexPath.row == 0)
        cell.setBottom(indexPath.row == (self.taskList?.count ?? 0) - 1)
        if let task = self.taskList?[indexPath.row] {
            cell.config(task)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScheduleTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        return ScheduleTableViewCell.rowHeight
        if self.cellHeightCache[indexPath.row] != 0 {
            return self.cellHeightCache[indexPath.row]
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseId) as! ScheduleTableViewCell
            
            if let task = self.taskList?[indexPath.row] {
                cell.config(task)
            }
            let height = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            self.cellHeightCache[indexPath.row] = height
            return height
        }
    }
}
