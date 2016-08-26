//
//  SystemViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SystemTaskViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var toolView: UIView!
    
    @IBOutlet weak var systemCollectionView: UICollectionView!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        configMainUI()
        initControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        self.view.backgroundColor = colors.mainGreenColor
        self.systemCollectionView.backgroundColor = colors.mainGreenColor
        
        self.toolView.backgroundColor = colors.cloudColor
        self.toolView.addShadow()
    }
    
    private func initControl() {
        self.systemCollectionView.registerNib(SystemActionCollectionViewCell.nib, forCellWithReuseIdentifier: SystemActionCollectionViewCell.reuseId)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .Vertical
        let screenWidth = UIScreen.mainScreen().bounds.width
        let width = screenWidth / 5 - 5
        layout.itemSize = CGSize(width: width, height: width)
        
        self.collectionHeightConstraint.constant = width * 3 + 10
        self.systemCollectionView.collectionViewLayout = layout
    }
    
    // MARK: - action
    func selectAction(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .LayoutSubviews, animations: {
            btn.transform = CGAffineTransformMakeScale(1, 1)
        }) { (finish) in }
    }
    
    func buttonAnimationStartAction(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
            btn.transform = CGAffineTransformScale(btn.transform, 0.8, 0.8)
        }) { (finish) in }
    }
    
    func buttonAnimationEndAction(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .LayoutSubviews, animations: {
            btn.transform = CGAffineTransformMakeScale(1, 1)
        }) { (finish) in }
    }
    
    // MARK: - colletion view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SystemActionCollectionViewCell.reuseId, forIndexPath: indexPath) as! SystemActionCollectionViewCell
        
        if indexPath.row % 2 == 0 {
            cell.configWithIcon("fa-phone")
        } else {
            cell.configWithIcon("fa-video-camera")
        }
        
        cell.actionButton.addTarget(self, action: #selector(self.selectAction(_:)), forControlEvents: .TouchUpInside)
        cell.actionButton.addTarget(self, action: #selector(self.buttonAnimationStartAction(_:)), forControlEvents: .TouchDown)
        cell.actionButton.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), forControlEvents: .TouchUpOutside)
        
        return cell
    }
    
}
