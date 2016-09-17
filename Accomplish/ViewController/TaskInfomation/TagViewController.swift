//
//  TagViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/16.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        debugPrint(RealmManager.shareManager.allTags())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let hintView = HintView.loadNib(self) else { return }
        
        self.view.addSubview(hintView)
        hintView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.height.equalTo(150)
            make.width.equalTo(280)
        }
        let hints = [
            HintItem(iconName: "fa-arrow-right", hintDetail: "asd"),
            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdasd"),
            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdas]sad"),
            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdakjkasjl"),
        ]
        hintView.addHints(hints)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TagViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return textField.resignFirstResponder()
        }
        
        let tag = Tag()
        tag.tagUUID = NSDate().createTagUUID()
        tag.name = text
        RealmManager.shareManager.saveTag(tag)
        return textField.resignFirstResponder()
    }
}
