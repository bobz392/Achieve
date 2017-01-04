//
//  SettingTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/9.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SettingTableViewCell: BaseTableViewCell {

    static let nib = UINib(nibName: "SettingTableViewCell", bundle: nil)
    static let reuseId = "settingTableViewCell"
    static let rowHeight: CGFloat = 60
    
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.clearView()
        self.backgroundColor = Colors.cellCardColor
        self.iconImageView.tintColor = Colors.cellLabelSelectedTextColor
        settingTitleLabel.textColor = Colors.mainTextColor
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
