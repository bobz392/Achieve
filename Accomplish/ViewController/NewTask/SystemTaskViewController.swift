//
//  SystemViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SystemTaskViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, TaskActionDataDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var newTaskDelegate: NewTaskDataDelegate? = nil
    
    private let actionBuilder = ActionBuilder()
    private var selectedActionType: SystemActionType? = nil
    
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
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.taskTableView.backgroundColor = colors.cloudColor
        self.taskTableView.separatorColor = colors.separatorColor
        self.toolView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.cancelButton.buttonColor(colors)
        let cancelIcon = FAKFontAwesome.arrowLeftIconWithSize(40)
        cancelIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.cancelButton.setAttributedTitle(cancelIcon.attributedString(), forState: .Normal)
    }
    
    private func initControl() {
        if #available(iOS 9, *) {
            self.taskTableView.cellLayoutMarginsFollowReadableWidth = false
        }
        self.taskTableView.tableFooterView = UIView()
        self.taskTableView.registerNib(SystemTaskTableViewCell.nib, forCellReuseIdentifier: SystemTaskTableViewCell.reuseId)
        
        self.cancelButton.addShadow()
        self.cancelButton.layer.cornerRadius = 30
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.toolView.addShadow()
        self.toolView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("selectAction")
    }
    
    // MARK: - action
    func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionBuilder.allActions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SystemTaskTableViewCell.reuseId, forIndexPath: indexPath) as! SystemTaskTableViewCell
        cell.iconImage.image = UIImage(named: "app_phone")
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SystemTaskTableViewCell.rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("\(actionBuilder.allActions[indexPath.row].type)")
        selectedActionType = actionBuilder.allActions[indexPath.row].type
        guard let present = selectedActionType?.actionPresent() else { return }
        
        switch present {
        case .AddressBook:
            let addressVC = AddressBookViewController()
            addressVC.delegate = self
            self.navigationController?.pushViewController(addressVC, animated: true)
        }
    }
    
    // MARK: - TaskActionDataDelegate
    // such as name = zhoubo info = 18827420512
    // taskToText = 1$$zhoubo$$18827420512
    // show = call zhoubo
    func actionData(name: String, info: String) {
        guard let type = selectedActionType else { return }
        let taskToText = TaskStringManager().createTaskText(type.rawValue, name: name, info: info)
        newTaskDelegate?.toDoForSystemTask(type.ationNameWithType() + name, taskToDoText: taskToText)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol TaskActionDataDelegate: NSObjectProtocol {
    func actionData(name: String, info: String)
}
