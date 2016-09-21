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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        
        self.tagLabel.textColor = colors.mainTextColor
        self.todayCountLabel.textColor = colors.secondaryTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
