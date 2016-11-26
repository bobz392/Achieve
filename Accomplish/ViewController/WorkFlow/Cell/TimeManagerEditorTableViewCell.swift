
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
    
    static let nib = UINib(nibName: "TimeManagerEditorTableViewCell", bundle: nil)
    static let reuseId = "timeManagerEditorTableViewCell"
    static let defaultHeight: CGFloat = 72.5
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let colors = Colors()
        self.deleteGroupButton.createIconButton(iconSize: kTaskDetailCellIconSize,
                                                icon: "fa-times",
                                                color: colors.mainGreenColor, status: .normal)
        self.deleteGroupButton.addTarget(self,
                                         action: #selector(self.deleteGroupAction), for: .touchUpInside)
        
        self.cardView.layer.cornerRadius = kCardViewSmallCornerRadius
        self.cardView.backgroundColor = colors.cloudColor
        
        self.itemsTableView.layer.cornerRadius = kCardViewSmallCornerRadius
        self.itemsTableView.register(ItemTableViewCell.nib,
                                     forCellReuseIdentifier: ItemTableViewCell.reuseId)
        self.itemsTableView.register(MethodCreateTableViewCell.nib,
                                     forCellReuseIdentifier: MethodCreateTableViewCell.reuseId)
        
        self.groupNameLabel.textColor = colors.mainTextColor
        
        self.groupRepeatLabel.textColor = colors.mainTextColor
        self.groupRepeatLabel.text = Localized("repeatNumber")
        self.groupRepeatButton.tintColor = colors.mainGreenColor
        
        self.itemsTableView.addLightBorder()
    }
    
    func configCell(methodTime: TimeMethod, canChange: Bool, groupIndex: Int) {
        self.methodTime = methodTime
        self.canChange = canChange
        self.groupIndex = groupIndex
        self.deleteGroupButton.isHidden = !canChange
        self.groupRepeatButton.isEnabled = canChange
        
        self.groupNameLabel.text = String(format: Localized("timeManageGroupName"), groupIndex + 1)
        self.groupRepeatButton.setTitle("\(methodTime.groups[groupIndex].repeatTimes)", for: .normal)
        self.itemsTableView.reloadData()
        self.itemsTableView.allowsSelection = canChange
    }
    
    func deleteGroupAction() {
        self.deleteBlock?()
    }
}

extension TimeManagerEditorTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
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
                cell.configCell(item: methodGroup.items[indexPath.row])
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
        guard let view = self.timeMethodInputView,
            let methodGroup = self.methodTime?.groups[self.groupIndex] else { return }
        
        let titles = [Localized("itemName"), Localized("itemTime")]
        let holders = [Localized("enterItemName"), Localized("enterItemTime")]
        
        if indexPath.row >= methodGroup.items.count {
            view.moveIn(twoTitles: titles,
                        twoHolders: holders,
                        twoContent: ["", ""]) { (first, second) in
                            if let interval = Int(second ?? "") {
                                let item = TimeMethodItem()
                                item.name = first
                                item.interval = interval
                                RealmManager.shared.updateObject {
                                    methodGroup.items.append(item)
                                    tableView.insertRows(at: [indexPath], with: .none)
                                    let reloadIndex = IndexPath(row: self.groupIndex, section: 0)
                                    self.methodTableView?.reloadRows(at: [reloadIndex], with: .automatic)
                                }
                            }
                            
            }
        } else {
            let item = methodGroup.items[indexPath.row]
            view.moveIn(twoTitles: titles,
                        twoHolders: holders,
                        twoContent: [item.name, "\(item.interval)"]) { (first, second) in
                            if let interval = Int(second ?? "") {
                                RealmManager.shared.updateObject {
                                    item.interval = interval
                                    item.name = first
                                    tableView.reloadRows(at: [indexPath], with: .automatic)
                                }
                            }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let methodGroup = self.methodTime?.groups[self.groupIndex] else { return false }
        return self.canChange && indexPath.row < methodGroup.items.count
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let methodGroup = self.methodTime?.groups[self.groupIndex] else { return }
        switch editingStyle {
        case .delete:
            RealmManager.shared.updateObject { [unowned self] in
                methodGroup.items.remove(objectAtIndex: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .none)
                let reloadIndex = IndexPath(row: self.groupIndex, section: 0)
                self.methodTableView?.reloadRows(at: [reloadIndex], with: .automatic)
            }
        default:
            break
        }
    }
}
