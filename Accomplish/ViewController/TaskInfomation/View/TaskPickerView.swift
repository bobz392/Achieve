//
//  DatePickerView.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TaskPickerView: UIView {

    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    static let height: CGFloat = 245

    fileprivate let repeatTypes: [RepeaterTimeType] = [.daily, .weekday, .everyWeek, .everyMonth, .annual]
    
    var task: Task?
    fileprivate var index: Int = 0
    fileprivate var viewShow = false
    
    override func awakeFromNib() {
        let colors = Colors()
        
        self.toolView.backgroundColor = colors.cloudColor
        self.leftButton.tintColor = colors.mainGreenColor
        self.rightButton.tintColor = colors.mainGreenColor
        self.backgroundColor = colors.cloudColor
        
        self.leftButton.setTitle(Localized("cancel"), for: UIControlState())
        self.toolView.addTopShadow()
        
        self.leftButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        self.rightButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        
        self.pickerView.isHidden = true
    }
    
    func close() {
        self.viewShow = false
    }
    
    func getIndex() -> Int {
        return index
    }
    
    func viewIsShow() -> Bool {
        return viewShow
    }
    
    func repeatTimeType() -> RepeaterTimeType {
        return repeatTypes[self.pickerView.selectedRow(inComponent: 0)]
    }
    
    func setIndex(index: Int) {
        guard let task = self.task else { return }
        self.index = index
        self.viewShow = true
        self.pickerView.isHidden = true
        self.datePicker.isHidden = true
        let now = Date()
        self.datePicker.date = task.createdDate as Date? ?? now
        
        switch index {
        case 0:
            self.datePicker.isHidden = false
            self.datePicker.minimumDate = now
            self.datePicker.datePickerMode = .dateAndTime
            self.rightButton.setTitle(Localized("setCreateDate"), for: UIControlState())
            self.datePicker.reloadInputViews()
        
        case TaskDueIndex:
            self.datePicker.isHidden = false
            self.datePicker.minimumDate = ((task.createdDate as NSDate?)?.addingMinutes(15)) ?? now
            self.datePicker.datePickerMode = .time
            self.rightButton.setTitle(Localized("setEstimateDate"), for: UIControlState())
            self.datePicker.reloadInputViews()
        
        case TaskReminderIndex:
            guard let createDate = task.createdDate else { break }
            self.datePicker.date = now
            self.datePicker.isHidden = false
            self.datePicker.datePickerMode = .time
            
            // 如果是今天的任务那么只能添加后面的提醒
            // 如果是今天以后的任务，那么一天随时都可以
            if (createDate as NSDate).isToday() {
                self.datePicker.minimumDate = now
            } else {
                self.datePicker.minimumDate = nil
            }
            
            self.rightButton.setTitle(Localized("setReminder"), for: UIControlState())
            self.datePicker.reloadInputViews()
        
        case TaskRepeatIndex:
            self.pickerView.isHidden = false
            self.rightButton.setTitle(Localized("setRepeat"), for: UIControlState())
            self.pickerView.reloadAllComponents()
            break
            
        default:
            break
        }
    }
}

extension TaskPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func repeaterSelectedTitle() -> String {
        guard let createDate = self.task?.createdDate else { return "" }
        return self.repeatTimeType().repeaterTitle(createDate: createDate)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.repeatTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let createDate = self.task?.createdDate else { return nil }
        let title = self.repeatTypes[row].repeaterTitle(createDate: createDate)
        return NSAttributedString(string: title,
                                  attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
