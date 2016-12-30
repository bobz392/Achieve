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
    static let rowHeight: CGFloat = 70
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Colors.mainBackgroundColor
        self.contentView.clearView()
        self.taskTitle.textColor = Colors.mainTextColor
        
        self.iconImage.layer.cornerRadius = 10
        self.iconImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
