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
    
    fileprivate let animation = LayerTransitioningAnimation()
    fileprivate let actionBuilder = SystemActionBuilder()
    fileprivate var selectedActionType: SystemActionType? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initControl()
        
        self.navigationController?.delegate = self
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
        self.cancelButton.createIconButton(iconSize: kBackButtonCorner,
                                           icon: backButtonIconString,
                                           color: colors.mainGreenColor, status: .normal)
        self.taskTableView.reloadData()
    }
    
    fileprivate func initControl() {
        self.taskTableView.tableFooterView = UIView()
        self.taskTableView.register(SystemTaskTableViewCell.nib, forCellReuseIdentifier: SystemTaskTableViewCell.reuseId)
        
        self.cancelButton.addShadow()
        self.cancelButton.layer.cornerRadius = kBackButtonCorner
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("selectAction")
    }
    
    // MARK: - action
    func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - table view
extension SystemTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actionBuilder.allActions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SystemTaskTableViewCell.reuseId, for: indexPath) as! SystemTaskTableViewCell
        let action = self.actionBuilder.allActions[indexPath.row]
        cell.iconImage.image = UIImage(named: action.actionImage)
        cell.taskTitle.text = Localized(action.hintString)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SystemTaskTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionType = actionBuilder.allActions[indexPath.row].type
        selectedActionType = actionType
        guard let present = selectedActionType?.actionPresent() else { return }
        
        switch present {
        case .addressBook:
            AddressBook.requestAccess {[unowned self] (finish) in
                let addressVC = AddressBookViewController.loadFromNib(true, delegate: self)
                
                self.navigationController?.pushViewController(addressVC, animated: true)
            }
            
        case .addressBookEmail:
            AddressBook.requestAccess {[unowned self] (finish) in
                let addressVC = AddressBookViewController.loadFromNib(false, delegate: self)
                self.navigationController?.pushViewController(addressVC, animated: true)
            }
            
        case .createSubtasks, .createCustomScheme:
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
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animation.reverse = operation == UINavigationControllerOperation.pop
        return animation
    }
}

// MARK: - TaskActionDataDelegate
extension SystemTaskViewController: TaskActionDataDelegate {
    
    // such as name = zhoubo info = 18827420512
    // taskToText = 1$$zhoubo$$18827420512
    // show = call zhoubo
    func actionData(_ name: String, info: String) {
        guard let type = selectedActionType else { return }
        // 返回task 信息
        let task = Task()
        // 用于 text field 显示用
        let attrText = NSMutableAttributedString()
        let colors = Colors()
        
        switch type.actionPresent() {
        case .addressBook, .addressBookEmail:
            let taskToText = TaskManager()
                .createTaskText(type.rawValue, name: name, info: info)
            task.taskToDo = taskToText
            
            attrText.append(
                NSAttributedString(string: type.ationNameWithType(), attributes:[
                    NSForegroundColorAttributeName: Colors.mainTextColor
                    ]))
            let nameAttrText = NSAttributedString(string: name, attributes: [
                NSForegroundColorAttributeName: colors.linkTextColor
                ])
            task.taskType = TaskType.system.type()
            attrText.append(nameAttrText)
            newTaskDelegate?.toDoForSystemTask(text: attrText, task: task)
            
        case .createSubtasks:
            task.taskToDo = name
            task.taskType = TaskType.custom.type()
            
            attrText.append(
                NSAttributedString(string: name, attributes:[
                    NSForegroundColorAttributeName: Colors.mainTextColor
                    ]))
            let subtaskCountString =
                NSAttributedString(string: Localized("subtaskCount"), attributes: [
                    NSForegroundColorAttributeName: Colors.secondaryTextColor
                    ])
            
            attrText.append(subtaskCountString)
            newTaskDelegate?.toDoForSystemSubtask(text: attrText, task: task, subtasks: info)
            
        case .createCustomScheme:
            let taskToText = TaskManager()
                .createTaskText(type.rawValue, name: name, info: info)
            task.taskToDo = taskToText
            task.taskType = TaskType.system.type()
            
            attrText.append(
                NSAttributedString(string: name, attributes:[
                    NSForegroundColorAttributeName: colors.linkTextColor
                    ]))
            
            newTaskDelegate?.toDoForSystemTask(text: attrText, task: task)
            
        default:
            return
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

protocol TaskActionDataDelegate: NSObjectProtocol {
    func actionData(_ name: String, info: String)
}
