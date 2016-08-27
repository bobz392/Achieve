//
//  SystemTaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SystemTaskTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: "SystemTaskTableViewCell", bundle: nil)
    static let reuseId = "systemTaskTableViewCell"
    static let rowHeight: CGFloat = 65
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.contentView.backgroundColor = colors.cloudColor
        self.layoutMargins = UIEdgeInsetsZero
        self.taskTitle.textColor = colors.mainTextColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell() {
        
    }
    
}
