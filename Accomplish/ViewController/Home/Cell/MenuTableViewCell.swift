//
//  MenuTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/28.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
    static let reuseId = "menuTableViewCell"
    static let rowHeight: CGFloat = 60
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Colors.mainBackgroundColor
        self.contentView.clearView()
        self.iconDetailLabel.textColor = Colors.mainIconColor
        self.iconDetailLabel.highlightedTextColor = Colors.cellLabelSelectedTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.iconImageView.tintColor = Colors.cellLabelSelectedTextColor
        } else {
            self.iconImageView.tintColor = Colors.mainIconColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.iconImageView.tintColor = Colors.cellLabelSelectedTextColor
        } else {
            self.iconImageView.tintColor = Colors.mainIconColor
        }
    }
    
    func configCell(icon: Icons) {
        self.iconImageView.image = icon.iconImage()
        self.iconImageView.tintColor = Colors.mainIconColor
        self.iconDetailLabel.text = Localized(icon.iconString())
    }
    
}
