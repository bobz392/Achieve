//
//  SearchViewController.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/22.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController {
    
    fileprivate let searchTextField = UITextField()
    fileprivate let searchTableView = UITableView()
    fileprivate let hintLabel = UILabel()

    fileprivate var searchResult = Array<Task>()
    fileprivate var searchInProgress = false
    fileprivate var selectedIndex: IndexPath? = nil
    fileprivate var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
        
        if #available(iOS 9.0, *) {
            self.registerPerview(sourceViewBlock: { [unowned self] () -> UIView in
                return self.searchTableView
                }, previewViewControllerBlock: { [unowned self] (previewingContext: UIViewControllerPreviewing, location: CGPoint) -> UIViewController? in
                    guard let index = self.searchTableView.indexPathForRow(at: location),
                        let cell = self.searchTableView.cellForRow(at: index) else { return nil }
                    let task = self.searchResult[index.row]
                    let taskVC = TaskDetailViewController(task: task, canChange: false)
                    previewingContext.sourceRect = cell.frame
                    self.searchTextField.resignFirstResponder()
                    return taskVC
            })
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.keyboardAction()
        self.searchTextField.becomeFirstResponder()

        guard let indexPath = self.selectedIndex else { return }
        self.searchTableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        KeyboardManager.sharedManager.closeNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: true)
        let leftButton = self.createLeftBarButton(icon: Icons.back)
        leftButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        bar.addSubview(self.searchTextField)
        self.searchTextField.font = appFont(size: 14)
        self.searchTextField.textColor = Colors.mainTextColor
        self.searchTextField.clearButtonMode = .whileEditing
        self.searchTextField.tintColor = Colors.mainTextColor
        self.searchTextField.delegate = self
        self.searchTextField.placeholder = Localized("searchHolder")
        self.searchTextField.returnKeyType = .done
        self.searchTextField.snp.makeConstraints { (make) in
            make.left.equalTo(leftButton.snp.right).offset(2)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(leftButton)
            make.height.equalTo(leftButton)
        }
        
        self.configTableView(bar: bar)
        
        self.hintLabel.font = appFont(size: 14)
        self.hintLabel.textColor = Colors.mainIconColor
        self.view.addSubview(self.hintLabel)
        self.hintLabel.isHidden = true
        self.hintLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.searchTableView)
        }
    }
    
    // MARK: - actions
    fileprivate func keyboardAction() {
        KeyboardManager.sharedManager.setShowHander { [unowned self] in
            self.searchTableView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().offset(-KeyboardManager.keyboardHeight)
            })
            
            UIView.animate(withDuration: KeyboardManager.duration, delay: kKeyboardAnimationDelay, options: .curveEaseInOut, animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
        KeyboardManager.sharedManager.setHideHander { [unowned self] in
            self.searchTableView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview()
            })
            
            UIView.animate(withDuration: KeyboardManager.duration, delay: kKeyboardAnimationDelay, options: .curveEaseInOut, animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    fileprivate func enterTask(_ task: Task) {
        self.searchTextField.resignFirstResponder()
        let taskVC = TaskDetailViewController(task: task, canChange: false)
        self.navigationController?.pushViewController(taskVC, animated: true)
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    fileprivate func configTableView(bar: UIView) {
        self.view.addSubview(self.searchTableView)
        self.searchTableView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.searchTableView.clearView()
        self.searchTableView.separatorStyle = .none
        self.searchTableView.tableFooterView = UIView()
        self.searchTableView
            .register(TaskTableViewCell.nib, forCellReuseIdentifier: TaskTableViewCell.reuseId)
        self.searchTableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        let task = self.searchResult[indexPath.row]
        self.enterTask(task)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.clearView()
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseId, for: indexPath) as! TaskTableViewCell
        
        let task = self.searchResult[indexPath.row]
        cell.configCellUse(task, enableSwipe: false)
        cell.configCellForSearch(search: self.searchString)
        return cell
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.hintLabel.isHidden = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var text = textField.text
        text?.replace(range, replacement: string)
        guard let realString = text else {
            return true
        }
        
        guard realString.length() > 0 else {
            self.searchResult.removeAll()
            self.searchTableView.reloadData()
            self.hintLabel.isHidden = true
            return true
        }
        
        self.hintLabel.text = Localized("searchNoResult")
        self.hintLabel.isHidden = true
        self.searchString = realString
        
        if !self.searchInProgress {
            self.queryResult(queryString: realString)
        }
        return true
    }
    
    fileprivate func queryResult(queryString: String) {
        self.searchInProgress = true
        
        let tasks = RealmManager.shared
            .searchTasks(queryString: queryString)
        
        self.searchResult.removeAll()
        self.searchResult.append(contentsOf: tasks)
        self.searchTableView.reloadData()
        self.searchInProgress = false
        self.hintLabel.isHidden = self.searchResult.count > 0
    }
    
}
