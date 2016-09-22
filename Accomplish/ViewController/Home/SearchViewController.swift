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
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
    
    private let searchCorner: CGFloat = 16
    private var searchResult = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardManager.sharedManager.setShowHander { [unowned self] in
            self.toolViewBottomConstraint.constant = KeyboardManager.keyboardHeight
            
            UIView.animate(withDuration: KeyboardManager.duration, delay: kKeyboardAnimationDelay, options: UIViewAnimationOptions(), animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
        self.searchTextField.becomeFirstResponder()
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
     
        self.toolView.addTopShadow()
        self.toolView.backgroundColor = colors.cloudColor
        
        self.backButton.tintColor = colors.mainGreenColor
    }
    
    fileprivate func initializeControl() {
        self.searchHolderView.layer.cornerRadius = self.searchCorner
        
        self.searchTextField.placeholder = Localized("searchHolder")
        
        self.backButton.setTitle(Localized("cancel"), for: .normal)
        self.backButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseId, for: indexPath) as! SearchTableViewCell
        
        return cell
    }
}
