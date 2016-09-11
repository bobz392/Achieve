
//
//  SettingDetialTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/10.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SettingDetialTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: "SettingDetialTableViewCell", bundle: nil)
    static let reuseId = "settingDetialTableViewCell"
    static let rowHeight: CGFloat = 44
    
    
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.contentView.clearView()
        self.clearView()
        self.settingTitleLabel.textColor =
            colors.mainTextColor
        self.detailLabel.textColor = colors.secondaryTextColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
