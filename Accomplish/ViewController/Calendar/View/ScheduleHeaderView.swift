//
//  ScheduleHeaderView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class ScheduleHeaderView: UIView {

    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var titleLable: UILabel!
    static let height: CGFloat = 60
    
    class func loadNib(_ target: AnyObject, title: String) -> ScheduleHeaderView? {
        guard let view =
            Bundle.main.loadNibNamed("ScheduleHeaderView", owner: target, options: nil)?.first as? ScheduleHeaderView else {
            return nil
        }
        
        view.clearView()
        view.headerBackgroundView.backgroundColor = Colors.mainBackgroundColor
        view.titleLable.textColor = Colors.cellCardColor
        view.titleLable.backgroundColor = Colors.scheduleLineBackgroundColor
        view.titleLable.addShadow()
        view.titleLable.text = title
        
        return view
    }

}
