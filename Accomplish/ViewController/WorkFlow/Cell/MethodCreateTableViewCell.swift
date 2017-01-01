//
//  MethodCreateTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/25.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class MethodCreateTableViewCell: BaseTableViewCell {

    static let nib = UINib(nibName: "MethodCreateTableViewCell", bundle: nil)
    static let reuseId = "methodCreateTableViewCell"
    static let rowHeightGroup: CGFloat = 44
    static let rowHeightItem: CGFloat = 38
    
    @IBOutlet weak var createButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.createButton.setImage(Icons.smallPlus.iconImage(), for: .normal)
        self.createButton.tintColor = Colors.mainIconColor
    }

}
