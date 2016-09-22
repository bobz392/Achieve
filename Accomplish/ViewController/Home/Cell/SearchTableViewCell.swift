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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
