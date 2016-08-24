//
//  NewTaskViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import GPUImage

class NewTaskViewController: UIViewController {
    
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var renderImageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priorityCardView: UIView!
    @IBOutlet weak var prioritySegmental: UISegmentedControl!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var clockButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
    
    
    private let keyboardManager = KeyboardManager()
    private let cardViewHeight: CGFloat = 194
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configMainUI() {
        let colors = Colors()
        self.cardView.backgroundColor = colors.cloudColor
        self.titleTextField.tintColor = colors.mainGreenColor
        self.prioritySegmental.tintColor = colors.mainGreenColor
        self.priorityLabel.textColor = colors.mainTextColor
        self.toolView.backgroundColor = colors.cloudColor
        self.doneButton.tintColor = colors.mainGreenColor
        
        let clockIcon = FAKFontAwesome.clockOIconWithSize(22)
        clockIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let clockImage = clockIcon.imageWithSize(CGSize(width: 32, height: 32))
        self.clockButton.setImage(clockImage, forState: .Normal)
    }
    
    private func initializeControl() {
        self.cardView.addShadow()
        
        self.priorityCardView.layer.cornerRadius = 6.0
        self.priorityCardView.layer.borderColor = UIColor(red:0.78, green:0.78, blue:0.78, alpha:1.00).CGColor
        self.priorityCardView.layer.borderWidth = 0.5
        
        self.titleTextField.placeholder = Localized("goingDo")
        self.doneButton.setTitle(Localized("done"), forState: .Normal)
        
        self.priorityLabel.text = Localized("priority")
        
        self.prioritySegmental.selectedSegmentIndex = 1
        self.prioritySegmental.setTitle(Localized("low"), forSegmentAtIndex: 0)
        self.prioritySegmental.setTitle(Localized("normal"), forSegmentAtIndex: 1)
        self.prioritySegmental.setTitle(Localized("high"), forSegmentAtIndex: 2)
        
        keyboardManager.keyboardShowHandler = { [unowned self] in
            self.cardViewTopConstraint.constant =
                (self.view.frame.height - KeyboardManager.keyboardHeight - self.cardViewHeight) * 0.5
            
            UIView.animateWithDuration(kNormalAnimationDuration, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .TransitionNone, animations: {
                self.view.layoutIfNeeded()
            }) { [unowned self] (finish) in
                self.toolViewBottomConstraint.constant = KeyboardManager.keyboardHeight
                self.toolView.alpha = 1
                UIView.animateWithDuration(0.25, animations: {
                    self.toolView.layoutIfNeeded()
                })
            }
        }
        
        doneButton.addTarget(self, action: #selector(self.done), forControlEvents: .TouchUpInside)
    }
    
    func done() {
        self.removeFromParentViewController()
    }
    
    // MARK: - parent view controller
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        guard let p = parent else {
            return
        }
        let image = p.view.convertViewToImage()
        
        let filter = GPUImageiOSBlurFilter()
        let imagePicture = GPUImagePicture(image: image)
        imagePicture.addTarget(filter)
        filter.blurRadiusInPixels = 0.5
        filter.useNextFrameForImageCapture()
        imagePicture.processImage()
        
        
        self.view.frame = p.view.frame
        p.view.addSubview(self.view)
        
        self.cardViewTopConstraint.constant = (p.view.frame.height - cardViewHeight) * 0.5
        
        self.renderImageView.image = filter.imageFromCurrentFramebuffer()
        
        let tapDissmiss = UITapGestureRecognizer(target: self, action: #selector(self.dissmiss(_:)))
        self.view.addGestureRecognizer(tapDissmiss)
        
        self.configMainUI()
        self.initializeControl()
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        
        guard let _ = parent else {
            return
        }
        
        self.renderImageView.alpha = 0
        self.cardView.alpha = 0
        self.cardView.layer.cornerRadius = 9
        
        UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
            self.renderImageView.alpha = 1
            self.cardView.alpha = 1
        }) { (finish) in
            self.titleTextField.becomeFirstResponder()
        }
    }
    
    override func removeFromParentViewController() {
        keyboardManager.closeNotification()
        UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
            self.renderImageView.alpha = 0
            self.cardView.alpha = 0
        }) { [unowned self] (finish) in
            self.titleTextField.resignFirstResponder()
            self.view.removeFromSuperview()
        }
    }
    
    func dissmiss(tap: UITapGestureRecognizer) {
        if (!CGRectContainsPoint(self.cardView.frame, tap.locationInView(self.view))) {
            self.removeFromParentViewController()
        }
    }
}

