//
//  SystemTaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SystemTaskTableViewCell: BaseTableViewCell {

    static let nib = UINib(nibName: "SystemTaskTableViewCell", bundle: nil)
    static let reuseId = "systemTaskTableViewCell"
    static let rowHeight: CGFloat = 65
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.backgroundColor = colors.cloudColor
        self.contentView.backgroundColor = colors.cloudColor
        self.taskTitle.textColor = Colors.mainTextColor
        
        self.iconImage.layer.cornerRadius = 10
        self.iconImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
