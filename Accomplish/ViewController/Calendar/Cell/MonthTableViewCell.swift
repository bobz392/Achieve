
//
//  MonthTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 2016/10/12.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class MonthTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "MonthTableViewCell", bundle: nil)
    static let reuseId = "monthTableViewCell"
    static let rowHeight: CGFloat = 68

    @IBOutlet weak var monthCardView: UIView!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var leftDetailLabel: UILabel!
    @IBOutlet weak var rightDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let colors = Colors()
        
        self.clearView()
        self.contentView.clearView()
        self.monthCardView.backgroundColor = colors.cloudColor
        self.monthCardView.layer.cornerRadius = kCardViewCornerRadius
        self.taskNameLabel.textColor = colors.mainTextColor
        self.infoLabel.textColor = colors.secondaryTextColor
        self.leftDetailLabel.textColor = colors.secondaryTextColor
        self.rightDetailLabel.textColor = colors.secondaryTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configPostpone(task: Task) {
        self.infoLabel.text = Localized("postponeTask")
        self.leftDetailLabel.text =
            String(format: Localized("postponeTimes"), task.postponeTimes)
        
        if let finishDate = task.finishedDate {
            self.rightDetailLabel.text =
                String(format: Localized("postponeFinishAt"),
                       finishDate.formattedDate(with: .medium))
        } else {
            if task.postponeTimes > 0 {
                self.rightDetailLabel.text = Localized("notComoletedYet")
            } else {
                self.rightDetailLabel.text = Localized("progess")
            }
        }
    }
}
