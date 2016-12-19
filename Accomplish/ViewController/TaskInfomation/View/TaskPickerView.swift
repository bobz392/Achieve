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
    fileprivate let allTags = RealmManager.shared.allTags()
    
    var task: Task?
    fileprivate var index: String = ""
    fileprivate var viewShow = false
    
    fileprivate let TaskRepeatTag = 998
    fileprivate let TaskTagTag = 999
    
    override func awakeFromNib() {
        let colors = Colors()
        
        self.toolView.backgroundColor = colors.cloudColor
        self.leftButton.tintColor = colors.mainGreenColor
        self.rightButton.tintColor = colors.mainGreenColor
        self.backgroundColor = colors.cloudColor
        
        self.leftButton.setTitle(Localized("cancel"), for: .normal)
        self.toolView.addTopShadow()
        
        self.leftButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        self.rightButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        
        self.pickerView.isHidden = true
    }
    
    func close() {
        self.viewShow = false
    }
    
    func getIndex() -> String {
        return self.index
    }
    
    func viewIsShow() -> Bool {
        return self.viewShow
    }
    
    func repeatTimeType() -> RepeaterTimeType {
        return self.repeatTypes[self.pickerView.selectedRow(inComponent: 0)]
    }
    
    func selectedTagUUID() -> String? {
        let selectedRow = self.pickerView.selectedRow(inComponent: 0)
        if selectedRow == 0 {
            return nil
        } else {
            return self.allTags[selectedRow - 1].tagUUID
        }
    }

    func setIndex(index: String) {
        guard let task = self.task else { return }
        self.index = index
        self.viewShow = true
        self.pickerView.isHidden = true
        self.datePicker.isHidden = true
        let now = Date()
        self.datePicker.date = task.createdDate as Date? ?? now
        
        switch index {
        case TaskIconCalendar:
            self.datePicker.isHidden = false
            self.datePicker.minimumDate = now
            self.datePicker.datePickerMode = .dateAndTime
            self.rightButton.setTitle(Localized("setCreateDate"), for: .normal)
            self.datePicker.reloadInputViews()
            
        case TaskDueIconCalendar:
            self.datePicker.isHidden = false
            let date = task.createdDate?.addingMinutes(1) ?? now
            self.datePicker.minimumDate = date
            self.datePicker.date = date
            self.datePicker.datePickerMode = .time
            self.rightButton.setTitle(Localized("setEstimateDate"), for: .normal)
            self.datePicker.reloadInputViews()
            
        case TaskIconReminder:
            guard let createDate = task.createdDate else { break }
            self.datePicker.date = (task.estimateDate as? Date) ?? now
            self.datePicker.isHidden = false
            self.datePicker.datePickerMode = .time
            
            // 如果是今天的任务那么只能添加后面的提醒
            // 如果是今天以后的任务，那么一天随时都可以
            if createDate.isToday() {
                self.datePicker.minimumDate = now
            } else {
                self.datePicker.minimumDate = nil
            }
            
            self.rightButton.setTitle(Localized("setReminder"), for: .normal)
            self.datePicker.reloadInputViews()
            
        case TaskIconRepeat:
            self.pickerView.isHidden = false
            self.rightButton.setTitle(Localized("setRepeat"), for: .normal)
            self.pickerView.tag = self.TaskRepeatTag
            self.pickerView.reloadAllComponents()
            break
            
        case TaskTagIcon:
            self.pickerView.isHidden = false
            self.rightButton.setTitle(Localized("setTag"), for: .normal)
            self.pickerView.tag = self.TaskTagTag
            self.pickerView.reloadAllComponents()
            
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
        if pickerView.tag == self.TaskRepeatTag {
            return self.repeatTypes.count
        } else {
            return self.allTags.count + 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let title: String
        if pickerView.tag == TaskRepeatTag {
            guard let createDate = self.task?.createdDate else { return pickerLabel }
            title = self.repeatTypes[row].repeaterTitle(createDate: createDate)
        } else {
            if row == 0 {
                title = Localized("noneTag")
            } else {
                title = self.allTags[row - 1].name
            }
        }
        pickerLabel.text = title
        pickerLabel.textColor = Colors.mainTextColor
        pickerLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
