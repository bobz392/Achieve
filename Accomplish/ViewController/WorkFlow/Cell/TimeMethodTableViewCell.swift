//
//  TimeMethodTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeMethodTableViewCell: BaseTableViewCell {
    
    static let nib = UINib(nibName: "TimeMethodTableViewCell", bundle: nil)
    static let reuseId = "timeMethodTableViewCell"
    static let rowHeight: CGFloat = 44

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.nameLabel.textColor = colors.mainTextColor
        self.timesLabel.textColor = colors.secondaryTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(method: TimeMethod) {
        self.nameLabel.text = method.name
        self.timesLabel.text =
            Localized(method.useTimes > 1 ? "useTimes" : "useTime")
    }
}
