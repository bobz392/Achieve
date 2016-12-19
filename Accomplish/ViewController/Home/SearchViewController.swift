//
//  SearchViewController.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/22.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController {
    
    @IBOutlet weak var topHolderView: UIView!
    @IBOutlet weak var searchHolderView: UIView!
    @IBOutlet weak var searchIconLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var hintLabel: UILabel!
    
    private let searchCorner: CGFloat = 16
    fileprivate var searchResult = Array<Task>()
    fileprivate var searchInProgress = false
    
    fileprivate var selectedIndex: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardManager.sharedManager.setShowHander { [unowned self] in
            self.tableViewBottomConstraint.constant = KeyboardManager.keyboardHeight
            
            UIView.animate(withDuration: KeyboardManager.duration, delay: kKeyboardAnimationDelay, options: UIViewAnimationOptions(), animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
        self.searchTextField.becomeFirstResponder()
        
        guard let indexPath = self.selectedIndex else { return }
        self.searchTableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardManager.sharedManager.closeNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.view.backgroundColor = colors.mainGreenColor
        self.topHolderView.backgroundColor = colors.cloudColor
        self.topHolderView.layer.cornerRadius = self.searchCorner
        
        self.searchIconLabel
            .createIconText(iconSize: 20, icon: "fa-search", color: colors.mainGreenColor)
        
        self.searchHolderView.backgroundColor = colors.placeHolderTextColor
        self.searchTextField.tintColor = colors.mainGreenColor
        self.searchTextField.textColor = Colors.mainTextColor
        
        self.searchTableView.separatorColor = colors.cloudColor
        
        self.hintLabel.textColor = colors.cloudColor
    }
    
    fileprivate func initializeControl() {
        self.searchHolderView.layer.cornerRadius = self.searchCorner
        
        self.searchTextField.placeholder = Localized("searchHolder")
        self.configTableView()
        
        self.hintLabel.text = Localized("searchStart")
    }
    
    // MARK: - actions
    func backAction() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func enterTask(_ task: Task) {
        let taskVC = TaskDetailViewController(task: task, canChange: false)
        self.navigationController?.pushViewController(taskVC, animated: true)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    fileprivate func configTableView() {
        self.searchTableView
            .register(SearchTableViewCell.nib, forCellReuseIdentifier: SearchTableViewCell.reuseId)
        self.searchTableView.clearView()
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
        return SearchTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseId, for: indexPath) as! SearchTableViewCell
        
        let task = self.searchResult[indexPath.row]
        cell.taskTitleLabel.text = task.getNormalDisplayTitle()
        cell.taskStartLabel.text =
            task.createdDate?.getDateString()
        
        return cell
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.backAction()
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
            self.hintLabel.text = Localized("searchStart")
            self.hintLabel.isHidden = false
            return true
        }
        
        self.hintLabel.text = Localized("searchNoResult")
        self.hintLabel.isHidden = true
        
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
