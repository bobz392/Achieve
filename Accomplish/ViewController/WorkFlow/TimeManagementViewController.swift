//
//  TimeManagementViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/10/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagementViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var methodTableView: UITableView!
    @IBOutlet weak var createMethodButton: UIButton!
    
    // TODO - first come to this page no need to query
    fileprivate var timeMethods = RealmManager.shared.allTimeMethods()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.configMainUI()
        self.initializeControl()
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
        let colors = Colors()
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor, status: .normal)
        self.createMethodButton.tintColor = colors.linkTextColor
        self.createMethodButton.backgroundColor = colors.cloudColor
        self.createMethodButton.addTopShadow()
    }
    
    fileprivate func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.createMethodButton.setTitle(Localized("createTimeManagement"), for: .normal)
        self.createMethodButton.addTarget(self, action: #selector(self.newMethodAction), for: .touchUpInside)
        
        self.titleLabel.text = Localized("timeManagementSetting")
        
        self.configMethodTableView()
    }
    
    // MARK: - actions
    func backAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    func newMethodAction() {
        let timeMethod = TimeMethod()
        let group = TimeMethodGroup()
        group.addDefaultGroupAndItem()
        timeMethod.groups.append(group)
        
        let timeManagerEditorVC =
            TimeManagerEditorViewController(method: timeMethod, canChange: true, isCreate: true)
        self.navigationController?.pushViewController(timeManagerEditorVC, animated: true)
    }
}

extension TimeManagementViewController: UITableViewDelegate, UITableViewDataSource {
    fileprivate func configMethodTableView() {
        self.methodTableView.clearView()
        self.methodTableView.register(TimeMethodTableViewCell.nib,
                                      forCellReuseIdentifier: TimeMethodTableViewCell.reuseId)
        self.methodTableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeMethodTableViewCell.reuseId,
                                                 for: indexPath) as! TimeMethodTableViewCell
        cell.configCell(method: self.timeMethods[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TimeMethodTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let canChange = indexPath.row != 0
        let timeManagerEditorVC =
            TimeManagerEditorViewController(method: self.timeMethods[indexPath.row],
                                            canChange: canChange)
        self.navigationController?.pushViewController(timeManagerEditorVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            RealmManager.shared.deleteObject(self.timeMethods[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        default:
            break
        }
    }
}
