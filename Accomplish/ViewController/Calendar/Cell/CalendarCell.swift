//
//  CalendarCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/5.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleDayCellView {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var hasTaskView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clearView()
        self.hasTaskView.layer.cornerRadius = 2
        self.hasTaskView.backgroundColor = Colors().priorityLowColor
        self.selectedView.layer.cornerRadius = 15
    }
    
    func setupCellBeforeDisplay(_ cellState: CellState, date: Date, hasTask: Bool) {
        
        dateLabel.text = cellState.text
        
        self.configureTextColor(cellState, date: date)
        self.configureHasTaskView(hasTask)
        self.configueViewIntoBubbleView(cellState)
    }
    
    fileprivate func configureHasTaskView(_ hasTask: Bool) {
        self.hasTaskView.isHidden = !hasTask
    }
    
    func configureTextColor(_ cellState: CellState, date: Date) {
        let colors = Colors()
        if cellState.isSelected {
            self.dateLabel.textColor = colors.cloudColor
        } else {
            if (date as NSDate).isToday() {
                self.dateLabel.textColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.00)
            } else if cellState.dateBelongsTo == .thisMonth {
                self.dateLabel.textColor = colors.mainTextColor
            } else {
                self.dateLabel.textColor = colors.secondaryTextColor
            }
        }
        
        self.selectedView.backgroundColor = colors.mainGreenColor
    }
    
    func cellSelectionChanged(_ cellState: CellState, date: Date) {
        if cellState.isSelected == true {
            configueViewIntoBubbleView(cellState)
            self.cellBounceEffectAnimation(view: self.selectedView)
        } else {
            configueViewIntoBubbleView(cellState, animateDeselection: true)
        }
        
        configureTextColor(cellState, date: date)
    }
    
    fileprivate func configueViewIntoBubbleView(_ cellState: CellState, animateDeselection: Bool = false) {
        if cellState.isSelected {
            self.selectedView.alpha = 1
            
        } else {
            self.selectedView.alpha = 0
        }
    }
    
    fileprivate func cellBounceEffectAnimation(view: UIView) {
        view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
    }
}
