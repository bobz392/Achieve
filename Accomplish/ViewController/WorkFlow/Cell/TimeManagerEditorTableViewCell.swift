
//
//  TimeManagerEditorTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagerEditorTableViewCell: BaseTableViewCell {
    
    static let nib = UINib(nibName: "TimeManagerEditorTableViewCell", bundle: nil)
    static let reuseId = "timeManagerEditorTableViewCell"
    static let defaultHeight: CGFloat = 84.5
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var deleteGroupButton: UIButton!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var groupRepeatLabel: UILabel!
    @IBOutlet weak var groupRepeatButton: UIButton!
    fileprivate var methodGroup: TimeMethodGroup? = nil
    fileprivate var canChange = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let colors = Colors()
        self.deleteGroupButton.createIconButton(iconSize: kTaskDetailCellIconSize,
                                                icon: "fa-times",
                                                color: colors.mainGreenColor, status: .normal)
        
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
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
    }
    
    func configCell(methodGroup: TimeMethodGroup, canChange: Bool, groupIndex: Int) {
        self.methodGroup = methodGroup
        self.canChange = canChange
        self.deleteGroupButton.isHidden = !canChange
        self.groupRepeatButton.isEnabled = canChange
        
        self.groupNameLabel.text = String(format: Localized("timeManageGroupName"), groupIndex)
        self.groupRepeatButton.setTitle("\(methodGroup.repeatTimes)", for: .normal)
        self.itemsTableView.reloadData()
        self.itemsTableView.allowsSelection = canChange
    }
}

extension TimeManagerEditorTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let methodGroup = self.methodGroup {
            return methodGroup.items.count + (self.canChange ? 1 : 0)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let methodGroup = self.methodGroup {
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
    }
    
}
