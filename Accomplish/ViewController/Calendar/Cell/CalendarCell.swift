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
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate) {
        // Setup Cell text
        dateLabel.text = cellState.text
        
        self.clearView()
        // Setup text color
        configureTextColor(cellState, date: date)
        
        // Setup cell selection status
        delayRunOnMainThread(0.0) {
            self.configueViewIntoBubbleView(cellState)
        }
        
        // Configure Visibility
        //        configureVisibility(cellState)
    }
    
    //    func configureVisibility(cellState: CellState) {
    //        if
    //            cellState.dateBelongsTo == .ThisMonth ||
    //                cellState.dateBelongsTo == .PreviousMonthWithinBoundary ||
    //                cellState.dateBelongsTo == .FollowingMonthWithinBoundary {
    //            self.hidden = false
    //        } else {
    //            self.hidden = false
    //        }
    //
    //    }
    
    func configureTextColor(cellState: CellState, date: NSDate) {
        let colors = Colors()
        if cellState.isSelected {
            self.dateLabel.textColor = colors.cloudColor
        } else {
            if date.isToday() {
                self.dateLabel.textColor = colors.linkTextColor
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
            if selectedView.hidden == true {
                configueViewIntoBubbleView(cellState)
                selectedView.animateWithBounceEffect(withCompletionHandler: {
                })
            }
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
