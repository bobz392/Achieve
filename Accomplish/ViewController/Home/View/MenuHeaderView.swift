//
//  MenuHeaderView.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/28.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class MenuHeaderView: UIView {

    static let height: CGFloat = 142

    @IBOutlet weak var dayUnitLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthYearLabel: UILabel!

    class func loadNib(_ target: AnyObject) -> MenuHeaderView? {
        guard let view =
            Bundle.main.loadNibNamed("MenuHeaderView", owner: target, options: nil)?
                .first as? MenuHeaderView else {
                    return nil
        }
        
        view.backgroundColor = Colors.mainBackgroundColor
        view.dayLabel.textColor = Colors.mainTextColor
        view.dayUnitLabel.textColor = Colors.secondaryTextColor
        view.monthYearLabel.textColor = Colors.secondaryTextColor
        return view
    }

}
