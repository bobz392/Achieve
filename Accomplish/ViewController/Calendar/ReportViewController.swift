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
                                         status: UIControlState())
        
        self.exportButton.buttonColor(colors)
        self.exportButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                           icon: "fa-share", color: colors.mainGreenColor, status: UIControlState())
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
        
        let myblock: UIActivityViewControllerCompletionHandler = {(activityType: UIActivityType?, completed: Bool) -> Void in
            debugPrint(activityType)
            debugPrint(completed)
        }
        activeViewController.completionHandler = myblock
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
        if (checkInDate as NSDate).isToday() {
            headerView.titleLableView.text = Localized("schedule") + Localized("today")
        } else if (checkInDate as NSDate).isTomorrow() {
            headerView.titleLableView.text = Localized("schedule") + Localized("tomorrow")
        } else if (checkInDate as NSDate).isYesterday() {
            headerView.titleLableView.text = Localized("schedule") + Localized("yesterday")
        } else {
            headerView.titleLableView.text = Localized("schedule") + " "
                + (checkInDate as NSDate).formattedDate(with: .medium)
        }
        self.scheduleTableView.tableHeaderView = headerView
        self.scheduleTableView.tableHeaderView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.scheduleTableView)
            make.height.equalTo(50)
            make.leading.equalTo(self.scheduleTableView)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseId, for: indexPath) as! ScheduleTableViewCell
        
        cell.setTop((indexPath as NSIndexPath).row == 0)
        cell.setBottom(indexPath.row == (self.taskList?.count ?? 0) - 1)
        if let task = self.taskList?[indexPath.row] {
            cell.config(task)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScheduleTableViewCell.rowHeight
    }
}