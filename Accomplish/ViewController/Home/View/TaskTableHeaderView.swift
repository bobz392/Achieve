//
//  TaskTableHeaderView.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/19.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TaskTableHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    class func loadNib(_ target: AnyObject, title: String) -> TaskTableHeaderView? {
        guard let view =
            Bundle.main.loadNibNamed("TaskTableHeaderView", owner: target, options: nil)?
                .first as? TaskTableHeaderView else {
                    return nil
        }
        
        view.titleLabel.text = title
        view.titleLabel.textColor = Colors.secondaryTextColor
        
        return view
    }

}
