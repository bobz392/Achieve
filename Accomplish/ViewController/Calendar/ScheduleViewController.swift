//
//  ReportViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/7.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleViewController: BaseViewController {
    
    fileprivate let scheduleTableView = UITableView()
    
    fileprivate let checkInDate: NSDate
    fileprivate var taskList: Results<Task>
    fileprivate var cellHeightCache: Array<CGFloat>
    
    init(checkInDate: NSDate) {
        self.checkInDate = checkInDate
        self.taskList = RealmManager.shared.queryTaskList(checkInDate)
        self.cellHeightCache = Array(repeating: 0, count: self.taskList.count)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
        
        if #available(iOS 9.0, *) {
            self.registerPerview(sourceViewBlock: { [unowned self] () -> UIView in
                return self.scheduleTableView
                }, previewViewControllerBlock: { [unowned self] (previewingContext: UIViewControllerPreviewing, location: CGPoint) -> UIViewController? in
                    guard let index = self.scheduleTableView.indexPathForRow(at: location),
                        let cell = self.scheduleTableView.cellForRow(at: index) else { return nil }
                    let task = self.taskList[index.row]
                    let taskVC = TaskDetailViewController(task: task, canChange: false)
                    previewingContext.sourceRect = cell.frame
                    return taskVC
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: true)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        let dateText = self.checkInDate.formattedDate(with: .medium) ?? ""
        let dateLabel = self.createTitleLabel(titleText: dateText, style: .left)
        dateLabel.textColor = Colors.mainIconColor
        
        let exportButton = UIButton(type: .custom)
        exportButton.buttonWithIcon(icon: Icons.export.iconString())
        bar.addSubview(exportButton)
        exportButton.snp.makeConstraints { (make) in
            make.width.equalTo(kBarIconSize)
            make.height.equalTo(kBarIconSize)
            make.top.equalTo(bar).offset(26)
            make.right.equalToSuperview().offset(-12)
        }
        exportButton.addTarget(self, action: #selector(self.extportAction), for: .touchUpInside)
        
        self.view.addSubview(self.scheduleTableView)
        self.scheduleTableView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.scheduleTableView.delegate = self
        self.scheduleTableView.dataSource = self
        self.scheduleTableView.clearView()
        self.scheduleTableView.separatorStyle = .none
        self.scheduleTableView.tableFooterView = UIView()
        self.scheduleTableView
            .register(ScheduleTableViewCell.nib,
                      forCellReuseIdentifier: ScheduleTableViewCell.reuseId)
    }
    
    // MARK: - actions
    @objc func extportAction() {
        let report = ReportGenerator().generateReport(taskList: self.taskList)
        let activeViewController =
            UIActivityViewController(activityItems: [report], applicationActivities: nil)
        
        self.present(activeViewController, animated: true) {
            
        }
        
        let activeBlock: UIActivityViewController.CompletionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error:Swift.Error?) -> Swift.Void in
            Logger.log("returnedItems = \(returnedItems)")
            Logger.log("activityType = \(activityType?.rawValue)")
            Logger.log("completed = \(completed)")
        }
        
        activeViewController.completionWithItemsHandler = activeBlock
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        if self.cellHeightCache[indexPath.row] != 0 {
            return self.cellHeightCache[indexPath.row]
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseId) as! ScheduleTableViewCell
            cell.config(self.taskList[indexPath.row])
            let height = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self.cellHeightCache[indexPath.row] = height
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScheduleHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView =
            ScheduleHeaderView.loadNib(self, title: Localized("schedule"))
            else { return nil }
    
        return headerView
    }
}
