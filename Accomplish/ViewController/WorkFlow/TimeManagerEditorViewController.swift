//
//  TimeManagerEditorViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagerEditorViewController: BaseViewController {
    
//    @IBOutlet weak var cardView: UIView!
//    @IBOutlet weak var methodNameTextFieldHolderView: UIView!
//    @IBOutlet weak var methodNameButton: UIButton!
//    
//    @IBOutlet weak var addGroupButton: UIButton!
//    @IBOutlet weak var backButton: UIButton!
//    @IBOutlet weak var methodRepeatTitleLabel: UILabel!
//    @IBOutlet weak var methodRepeatLabel: UILabel!
//    
//    @IBOutlet weak var backButtonCenterConstraint: NSLayoutConstraint!
//    @IBOutlet weak var addGroupButtonCenterConstraint: NSLayoutConstraint!
    
    fileprivate let methodTableView = UITableView()
    fileprivate lazy var timeMethodInputView = TimeMethodInputView.loadNib(self)!
    
    fileprivate let timeMethod: TimeMethod
    fileprivate let canChange: Bool
    
    init(method: TimeMethod, canChange: Bool) {
        self.timeMethod = method
        self.canChange = canChange
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.timeMethod = TimeMethod()
        self.canChange = false
        super.init(coder: aDecoder)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configMainUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: true)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        self.createTitleLabel(titleText: self.timeMethod.name, style: .left)
        self.configMethodTableView(bar: bar)
        
        if self.canChange {
            let addGroupButton = self.createPlusButton()
            addGroupButton.addTarget(self, action: #selector(self.addGroupAction), for: .touchUpInside)
        }
    }
    
    // MARK: - actions
    
    @objc func addGroupAction() {
        RealmManager.shared.updateObject { [unowned self] in
            let group = TimeMethodGroup()
            group.addDefaultGroupAndItem()
            self.timeMethod.groups.append(group)
            let indexPath = IndexPath(row: self.timeMethod.groups.count - 1, section: 0)
            self.methodTableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

}

extension TimeManagerEditorViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        self.methodTableView.allowsSelection = false
        self.methodTableView.separatorStyle = .none
        self.methodTableView.tableFooterView = UIView()
        self.methodTableView.register(TimeManagerEditorTableViewCell.nib,
                                      forCellReuseIdentifier: TimeManagerEditorTableViewCell.reuseId)
    }
    
    fileprivate func deleteTimeMethodGroup(indexPath: IndexPath) {
        RealmManager.shared.updateObject {
            self.timeMethod.groups.remove(at: indexPath.row)
        }
        
        self.methodTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeMethod.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: TimeManagerEditorTableViewCell.reuseId, for: indexPath) as! TimeManagerEditorTableViewCell
        cell.configCell(methodTime: self.timeMethod,
                        canChange: self.canChange, groupIndex: indexPath.row)

        cell.timeMethodInputView = self.timeMethodInputView
        cell.moveInBlock = { [unowned self] () -> UIView in
            self.view
        }
        cell.methodTableView = self.methodTableView
        cell.deleteBlock = { [unowned self] () -> Void in
            self.deleteTimeMethodGroup(indexPath: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = CGFloat(self.timeMethod.groups[indexPath.row].items.count)
        return TimeManagerEditorTableViewCell.defaultHeight +
            // 计算高度
            (CGFloat(self.canChange ? 1 : 0) + count) * ItemTableViewCell.rowHeight
    }
    
}
