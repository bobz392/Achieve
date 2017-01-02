
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
        
        self.clearView()
        self.contentView.clearView()
        self.monthCardView.backgroundColor = Colors.mainBackgroundColor
        self.taskNameLabel.textColor = Colors.mainTextColor
        self.infoLabel.textColor = Colors.secondaryTextColor
        self.leftDetailLabel.textColor = Colors.secondaryTextColor
        self.rightDetailLabel.textColor = Colors.secondaryTextColor
        
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
