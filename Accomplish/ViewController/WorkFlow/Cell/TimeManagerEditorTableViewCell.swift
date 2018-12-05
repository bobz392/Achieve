
//
//  TimeManagerEditorTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagerEditorTableViewCell: BaseTableViewCell {
    
    typealias DeleteTimeMethodGroupBlock = () -> Void
    typealias GetMoveInViewBlock = () -> UIView
    
    static let nib = UINib(nibName: "TimeManagerEditorTableViewCell", bundle: nil)
    static let reuseId = "timeManagerEditorTableViewCell"
    static let defaultHeight: CGFloat = 74
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var deleteGroupButton: UIButton!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var groupRepeatLabel: UILabel!
    @IBOutlet weak var groupRepeatButton: UIButton!
    
    weak var timeMethodInputView: TimeMethodInputView? = nil
    weak var methodTableView: UITableView? = nil
    
    fileprivate var methodTime: TimeMethod? = nil
    
    fileprivate var groupIndex: Int = 0
    fileprivate var canChange = false
    var deleteBlock: DeleteTimeMethodGroupBlock? = nil
    var moveInBlock: GetMoveInViewBlock? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.deleteGroupButton.setImage(Icons.clear.iconImage(), for: .normal)
        self.deleteGroupButton.tintColor = Colors.linkButtonTextColor
        self.deleteGroupButton.addTarget(self, action: #selector(self.deleteGroupAction), for: .touchUpInside)
        
        self.cardView.layer.cornerRadius = 4
        self.cardView.backgroundColor = Colors.cellCardColor
        self.cardView.addCardShadow()
        
        self.itemsTableView.layer.cornerRadius = 4
        self.itemsTableView.register(ItemTableViewCell.nib,
                                     forCellReuseIdentifier: ItemTableViewCell.reuseId)
        self.itemsTableView.register(MethodCreateTableViewCell.nib,
                                     forCellReuseIdentifier: MethodCreateTableViewCell.reuseId)
        
        self.groupNameLabel.textColor = Colors.mainTextColor
        
        self.groupRepeatLabel.textColor = Colors.mainTextColor
        self.groupRepeatLabel.text = Localized("repeatNumber")
        self.groupRepeatButton.tintColor = Colors.linkButtonTextColor
        self.groupRepeatButton.addTarget(self, action: #selector(self.groupRepeatAction), for: .touchUpInside)
        
        self.itemsTableView.separatorColor = Colors.lightSeparatorColor
        self.itemsTableView.layer.borderWidth = 0.2
        self.itemsTableView.layer.borderColor = Colors.lightSeparatorColor.cgColor
    }
    
    func configCell(methodTime: TimeMethod, canChange: Bool, groupIndex: Int) {
        self.methodTime = methodTime
        self.canChange = canChange
        self.groupIndex = groupIndex
        // 如果在可以删除的情况下，也禁止第一个 group 删除，因为默认最少有一个group
        self.deleteGroupButton.isHidden = !canChange || groupIndex == 0
        self.groupRepeatButton.isEnabled = canChange
        
        self.groupNameLabel.text = Localized("timeManageGroupName") + "\(groupIndex + 1)"
        self.groupRepeatButton.setTitle("\(methodTime.groups[groupIndex].repeatTimes)", for: .normal)
        self.itemsTableView.reloadData()
        self.itemsTableView.allowsSelection = canChange
    }
    
    @objc func deleteGroupAction() {
        self.deleteBlock?()
    }
    
    @objc func groupRepeatAction() {
        guard let inputView = self.timeMethodInputView,
            let methodGroup = self.methodTime?.groups[self.groupIndex] else { return }
        
        
        inputView.firstTextField.isUserInteractionEnabled = false
        inputView.setTitles(first: Localized("timeManageGroupName"), second: Localized("repeatNumber"))
            .setPlaceHolders(first: "", second: Localized("enterGroupRepeatNumber"))
            .setContent(first: self.groupNameLabel.text ?? "", second: "\(methodGroup.repeatTimes)")
            .setSecondKeyboardType(keyboardType: .numberPad)
            .setSaveBlock { [unowned self] (_, times) in
                inputView.firstTextField.isUserInteractionEnabled = true
                if let t = Int(times ?? "1") {
                    RealmManager.shared.updateObject { [unowned self] in
                        methodGroup.repeatTimes = t <= 0 ? 1 : t
                        self.groupRepeatButton.setTitle(times, for: .normal)
                    }
                }
            }

        guard let moveInView = self.moveInBlock?() else { return }
        inputView.setMoveInView(moveInView: moveInView).moveIn()
    }
}

extension TimeManagerEditorTableViewCell: UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let methodGroup = self.methodTime?.groups[self.groupIndex] {
            return methodGroup.items.count + (self.canChange ? 1 : 0)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let methodGroup = self.methodTime?.groups[self.groupIndex] {
            if indexPath.row >= methodGroup.items.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: MethodCreateTableViewCell.reuseId,
                                                         for: indexPath) as! MethodCreateTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.reuseId,
                                                         for: indexPath) as! ItemTableViewCell
                let canSwipe = self.canChange && indexPath.row < methodGroup.items.count
                cell.configCell(item: methodGroup.items[indexPath.row], swipeEnable: canSwipe)
                cell.delegate = self
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ItemTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.canChange {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let inputView = self.timeMethodInputView,
            let methodGroup = self.methodTime?.groups[self.groupIndex] else { return }
        
        inputView.setTitles(first: Localized("itemName"), second: Localized("itemTime"))
            .setPlaceHolders(first: Localized("enterItemName"), second: Localized("enterItemTime"))
            .setSecondKeyboardType(keyboardType: .numberPad)
        
        if indexPath.row >= methodGroup.items.count {
            inputView.setContent(first: "", second: "")
                .setSaveBlock(saveBlock: { (name, interval) in
                    if let itv = Int(interval ?? "5") {
                        let item = TimeMethodItem()
                        item.name = name
                        item.interval = itv
                        RealmManager.shared.updateObject {
                            methodGroup.items.append(item)
                            tableView.insertRows(at: [indexPath], with: .none)
                            let reloadIndex = IndexPath(row: self.groupIndex, section: 0)
                            self.methodTableView?.reloadRows(at: [reloadIndex], with: .automatic)
                        }
                    }
                })
        } else {
            let item = methodGroup.items[indexPath.row]
            inputView.setContent(first: item.name, second:  "\(item.interval)")
                .setSaveBlock(saveBlock: { (name, interval) in
                    if let itv = Int(interval ?? "") {
                        RealmManager.shared.updateObject {
                            item.name = name
                            item.interval = itv
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
            })
        }
        
        guard let moveInView = self.moveInBlock?() else { return }
        inputView.setMoveInView(moveInView: moveInView).moveIn()
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        guard let indexPath = self.itemsTableView.indexPath(for: cell),
            let methodGroup = self.methodTime?.groups[self.groupIndex]
            else { return true}
        
        RealmManager.shared.updateObject { [unowned self] in
            methodGroup.items.remove(at: indexPath.row)
            self.itemsTableView.deleteRows(at: [indexPath], with: .none)
            let reloadIndex = IndexPath(row: self.groupIndex, section: 0)
            self.methodTableView?.reloadRows(at: [reloadIndex], with: .automatic)
        }
        return true
    }

}
