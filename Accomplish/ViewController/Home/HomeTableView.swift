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
    
    fileprivate let changeLength: CGFloat = 50
    var initLocationX: CGFloat = 0
    var endLocationX: CGFloat = 0
    var canChange = false
    
    var getCurrentIndex: ( () -> Int )?
    var changeCallBack: ( (Int) -> Void )?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(pan:)))
        self.addGestureRecognizer(pan)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func panAction(pan: UIPanGestureRecognizer) {
        if pan.state == .ended {
            HUD.shared.dismiss()
            
            if self.canChange {
                self.changeCallBack?( self.getCurrentIndex?() == 0 ? 1 : 0 )
            }
            
        } else if pan.state == .began {
            self.initLocationX = 0
            self.canChange = false
            self.initLocationX = pan.location(in: self).x
            
        } else {
            guard self.initLocationX != 0 else { return }
            
            let locationX = pan.location(in: self).x
            let currentIndex = getCurrentIndex?()
            
            if locationX > self.initLocationX {
                guard currentIndex == kRunningSegmentIndex else { return }
                
                self.endLocationX = locationX
                if locationX - self.initLocationX > self.changeLength {
                    HUD.shared.showSwitch(Localized("switchFinish"), left: false)
                    self.canChange = true
                } else {
                    HUD.shared.dismiss()
                    self.canChange = false
                }
            } else {
                guard currentIndex == kFinishSegmentIndex else { return }
                
                self.endLocationX = locationX
                if self.initLocationX - locationX > self.changeLength {
                    HUD.shared.showSwitch(Localized("switchRunning"), left: true)
                    self.canChange = true
                } else {
                    HUD.shared.dismiss()
                    self.canChange = false
                }
            }
        }
    }
}
