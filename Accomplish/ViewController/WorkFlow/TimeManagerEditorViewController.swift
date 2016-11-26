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
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var methodRepeatTitleLabel: UILabel!
    @IBOutlet weak var methodRepeatLabel: UILabel!
    
    internal var timeMethodInputView: TimeMethodInputView? = nil
    
    fileprivate let timeMethod: TimeMethod
    fileprivate let canChange: Bool
    
    init(method: TimeMethod, canChange: Bool) {
        self.timeMethod = method
        self.canChange = canChange
        super.init(nibName: "TimeManagerEditorViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.timeMethod = TimeMethod()
        self.canChange = false
        super.init(coder: aDecoder)
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
        
        self.cardView.backgroundColor = colors.cloudColor
        
        self.view.backgroundColor = colors.mainGreenColor
        self.methodNameButton.setTitleColor(colors.mainTextColor, for: .normal)
        self.methodNameButton.setTitleColor(colors.mainTextColor, for: .disabled)
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor, status: .normal)
        
        self.methodRepeatTitleLabel.textColor = colors.mainTextColor
        self.methodRepeatLabel.textColor = colors.mainGreenColor
    }
    
    fileprivate func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        self.methodNameTextFieldHolderView.addSmallShadow()
        self.methodNameTextFieldHolderView.layer.cornerRadius = kCardViewSmallCornerRadius
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.configTableView()
        
        self.methodNameButton.isEnabled = self.canChange
        self.methodNameButton.setTitle(self.timeMethod.name, for: .normal)
        self.methodNameButton
            .addTarget(self, action: #selector(self.changeMethodNameAction), for: .touchUpInside)
        
        let repeatTitle = self.timeMethod.repeatTimes == kTimeMethodInfiniteRepeat ?
            Localized("infiniteRepeat") : "\(self.timeMethod.repeatTimes)"
        self.methodRepeatTitleLabel.text = Localized("repeatNumber")
        self.methodRepeatLabel.text = repeatTitle
        
        self.checkInputViewCreated()
    }
    
    // MARK: - actions
    func backAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    func changeMethodNameAction() {
        guard let view = self.timeMethodInputView else { return }
        view.moveIn(twoTitles: [Localized("methodName"), Localized("aliase")],
                    twoHolders: [Localized("enterMethodName"), Localized("enterMethodAliase")],
                    twoContent: [self.timeMethod.name, self.timeMethod.timeMethodAliase])
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeMethod.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: TimeManagerEditorTableViewCell.reuseId, for: indexPath) as! TimeManagerEditorTableViewCell
        cell.configCell(methodGroup: self.timeMethod.groups[indexPath.row],
                        canChange: self.canChange, groupIndex: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = CGFloat(self.timeMethod.groups[indexPath.row].items.count)
        return TimeManagerEditorTableViewCell.defaultHeight +
            // 计算高度
            (CGFloat(self.canChange ? 1 : 0) + count) * ItemTableViewCell.rowHeight
    }
}
