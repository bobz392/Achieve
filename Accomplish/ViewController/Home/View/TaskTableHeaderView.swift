//
//  TaskTableHeaderView.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/19.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TaskTableHeaderView: UIView {
    
    typealias TaskHeaderButtonBlock = (_ button: UIButton) -> Void
    
    static let preceedHeight: CGFloat = 20
    static let completedHeight: CGFloat = 40
    fileprivate var block: TaskHeaderButtonBlock? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var additionButton: UIButton!
    
    class func loadNib(_ target: AnyObject, title: String) -> TaskTableHeaderView? {
        guard let view =
            Bundle.main.loadNibNamed("TaskTableHeaderView", owner: target, options: nil)?
                .first as? TaskTableHeaderView else {
                    return nil
        }
        
        view.backgroundColor = Colors.mainBackgroundColor
        view.titleLabel.text = title
        view.titleLabel.textColor = Colors.headerTextColor
        view.additionButton.isHidden = true
        view.additionButton.setTitleColor(Colors.linkButtonTextColor, for: .normal)
        view.additionButton.addTarget(view, action: #selector(view.additionAction), for: .touchUpInside)
        
        return view
    }
    
    func updateTitle(newTitle: String) {
        self.titleLabel.text = newTitle
    }

    @objc func additionAction() {
        self.block?(self.additionButton)
    }
    
    func configAdditionButton(title: String, buttonBlock: @escaping TaskHeaderButtonBlock) {
        self.block = buttonBlock
        self.additionButton.setTitle(title, for: .normal)
        self.additionButton.isHidden = false
    }
    
    func removeAdditionButton() {
        self.block = nil
        self.additionButton.setTitle(nil, for: .normal)
        self.additionButton.isHidden = false
    }
}
