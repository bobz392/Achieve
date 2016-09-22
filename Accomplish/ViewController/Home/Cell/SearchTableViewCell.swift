//
//  SearchTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/22.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SearchTableViewCell: BaseTableViewCell {

    static let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
    static let reuseId = "searchTableViewCell"
    static let rowHeight: CGFloat = 65
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskStartLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.clearView()
        self.contentView.clearView()
        self.taskTitleLabel.textColor = colors.cloudColor
        self.taskStartLabel.textColor = colors.cloudColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}