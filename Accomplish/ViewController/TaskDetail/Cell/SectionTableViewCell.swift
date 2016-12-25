//
//  SectionTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SectionTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: "SectionTableViewCell", bundle: nil)
    static let reuseId = "sectionTableViewCell"
    static let rowHeight: CGFloat = 34

    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lineView.backgroundColor = Colors.separatorColor
        self.backgroundColor = Colors.mainBackgroundColor
        self.contentView.clearView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
