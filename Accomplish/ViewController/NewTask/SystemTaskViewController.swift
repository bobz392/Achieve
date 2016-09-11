//
//  SystemViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SystemTaskViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var newTaskDelegate: NewTaskDataDelegate? = nil
    
    private let animation = LayerTransitioningAnimation()
    private let actionBuilder = SystemActionBuilder()
    private var selectedActionType: SystemActionType? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        configMainUI()
        initControl()
        
        self.navigationController?.delegate = self
        //        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.cancelButton.buttonColor(colors)
        self.cancelButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                           icon: backButtonIconString, color: colors.mainGreenColor, status: .Normal)
        self.taskTableView.reloadData()
    }
    
    private func initControl() {
        if #available(iOS 9, *) {
            self.taskTableView.cellLayoutMarginsFollowReadableWidth = false
        }
        self.taskTableView.tableFooterView = UIView()
        self.taskTableView.registerNib(SystemTaskTableViewCell.nib, forCellReuseIdentifier: SystemTaskTableViewCell.reuseId)
        
        self.cancelButton.addShadow()
        self.cancelButton.layer.cornerRadius = kBackButtonCorner
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("selectAction")
    }
    
    // MARK: - action
    func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - table view
extension SystemTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionBuilder.allActions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SystemTaskTableViewCell.reuseId, forIndexPath: indexPath) as! SystemTaskTableViewCell
        let action = actionBuilder.allActions[indexPath.row]
        cell.iconImage.image = UIImage(named: action.actionImage)
        cell.taskTitle.text = Localized(action.hintString)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SystemTaskTableViewCell.rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let actionType = actionBuilder.allActions[indexPath.row].type
        selectedActionType = actionType
        guard let present = selectedActionType?.actionPresent() else { return }
        
        switch present {
        case .AddressBook:
            AddressBook.requestAccess {[unowned self] (finish) in
                let addressVC = AddressBookViewController.loadFromNib(true, delegate: self)
                
                self.navigationController?.pushViewController(addressVC, animated: true)
            }
            
        case .AddressBookEmail:
            AddressBook.requestAccess {[unowned self] (finish) in
                let addressVC = AddressBookViewController.loadFromNib(false, delegate: self)
                self.navigationController?.pushViewController(addressVC, animated: true)
            }
            
        case .CreateSubtasks:
            let task = KVTaskViewController(actionType: actionType, delegate: self)
            self.navigationController?.pushViewController(task, animated: true)
            break
            
        default:
            break
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SystemTaskViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animation.reverse = operation == UINavigationControllerOperation.Pop
        return animation
    }
}

// MARK: - TaskActionDataDelegate
extension SystemTaskViewController: TaskActionDataDelegate {
    
    // such as name = zhoubo info = 18827420512
    // taskToText = 1$$zhoubo$$18827420512
    // show = call zhoubo
    func actionData(name: String, info: String) {
        guard let type = selectedActionType else { return }
        // 返回task 信息
        let task = Task()
        task.taskType = kSystemTaskType
        // 用于 text field 显示用
        let attrText = NSMutableAttributedString()
        
        switch type.actionPresent() {
        case .AddressBook, .AddressBookEmail:
            let taskToText = TaskManager().createTaskText(type.rawValue, name: name, info: info)
            task.taskToDo = taskToText
            
            attrText.appendAttributedString(
                NSAttributedString(string: type.ationNameWithType(), attributes:[
                    NSForegroundColorAttributeName: Colors().mainTextColor
                    ]))
            let nameAttrText = NSAttributedString(string: name, attributes: [
                NSForegroundColorAttributeName: Colors().linkTextColor
                ])
            
            attrText.appendAttributedString(nameAttrText)
            newTaskDelegate?.toDoForSystemTask(attrText, task: task)
            
        case .CreateSubtasks:
            let taskToText = TaskManager().createTaskText(type.rawValue, name: name, info: nil)
            task.taskToDo = taskToText.componentsSeparatedByString(kSpliteTaskIdentity).last ?? ""
            
            let nameAttrText = NSAttributedString(string: name)
            attrText.appendAttributedString(nameAttrText)
            newTaskDelegate?.toDoForSystemSubtask(attrText, task: task, subtasks: info)
            
        default:
            return
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol TaskActionDataDelegate: NSObjectProtocol {
    func actionData(name: String, info: String)
}
