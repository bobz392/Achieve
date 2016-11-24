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
    @IBOutlet weak var methodNameTextField: UITextField!
    @IBOutlet weak var methodTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var methodRepeatLabel: UILabel!
    @IBOutlet weak var methodRepeatButton: UIButton!
    
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
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor, status: .normal)
    }
    
    fileprivate func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        self.methodNameTextFieldHolderView.addSmallShadow()
        self.methodNameTextFieldHolderView.layer.cornerRadius = kCardViewSmallCornerRadius
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.methodTableView.clearView()
        self.methodTableView.register(TimeManagerEditorTableViewCell.nib,
                                      forCellReuseIdentifier: TimeManagerEditorTableViewCell.reuseId)
        
        self.methodNameTextField.isUserInteractionEnabled = self.canChange
        self.methodNameTextField.text = self.timeMethod.name
        let repeatTitle = self.timeMethod.repeatTimes == kTimeMethodInfiniteRepeat ?
                Localized("infiniteRepeat") : "\(self.timeMethod.repeatTimes)"
        self.methodRepeatButton.setTitle(repeatTitle, for: .normal)
        self.methodRepeatLabel.text = Localized("repeatNumber")
    }

    // MARK: - actions
    func backAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
}

extension TimeManagerEditorViewController: UITableViewDelegate, UITableViewDataSource {
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
