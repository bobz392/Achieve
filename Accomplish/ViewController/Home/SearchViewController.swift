//
//  SearchViewController.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/22.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: BaseViewController {
    
    @IBOutlet weak var topHolderView: UIView!
    @IBOutlet weak var searchHolderView: UIView!
    @IBOutlet weak var searchIconLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    private let searchCorner: CGFloat = 16
    fileprivate var searchResult: Results<Task>? = nil
    fileprivate var searchInProgress = false
    
    fileprivate let searchDispatch =
        DispatchQueue.init(label: "search.dispatch.queue", qos:
            DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 0))
    
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
            .createIconText(iconSize: 20, icon: "fa-search", color: colors.cloudColor)
        
        self.searchHolderView.backgroundColor = colors.placeHolderTextColor
        self.searchTextField.tintColor = colors.mainGreenColor
        self.searchTextField.textColor = colors.mainTextColor
        
        self.searchTableView.separatorColor = colors.cloudColor
    }
    
    fileprivate func initializeControl() {
        self.searchHolderView.layer.cornerRadius = self.searchCorner
        
        self.searchTextField.placeholder = Localized("searchHolder")
        self.configTableView()
    }
    
    // MARK: - actions
    func cancelAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
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
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResult?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseId, for: indexPath) as! SearchTableViewCell
        
        if let task = self.searchResult?[indexPath.row] {
            cell.taskTitleLabel.text = task.getNormalDisplayTitle()
            cell.taskStartLabel.text =
                task.createdDate?.formattedDate(with: DateFormatter.Style.medium)
        }
        
        return cell
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.cancelAction()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text
        text?.replace(range, replacement: string)
        guard let realString = text else {
            return true
        }
        
        if !self.searchInProgress {
            self.queryResult(queryString: realString)
        }
        return true
    }
    
    fileprivate func queryResult(queryString: String) {
        self.searchInProgress = true
        
        self.searchDispatch.async {
            let tasks = RealmManager.shareManager
                .searchTasks(queryString: queryString, realmInThatThread: try! Realm())
            dispatch_async_main { [unowned self] in
                self.searchResult? = tasks
                self.searchTableView.reloadData()
                self.searchInProgress = false
            }
        }
    }
}
