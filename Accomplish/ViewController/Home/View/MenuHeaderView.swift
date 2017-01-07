//
//  MenuHeaderView.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/28.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class MenuHeaderView: UIView {

    static let height: CGFloat = 160

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
        view.dayLabel.textColor = Colors.mainIconColor
        view.dayUnitLabel.textColor = Colors.mainIconColor
        view.monthYearLabel.textColor = Colors.mainIconColor
        let line = UIView()
        line.backgroundColor = Colors.separatorColor
        view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        return view
    }

    func setNewDate(date: NSDate) {
        self.dayLabel.text = String(format: "%02d", date.day())
        self.monthYearLabel.text = date.formattedDate(withFormat: MenuDateFormat)
    }
    
}
