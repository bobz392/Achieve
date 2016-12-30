//
//  TimeManagementViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/10/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagementViewController: BaseViewController {
    
    typealias SelectTMBlock = (TimeMethod) -> Void
    
    fileprivate let methodTableView = UITableView()
    
    // TODO - first come to this page no need to query
    fileprivate var timeMethods = RealmManager.shared.allTimeMethods()
    // 是是选择一个工作法开始，还是管理工作法
    fileprivate var isSelectTM: Bool
    fileprivate var selectTMBlock: SelectTMBlock? = nil
    
    init(isSelectTM: Bool, selectTMBlock: SelectTMBlock? = nil) {
        self.isSelectTM = isSelectTM
        self.selectTMBlock = selectTMBlock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isSelectTM = false
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.timeMethods = RealmManager.shared.allTimeMethods()
        self.methodTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: false)
        self.congfigMenuButton()
        let titleLabel = self.createTitleLabel(titleText: "")
        self.configMethodTableView(bar: bar)
        
        if self.isSelectTM == true {
            titleLabel.text = Localized("selectTimeManagement")
        } else {
            let createMethodButton = self.createPlusButton()
            createMethodButton.addTarget(self, action: #selector(self.newMethodAction), for: .touchUpInside)
            titleLabel.text = Localized("time_management")
        }
    }
    
    // MARK: - actions
    func newMethodAction() {
        let timeMethod = TimeMethod()
        timeMethod.name = Localized("defaultTimeManagerName")
        let group = TimeMethodGroup()
        group.addDefaultGroupAndItem()
        timeMethod.groups.append(group)
        
        let timeManagerEditorVC =
            TimeManagerEditorViewController(method: timeMethod, canChange: true, isCreate: true)
        self.navigationController?.pushViewController(timeManagerEditorVC, animated: true)
    }
}

extension TimeManagementViewController: UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {
    fileprivate func configMethodTableView(bar: UIView) {
        self.view.addSubview(self.methodTableView)
        self.methodTableView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.methodTableView.delegate = self
        self.methodTableView.dataSource = self
        self.methodTableView.clearView()
        self.methodTableView.separatorStyle = .none
        self.methodTableView.tableFooterView = UIView()
        self.methodTableView.register(TimeMethodTableViewCell.nib,
                                      forCellReuseIdentifier: TimeMethodTableViewCell.reuseId)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeMethodTableViewCell.reuseId,
                                                 for: indexPath) as! TimeMethodTableViewCell
        
        let canSwipe = indexPath.row != 0 && self.isSelectTM == false
        cell.configCell(method: self.timeMethods[indexPath.row], enableSwipe: canSwipe)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TimeMethodTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.isSelectTM {
            self.selectTMBlock?(self.timeMethods[indexPath.row])
            self.backAction()
        } else {
            let canChange = indexPath.row != 0
            let timeManagerEditorVC =
                TimeManagerEditorViewController(method: self.timeMethods[indexPath.row],
                                                canChange: canChange)
            self.navigationController?.pushViewController(timeManagerEditorVC, animated: true)
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        if let indexPath = self.methodTableView.indexPath(for: cell) {
            RealmManager.shared.deleteObject(self.timeMethods[indexPath.row ])
            self.methodTableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return true
    }

}

// MAKR: - drawer open close call back -- not prefect
extension TimeManagementViewController: MenuDrawerSlideStatusDelegate {
    func slideOpen(open: Bool) {
        self.leftBarButton?.isSelected = open
    }
}
