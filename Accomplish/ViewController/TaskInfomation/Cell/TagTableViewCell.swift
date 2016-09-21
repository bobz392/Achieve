//
//  TagTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/21.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: "TagTableViewCell", bundle: nil)
    static let reuseId = "tagTableViewCell"
    static let rowHeight: CGFloat = 44
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var todayCountLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        
        self.tagLabel.textColor = colors.mainTextColor
        self.todayCountLabel.textColor = colors.secondaryTextColor
        
        self.currentLabel.text = Localized("currentTag")
        self.currentLabel.isHidden = true
        
        self.currentLabel.layoutIfNeeded()
        self.currentLabel.textColor = colors.mainGreenColor
        self.currentLabel.layer.cornerRadius = self.currentLabel.frame.height * 0.5
        self.currentLabel.layer.borderColor = colors.mainGreenColor.cgColor
        self.currentLabel.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        self.currentLabel.isHidden = !selected
        self.tagLabel.font =
            selected ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
