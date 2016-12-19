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
    
    fileprivate let changeLength: CGFloat = 70
    fileprivate let changeYLength: CGFloat = 50
    var initLocationX: CGFloat = 0
    var initLocationY: CGFloat = 0
    var endLocationX: CGFloat = 0
    var canChange = false
    let homeRefreshControl = UIRefreshControl()
    
    var getCurrentIndex: ( () -> Int )?
    var changeCallBack: ( (Int) -> Void )?
    var searchCallBack: ( () -> Void )?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(pan:)))
//        self.addGestureRecognizer(pan)
        
//        self.homeRefreshControl
//            .addTarget(self, action: #selector(self.searchAction), for: .valueChanged)
//
//        self.addSubview(self.homeRefreshControl)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func searchAction() {
        self.initLocationX = 0
        self.searchCallBack?()
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
            let location = pan.location(in: self)
            self.initLocationX = location.x
            self.initLocationY = location.y
            
        } else if pan.state == .changed {
            guard self.initLocationX != 0 else { return }
            
            let location = pan.location(in: self)
            let locationX = location.x
            let locationY = location.y
            let currentIndex = self.getCurrentIndex?()
            
            if abs(locationY - self.initLocationY) > self.changeYLength {
                self.initLocationX = 0
                return
            }
            
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
