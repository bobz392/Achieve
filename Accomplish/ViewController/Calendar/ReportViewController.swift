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
    fileprivate var taskList: Results<Task>
    fileprivate var cellHeightCache: Array<CGFloat>
    
    init(checkInDate: NSDate) {
        self.checkInDate = checkInDate
        self.taskList = RealmManager.shareManager.queryTaskList(checkInDate)
        self.cellHeightCache = Array(repeating: 0, count: self.taskList.count)
        super.init(nibName: "ReportViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.checkInDate = NSDate()
        self.taskList = RealmManager.shareManager.queryTaskList(self.checkInDate)
        self.cellHeightCache = [CGFloat]()
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
        
        
        
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
        let report = ReportGenerator().generateReport(taskList: self.taskList)
        let activeViewController =
            UIActivityViewController(activityItems: [report], applicationActivities: nil)
        
        self.present(activeViewController, animated: true) {
            
        }
        
        let activeBlock: UIActivityViewControllerCompletionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error:Swift.Error?) -> Swift.Void in
            Logger.log("returnedItems = \(returnedItems)")
            Logger.log("activityType = \(activityType?.rawValue)")
            Logger.log("completed = \(completed)")
        }
        
        activeViewController.completionWithItemsHandler = activeBlock
    }
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configTableView() {
        self.scheduleTableView.clearView()
        self.scheduleTableView.register(ScheduleTableViewCell.nib, forCellReuseIdentifier: ScheduleTableViewCell.reuseId)
        
        self.scheduleTableView.tableFooterView = UIView()
        guard let headerView = ScheduleHeaderView.loadNib(self) else { return }
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: screenBounds.width, height: 50))
        
        headerView.titleLableView.text = self.checkInDate.getDateString()
        self.scheduleTableView.tableHeaderView = headerView
        self.scheduleTableView.tableHeaderView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.scheduleTableView)
            make.height.equalTo(50)
            make.trailing.equalTo(self.scheduleTableView)
            make.leading.equalTo(self.scheduleTableView)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = self.taskList[indexPath.row]
        let taskVC = TaskDetailViewController(task: task, canChange: task.createdDate?.isToday() ?? false)
        self.navigationController?.pushViewController(taskVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseId, for: indexPath) as! ScheduleTableViewCell
        
        cell.setTop(indexPath.row == 0)
        cell.setBottom( indexPath.row == (self.taskList.count - 1) )
        
        cell.config(self.taskList[indexPath.row])
        
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
            cell.config(self.taskList[indexPath.row])
            let height = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            self.cellHeightCache[indexPath.row] = height
            return height
        }
    }
}
