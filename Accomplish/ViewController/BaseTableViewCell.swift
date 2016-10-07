
//
//  BaseTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/22.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
//        let f = frame.insetBy(dx: 0, dy: -1)
//        selectedBackgroundView = UIView(frame: f)
//        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
