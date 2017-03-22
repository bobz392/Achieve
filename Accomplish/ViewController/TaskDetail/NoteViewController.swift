//
//  NoteViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class NoteViewController: BaseViewController {
    
    fileprivate let noteTextView = UITextView()
    
    var task: Task
    var noteDelegate: TaskNoteDataDelegate?
    
    // MARK: - life circle
    init(task: Task, noteDelegate: TaskNoteDataDelegate?) {
        self.task = task
        self.noteDelegate = noteDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.task = Task()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardManager.sharedManager.closeNotification()
        let weakSelf = self
        KeyboardManager.sharedManager.setHideHander {
            weakSelf.noteTextView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().offset(0)
            })
            UIView.animate(withDuration: kNormalAnimationDuration, animations: { 
                weakSelf.view.layoutIfNeeded()
            })
        }
        
        KeyboardManager.sharedManager.setShowHander {
            weakSelf.noteTextView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().offset(-KeyboardManager.keyboardHeight)
            })
            UIView.animate(withDuration: kNormalAnimationDuration, animations: {
                weakSelf.view.layoutIfNeeded()
            })
        }
        
        if self.task.taskNote.isRealEmpty {
            self.noteTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.saveNote()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: true)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        let titleLable = UILabel()
        titleLable.text = self.task.realTaskToDo()
        titleLable.font = appFont(size: 17)
        titleLable.textAlignment = .center
        titleLable.textColor = Colors.mainTextColor
        bar.addSubview(titleLable)
        titleLable.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton.snp.centerY)
            make.width.equalTo(180)
        }
        
        noteTextView.font = appFont(size: 16)
        noteTextView.textColor = Colors.mainTextColor
        noteTextView.tintColor = Colors.mainTextColor
        noteTextView.text = self.task.taskNote
        noteTextView.clearView()
        noteTextView.dataDetectorTypes = [.all]
        self.view.addSubview(noteTextView)
        noteTextView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - action
    func saveNote() {
        guard let content = self.noteTextView.text else { return }
        self.noteDelegate?.taskNoteAdd(content)
    }
}
