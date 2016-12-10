//
//  ReadLaterTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class ReadLaterTableViewCell: BaseTableViewCell {

    static let nib = UINib(nibName: "ReadLaterTableViewCell", bundle: nil)
    static let reuseId = "readLaterTableViewCell"
    static let rowHeight: CGFloat = 70

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
