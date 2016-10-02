//
//  HomeTableView.swift
//  Accomplish
//
//  Created by zhoubo on 2016/10/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

let kRunningSegmentIndex = 0
let kFinishSegmentIndex = 1

class HomeTableView: UITableView, UIGestureRecognizerDelegate {
    
    fileprivate var pulldownView: HomePulldownView? = nil
    fileprivate var canchange = false
    
    fileprivate var currentX: CGFloat = -1
    fileprivate var currentSelect: Int = -1
    fileprivate var nowSelect: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(pan:)))
//        self.addGestureRecognizer(pan)
//        
//        guard let pulldownView = HomePulldownView.loadNib(self) else { return }
//        self.addSubview(pulldownView)
//        self.pulldownView = pulldownView
    }
    
    func layout(holderView: UIView) {
        pulldownView?.layout(superview: self, holderView: holderView)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print(gestureRecognizer)
        return true
    }

    func panAction(pan: UIPanGestureRecognizer) {
        guard  let pulldownView = self.pulldownView else { return }
        guard self.canchange == true else { return }
        
        let location = pan.location(in: self)
        print(location)
    }
    
    func setAnimation(progress: CGFloat, current: Int) {
        guard  let pulldownView = self.pulldownView else { return }
        
        pulldownView.setConstraint(current: current)
        
        self.currentSelect = current
        self.nowSelect = current
        self.canchange = progress >= 1.0
    }
    
    func reset() {
        self.canchange = false
        self.currentX = -1
    }
    
}
