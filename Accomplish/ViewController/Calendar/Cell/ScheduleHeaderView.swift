//
//  ScheduleHeaderView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class ScheduleHeaderView: UIView {

    @IBOutlet weak var titleLableView: UILabel!
    
    class func loadNib(_ target: AnyObject) -> ScheduleHeaderView? {
        return Bundle.main
            .loadNibNamed("ScheduleHeaderView", owner: target, options: nil)?.first as? ScheduleHeaderView
    }
    
    override func awakeFromNib() {
        self.titleLableView.textColor = Colors.cloudColor
        super.awakeFromNib()
    }

}
