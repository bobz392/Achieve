//
//  TagViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/16.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TagViewController: BaseViewController {
    
    fileprivate let tagTableView = UITableView()
    
    @IBOutlet weak var newTagShadowView: UIView!
    @IBOutlet weak var textFieldHolderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTagTextField: UITextField!
    @IBOutlet weak var realShadowView: UIView!
    @IBOutlet weak var holderView: UIView!
    
    fileprivate var allTags = RealmManager.shared.allTags()
    fileprivate let noTag = "noneTag"
    fileprivate var bagDict = Dictionary<String, Int>()
    fileprivate var currentSelectedIndex: IndexPath? = nil
    fileprivate var tagChange: Bool = false
    
    var delegate: SwitchTagDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tasks = RealmManager.shared.queryTaskList(NSDate())
        self.bagDict.removeAll()
        
        for task in tasks {
            if let tagUUID = task.tagUUID {
                self.bagDict[tagUUID] = (self.bagDict[tagUUID] ?? 0) + 1
            }
        }
        self.bagDict[noTag] = tasks.count
        
        self.tagTableView.reloadData()
        
        let indexPath: IndexPath
        
        if let selectedTag = AppUserDefault().readString(kUserDefaultCurrentTagUUIDKey),
            let index = self.allTags.index(matching: "tagUUID = '\(selectedTag)'") {
            indexPath = IndexPath(row: index + 1, section: 0)
        } else {
            indexPath = IndexPath(row: 0, section: 0)
        }
        self.currentSelectedIndex = indexPath
        self.tagTableView.selectRow(at: self.currentSelectedIndex, animated: true, scrollPosition: .none)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        if self.tagChange {
            if let index = self.currentSelectedIndex {
                if index.row == 0 {
                    self.delegate?.switchTagTo(tag: nil)
                } else {
                    let tag = self.allTags[index.row - 1]
                    self.delegate?.switchTagTo(tag: tag)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: true)
        self.congfigMenuButton()
        self.createTitleLabel(titleText: Localized("tag"), style: .center)
        
        self.configTableView(bar: bar)
        let newTagButton = self.createPlusButton()
        newTagButton.addTarget(self, action: #selector(self.newTagAction), for: .touchUpInside)
        
        self.view.bringSubviewToFront(self.newTagShadowView)
        self.newTagTextField.placeholder = Localized("newTag")
        self.holderView.layer.cornerRadius = 4
    }
    
    // MARK: - actions
    @objc func newTagAction() {
        self.newTagShadowView.isHidden = false
        
        UIView.animate(withDuration: kNormalAnimationDuration) { [unowned self] in
            self.realShadowView.alpha = 0.6
        }
        self.newTagTextField.becomeFirstResponder()
        
        self.textFieldHolderTopConstraint.constant = 20
        UIView.animate(withDuration: kNormalAnimationDuration, delay: kNormalAnimationDuration, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: UIView.AnimationOptions(), animations: { [unowned self] in
            self.view.layoutIfNeeded()
        }) { [unowned self] (finish) in
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeNewTagAction))
            self.newTagShadowView.addGestureRecognizer(tap)
        }
    }
    
    @objc func closeNewTagAction() {
        self.textFieldHolderTopConstraint.constant = -44
        self.newTagTextField.text = nil
        self.newTagTextField.resignFirstResponder()
        if let tap = self.newTagShadowView.gestureRecognizers?.first {
            self.newTagShadowView.removeGestureRecognizer(tap)
        }
        
        UIView.animate(withDuration: kNormalAnimationDuration, delay: kNormalAnimationDuration, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIView.AnimationOptions(), animations: { [unowned self] in
            self.view.layoutIfNeeded()
            self.realShadowView.alpha = 0
        }) { [unowned self] (finish) in
            self.newTagShadowView.isHidden = true
        }
    }
}

// MARK: - tableview datasource and delegate
extension TagViewController: UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {
    fileprivate func configTableView(bar: UIView) {
        self.view.addSubview(self.tagTableView)
        self.tagTableView.delegate = self
        self.tagTableView.dataSource = self
        self.tagTableView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.tagTableView.separatorStyle = .none
        self.tagTableView.clearView()
        self.tagTableView.register(TagTableViewCell.nib,
                                   forCellReuseIdentifier: TagTableViewCell.reuseId)
        self.tagTableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTags.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.clearView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagTableViewCell.reuseId,
                                                 for: indexPath) as! TagTableViewCell
        
        if indexPath.row == 0 {
            cell.tagLabel.text = Localized("allTask")
            if let count = self.bagDict[noTag] {
                cell.todayCountLabel.text = String(format: Localized("tagToday"), count)
            }
            cell.configSwipeButtons(enable: false)
        } else {
            let tag = allTags[indexPath.row - 1]
            cell.tagLabel.text = tag.name
            if let count = self.bagDict[tag.tagUUID] {
                cell.todayCountLabel.text = String(format: Localized("tagToday"), count)
            } else {
                cell.todayCountLabel.text = nil
            }
            
            cell.configSwipeButtons(enable: true)
            cell.delegate = self
        }
        
        return cell
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        guard let indexPath = self.tagTableView.indexPath(for: cell) else { return true }
        
        let tag = self.allTags[indexPath.row - 1]
        let message: String?
        if let count = self.bagDict[tag.tagUUID] {
            message = String(format: Localized("tagToday"), count)
        } else {
            message = nil
        }
        
        let alert = UIAlertController(title: tag.name, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: Localized("cancel"), style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: Localized("deleteTag"), style: .destructive, handler: { [unowned self] (action) in
            RealmManager.shared.deleteObject(tag)
            self.tagTableView.deleteRows(at: [indexPath], with: .automatic)
        })
        alert.addAction(deleteAction)
        
        self.present(alert, animated: true, completion: nil)
        return true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row == self.currentSelectedIndex?.row {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.checkCurrentTagHasTask(row: indexPath.row) {
            if let current = self.currentSelectedIndex {
                if current == indexPath {
                    return
                }
                tableView.deselectRow(at: current, animated: true)
            }
            
            self.currentSelectedIndex = indexPath
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /**
     当前的选中的row 对应的 tag 下是否含有 task
     */
    fileprivate func checkCurrentTagHasTask(row: Int) -> Bool {
        if row == 0 {
            if let _ = self.bagDict[noTag] {
                self.tagChange = true
                AppUserDefault().remove(kUserDefaultCurrentTagUUIDKey)
                return true
            }
        } else {
            let tag = allTags[row - 1]
            if let _ = self.bagDict[tag.tagUUID] {
                self.tagChange = true
                AppUserDefault().write(kUserDefaultCurrentTagUUIDKey, value: tag.tagUUID)
                return true
            }
        }
        
        return false
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
        tag.createdAt = NSDate()
        
        let canSave = RealmManager.shared.saveTag(tag)
        if !canSave {
            HUD.shared.showOnce(Localized("tagExist"))
            return canSave
        } else {
            let index = IndexPath(row: self.allTags.count, section: 0)
            self.tagTableView.insertRows(at: [index], with: .automatic)
            self.closeNewTagAction()
            return textField.resignFirstResponder()
        }
    }
}

// MAKR: - drawer open close call back -- not prefect
extension TagViewController: MenuDrawerSlideStatusDelegate {
    func slideOpen(open: Bool) {
        self.leftBarButton?.isSelected = open
    }
}

protocol SwitchTagDelegate {
    func switchTagTo(tag: Tag?)
}
