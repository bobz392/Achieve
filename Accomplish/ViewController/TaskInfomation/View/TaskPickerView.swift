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

    private let repeatTypes: [RepeaterTimeType] = [.Daily, .Weekday, .EveryWeek, .EveryMonth, .Annual]
    
    var task: Task?
    private var index: Int = 0
    private var viewShow = false
    
    override func awakeFromNib() {
        let colors = Colors()
        
        self.toolView.backgroundColor = colors.cloudColor
        self.leftButton.tintColor = colors.mainGreenColor
        self.rightButton.tintColor = colors.mainGreenColor
        self.backgroundColor = colors.cloudColor
        
        self.leftButton.setTitle(Localized("cancel"), forState: .Normal)
        self.toolView.addTopShadow()
        
        self.leftButton.addTarget(self, action: #selector(self.close), forControlEvents: .TouchUpInside)
        self.rightButton.addTarget(self, action: #selector(self.close), forControlEvents: .TouchUpInside)
        
        self.pickerView.hidden = true
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
        return repeatTypes[self.pickerView.selectedRowInComponent(0)]
    }
    
    func setIndex(index: Int) {
        guard let task = self.task else { return }
        self.index = index
        self.viewShow = true
        self.pickerView.hidden = true
        self.datePicker.hidden = true
        let now = NSDate()
        self.datePicker.date = task.createdDate ?? now
        
        switch index {
        case 0:
            self.datePicker.hidden = false
            self.datePicker.minimumDate = now
            self.datePicker.datePickerMode = .DateAndTime
            self.rightButton.setTitle(Localized("setCreateDate"), forState: .Normal)
            self.datePicker.reloadInputViews()
            
        case 1:
            guard let createDate = task.createdDate else { break }
            self.datePicker.date = now
            self.datePicker.hidden = false
            self.datePicker.datePickerMode = .Time
            
            // 如果是今天的任务那么只能添加后面的提醒
            // 如果是今天以后的任务，那么一天随时都可以
            if createDate.isToday() {
                self.datePicker.minimumDate = NSDate()
            } else {
                self.datePicker.minimumDate = nil
            }
            
            self.rightButton.setTitle(Localized("setReminder"), forState: .Normal)
            self.datePicker.reloadInputViews()
        
        case 2:
            self.pickerView.hidden = false
            self.rightButton.setTitle(Localized("setRepeat"), forState: .Normal)
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
        return self.repeatTimeType().repeaterTitle(createDate)
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.repeatTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let createDate = self.task?.createdDate else { return nil }
        let title = self.repeatTypes[row].repeaterTitle(createDate)
        return NSAttributedString(string: title,
                                  attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)])
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
}
