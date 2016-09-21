//
//  TagViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/16.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TagViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var tagTableView: UITableView!
    @IBOutlet weak var newTagButton: UIButton!
    
    @IBOutlet weak var newTagShadowView: UIView!
    @IBOutlet weak var textFieldHolderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTagTextField: UITextField!
    @IBOutlet weak var realShadowView: UIView!
    @IBOutlet weak var holderView: UIView!
    
    fileprivate var allTags = RealmManager.shareManager.allTags()
    
    fileprivate let noTag = "noneTag"
    fileprivate var bagDict = Dictionary<String, Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        debugPrint(RealmManager.shareManager.allTags())
        self.configMainUI()
        self.initializeControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        guard let hintView = HintView.loadNib(self) else { return }
        //
        //        self.view.addSubview(hintView)
        //        hintView.snp.makeConstraints { (make) in
        //            make.center.equalTo(self.view)
        //            make.height.equalTo(150)
        //            make.width.equalTo(280)
        //        }
        //        let hints = [
        //            HintItem(iconName: "fa-arrow-right", hintDetail: "asd"),
        //            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdasd"),
        //            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdas]sad"),
        //            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdakjkasjl"),
        //        ]
        //        hintView.addHints(hints)
        
        let tasks = RealmManager.shareManager.queryTaskList(NSDate())
        
        for task in tasks {
            if let tag = task.tag {
                self.bagDict[tag] = (self.bagDict[tag] ?? 0) + 1
            } else {
                self.bagDict[noTag] = (self.bagDict[noTag] ?? 0) + 1
            }
        }
        
        self.tagTableView.reloadData()
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
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                         icon: backButtonIconString, color: colors.mainGreenColor,
                                         status: .normal)
        self.newTagButton.tintColor = colors.linkTextColor
        self.titleLabel.text = Localized("tag")
        
        self.newTagTextField.tintColor = colors.mainGreenColor
    }
    
    fileprivate func initializeControl() {
        self.configTableView()
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.newTagButton.setTitle(Localized("newTag"), for: .normal)
        self.newTagButton.addTarget(self, action: #selector(self.newTagAction), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeNewTagAction))
        self.newTagShadowView.addGestureRecognizer(tap)
        self.holderView.layer.cornerRadius = kCardViewCornerRadius
        
        self.newTagTextField.placeholder = Localized("newTag")
    }
    
    // MARK: - actions
    func backAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    func newTagAction() {
        self.newTagShadowView.isHidden = false
        
        UIView.animate(withDuration: kNormalAnimationDuration) { [unowned self] in
            self.realShadowView.alpha = 0.6
        }
        
        self.textFieldHolderTopConstraint.constant = 20
        UIView.animate(withDuration: kNormalAnimationDuration, delay: kNormalAnimationDuration, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: { [unowned self] in
            self.view.layoutIfNeeded()
        }) { [unowned self] (finish) in
            self.newTagTextField.becomeFirstResponder()
        }
    }
    
    func closeNewTagAction() {
        self.textFieldHolderTopConstraint.constant = -44
        self.newTagTextField.text = nil
        self.newTagTextField.resignFirstResponder()
        
        UIView.animate(withDuration: kNormalAnimationDuration, delay: kNormalAnimationDuration, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: { [unowned self] in
            self.view.layoutIfNeeded()
            self.realShadowView.alpha = 0
        }) { [unowned self] (finish) in
            self.newTagShadowView.isHidden = true
        }
    }
}

// MARK: - tableview datasource and delegate
extension TagViewController: UITableViewDelegate, UITableViewDataSource {
    fileprivate func configTableView() {
        self.tagTableView.clearView()
        
        self.tagTableView.register(TagTableViewCell.nib,
                                   forCellReuseIdentifier: TagTableViewCell.reuseId)
        
        self.tagTableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTags.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagTableViewCell.reuseId,
                                                 for: indexPath) as! TagTableViewCell
        
        if indexPath.row == 0 {
            cell.tagLabel.text = Localized(noTag)
            if let count = self.bagDict[noTag] {
                cell.todayCountLabel.text = String(format: Localized("tagToday"), count)
            }
        } else {
            let tag = allTags[indexPath.row - 1]
            cell.tagLabel.text = tag.name
            if let count = self.bagDict[tag.tagUUID] {
                cell.todayCountLabel.text = String(format: Localized("tagToday"), count)
            } else {
                cell.todayCountLabel.text = nil
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TagViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let tag = Tag()
        tag.tagUUID = NSDate().createTagUUID()
        tag.name = text
        let canSave = RealmManager.shareManager.saveTag(tag)
        if !canSave {
            HUD.sharedHUD.showOnce(Localized("tagExist"))
            return canSave
        } else {
            let index = IndexPath(row: self.allTags.count, section: 0)
            self.tagTableView.insertRows(at: [index], with: .automatic)
            self.closeNewTagAction()
            return textField.resignFirstResponder()
        }
    }
}
