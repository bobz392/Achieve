//
//  CalendarCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/5.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class CalendarCell: JTAppleDayCellView {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: AnimationView!
    @IBOutlet weak var hasTaskView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clearView()
        self.hasTaskView.layer.cornerRadius = 2
        self.hasTaskView.backgroundColor = Colors().priorityLowColor
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
            selectedView.animateWithBounceEffect(withCompletionHandler: { })
            
        } else {
            configueViewIntoBubbleView(cellState, animateDeselection: true)
        }
        
        configureTextColor(cellState, date: date)
    }
    
    fileprivate func configueViewIntoBubbleView(_ cellState: CellState, animateDeselection: Bool = false) {
        if cellState.isSelected {
            self.selectedView.layer.cornerRadius =  self.selectedView.frame.width  / 2
            self.selectedView.isHidden = false
            
        } else {
            if animateDeselection {
                if selectedView.isHidden == false {
                    selectedView.animateWithFadeEffect(withCompletionHandler: { () -> Void in
                        self.selectedView.isHidden = true
                        self.selectedView.alpha = 1
                    })
                }
            } else {
                selectedView.isHidden = true
            }
        }
    }
}


class AnimationView: UIView {
    
    func animateWithFlipEffect(withCompletionHandler completionHandler:(()->Void)?) {
        AnimationClass.flipAnimation(self, completion: completionHandler)
    }
    func animateWithBounceEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.BounceEffect()
        viewAnimation(self){ _ in
            completionHandler?()
        }
    }
    func animateWithFadeEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.FadeOutEffect()
        viewAnimation(self) { _ in
            completionHandler?()
        }
    }
}
