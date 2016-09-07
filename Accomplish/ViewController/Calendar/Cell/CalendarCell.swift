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
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate, hasTask: Bool) {
        
        dateLabel.text = cellState.text
        
        self.configureTextColor(cellState, date: date)
        self.configureHasTaskView(hasTask)
        self.configueViewIntoBubbleView(cellState)
    }
    
    private func configureHasTaskView(hasTask: Bool) {
        self.hasTaskView.hidden = !hasTask
    }
    
    func configureTextColor(cellState: CellState, date: NSDate) {
        let colors = Colors()
        if cellState.isSelected {
            self.dateLabel.textColor = colors.cloudColor
        } else {
            if date.isToday() {
                self.dateLabel.textColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.00)
            } else if cellState.dateBelongsTo == .ThisMonth {
                self.dateLabel.textColor = colors.mainTextColor
            } else {
                self.dateLabel.textColor = colors.secondaryTextColor
            }
        }
        
        self.selectedView.backgroundColor = colors.mainGreenColor
    }
    
    func cellSelectionChanged(cellState: CellState, date: NSDate) {
        if cellState.isSelected == true {
            configueViewIntoBubbleView(cellState)
            selectedView.animateWithBounceEffect(withCompletionHandler: { })
            
        } else {
            configueViewIntoBubbleView(cellState, animateDeselection: true)
        }
        
        configureTextColor(cellState, date: date)
    }
    
    private func configueViewIntoBubbleView(cellState: CellState, animateDeselection: Bool = false) {
        if cellState.isSelected {
            self.selectedView.layer.cornerRadius =  self.selectedView.frame.width  / 2
            self.selectedView.hidden = false
            
        } else {
            if animateDeselection {
                if selectedView.hidden == false {
                    selectedView.animateWithFadeEffect(withCompletionHandler: { () -> Void in
                        self.selectedView.hidden = true
                        self.selectedView.alpha = 1
                    })
                }
            } else {
                selectedView.hidden = true
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
