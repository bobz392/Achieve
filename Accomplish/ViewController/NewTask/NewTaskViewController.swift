//
//  NewTaskViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import GPUImage
import SnapKit

class NewTaskViewController: UIViewController {
    
    @IBOutlet weak var renderImageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        titleTextField.placeholder = Localized("goingDo")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        
        self.view.frame = p.view.frame ?? CGRectZero
        p.view.addSubview(self.view)
        renderImageView.image = filter.imageFromCurrentFramebuffer()
        
        let tapDissmiss = UITapGestureRecognizer(target: self, action: #selector(self.tapDissmiss))
        self.view.addGestureRecognizer(tapDissmiss)
        
        self.cardView.backgroundColor = Colors().cloudColor
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        
        self.renderImageView.alpha = 0
        self.cardView.alpha = 0
        self.cardView.layer.cornerRadius = 9
        
        UIView.animateWithDuration(kNormalAnimationDuration) { [unowned self] in
            self.renderImageView.alpha = 1
            self.cardView.alpha = 1
        }
    }
    
    override func removeFromParentViewController() {
        UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
            self.renderImageView.alpha = 0
        }) { [unowned self] (finish) in
            self.view.removeFromSuperview()
        }
    }
    
    func tapDissmiss() {
        self.removeFromParentViewController()
    }
    
}

