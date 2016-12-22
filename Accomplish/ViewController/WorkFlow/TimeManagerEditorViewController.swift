//
//  TimeManagerEditorViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagerEditorViewController: BaseViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var methodNameTextFieldHolderView: UIView!
    @IBOutlet weak var methodNameButton: UIButton!
    @IBOutlet weak var methodTableView: UITableView!
    @IBOutlet weak var addGroupButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var methodRepeatTitleLabel: UILabel!
    @IBOutlet weak var methodRepeatLabel: UILabel!
    
    @IBOutlet weak var backButtonCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var addGroupButtonCenterConstraint: NSLayoutConstraint!
    
    
    internal var timeMethodInputView: TimeMethodInputView? = nil
    
    fileprivate let timeMethod: TimeMethod
    fileprivate let canChange: Bool
    fileprivate let isCreate: Bool
    
    init(method: TimeMethod, canChange: Bool, isCreate: Bool = false) {
        self.timeMethod = method
        self.canChange = canChange
        self.isCreate = isCreate
        super.init(nibName: "TimeManagerEditorViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.timeMethod = TimeMethod()
        self.canChange = false
        self.isCreate = false
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isCreate {
            self.changeMethodNameAction()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.cardView.backgroundColor = Colors.cloudColor
        
        self.view.backgroundColor = colors.mainGreenColor
        self.methodNameButton.setTitleColor(Colors.mainTextColor, for: .normal)
        self.methodNameButton.setTitleColor(Colors.mainTextColor, for: .disabled)
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor, status: .normal)
        self.addGroupButton.buttonColor(colors)
        self.addGroupButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: "fa-plus",
                                         color: colors.mainGreenColor, status: .normal)
        
        self.methodRepeatTitleLabel.textColor = Colors.mainTextColor
        self.methodRepeatLabel.textColor = colors.mainGreenColor
        
        if self.isCreate || self.canChange {
            self.addGroupButtonCenterConstraint.constant = 50
            self.backButtonCenterConstraint.constant = -50
            // 进来的时候首先持久化临时创建的 timeMethod，返回的时候根据用户的选择来决定是否删除
            // 其次是对于后面的所有操作这样可以一致来对待
            // 最次是可以防止突发情况导致的编辑未保存，例如关app 关机 等
            RealmManager.shared.writeObject(self.timeMethod)
        } else {
            self.addGroupButtonCenterConstraint.constant = 0
            self.addGroupButton.isHidden = true
            self.backButtonCenterConstraint.constant = 0
        }
    }
    
    fileprivate func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewSmallCornerRadius
        self.methodNameTextFieldHolderView.addSmallShadow()
        self.methodNameTextFieldHolderView.layer.cornerRadius = kCardViewSmallCornerRadius
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.addGroupButton.addShadow()
        self.addGroupButton.layer.cornerRadius = kBackButtonCorner
        self.addGroupButton
            .addTarget(self, action: #selector(self.addGroupAction), for: .touchUpInside)
        
        self.configTableView()
        
        self.methodNameButton.isEnabled = self.canChange
        self.methodNameButton.setTitle(self.timeMethod.name, for: .normal)
        self.methodNameButton
            .addTarget(self, action: #selector(self.changeMethodNameAction), for: .touchUpInside)
        
        self.methodRepeatTitleLabel.text = Localized("aliase")
        self.methodRepeatLabel.text = self.timeMethod.timeMethodAliase
        
        self.checkInputViewCreated()
    }
    
    // MARK: - actions
    func backAction() {
        if self.isCreate {
            let alert = UIAlertController(title: Localized("saveTimeMethod"),
                                          message: nil, preferredStyle: .actionSheet)
            let saveAction = UIAlertAction(title: Localized("save"), style: .destructive,
                                           handler: { [unowned self] (action) in
                self.pop()
            })
            
            let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel, handler: { (action) in
                RealmManager.shared.deleteObject(self.timeMethod)
                self.pop()
            })
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            self.navigationController?.present(alert, animated: true, completion: nil)
            
        } else {
            self.pop()
        }
    }
    
    fileprivate func pop() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    func addGroupAction() {
        RealmManager.shared.updateObject { [unowned self] in
            let group = TimeMethodGroup()
            group.addDefaultGroupAndItem()
            self.timeMethod.groups.append(group)
            let indexPath = IndexPath(row: self.timeMethod.groups.count - 1, section: 0)
            self.methodTableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    func changeMethodNameAction() {
        guard let view = self.timeMethodInputView else { return }
        view.moveIn(twoTitles: [Localized("methodName"), Localized("aliase")],
                    twoHolders: [Localized("enterMethodName"), Localized("enterMethodAliase")],
                    twoContent: [self.timeMethod.name, self.timeMethod.timeMethodAliase],
                    saveBlock: { (first, second) in
                        RealmManager.shared.updateObject { [unowned self] in
                            self.timeMethod.name = first
                            if let s = second?.trim() {
                                if s.length() > 0 {
                                    self.timeMethod.timeMethodAliase = s
                                }
                            }
                            self.methodNameButton.setTitle(first, for: .normal)
                            self.methodRepeatLabel.text = second
                        }
        })
    }
    
    /**
     make sure input view created
     */
    fileprivate func checkInputViewCreated() {
        guard  let _ = self.timeMethodInputView else {
            let view = TimeMethodInputView.loadNib(self)!
            self.timeMethodInputView = view
            self.view.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.top.equalTo(self.view)
                make.bottom.equalTo(self.view)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
            })
            view.layoutIfNeeded()
            return
        }
    }
}

extension TimeManagerEditorViewController: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate func configTableView() {
        self.methodTableView.clearView()
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: 15))
        headerView.clearView()
        self.methodTableView.tableHeaderView = headerView
        self.methodTableView.register(TimeManagerEditorTableViewCell.nib,
                                      forCellReuseIdentifier: TimeManagerEditorTableViewCell.reuseId)
    }
    
    fileprivate func deleteTimeMethodGroup(indexPath: IndexPath) {
        let title = Localized("delete") +
            String(format: Localized("timeManageGroupName"), indexPath.row + 1) + " ?"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: Localized("delete"), style: .destructive, handler: { [unowned self] (action) in
            RealmManager.shared.updateObject {
                self.timeMethod.groups.remove(objectAtIndex: indexPath.row)
            }
            self.methodTableView.deleteRows(at: [indexPath], with: .automatic)
        })
        alert.addAction(deleteAction)
        
        self.present(alert, animated: true, completion: nil)
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
