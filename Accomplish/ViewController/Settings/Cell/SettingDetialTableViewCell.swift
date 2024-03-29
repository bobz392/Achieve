
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
    static let rowHeight: CGFloat = 60
    
    
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.clearView()
        self.backgroundColor = Colors.cellCardColor
        self.settingTitleLabel.textColor =
            Colors.mainTextColor
        self.detailLabel.textColor = Colors.cellLabelSelectedTextColor
        self.iconImageView.tintColor = Colors.cellLabelSelectedTextColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.backgroundColor = Colors.cellCardSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.backgroundColor = Colors.cellCardColor
            })
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.backgroundColor = Colors.cellCardSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.backgroundColor = Colors.cellCardColor
            })
        }
    }
    
}
