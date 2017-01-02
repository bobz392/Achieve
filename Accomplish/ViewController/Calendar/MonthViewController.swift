//
//  MonthViewController.swift
//  Accomplish
//
//  Created by zhoubo on 2016/10/10.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import Charts

class MonthViewController: BaseViewController, ChartViewDelegate {
    
    fileprivate let emptyDataLabel = UILabel()
    fileprivate let monthTableView = UITableView()
    fileprivate let chartView = LineChartView()
    
    fileprivate var monthlyTasks = Array<Task>()
    fileprivate var taskDict = Dictionary<String, Array<Int>>()
    
    let monthRepeatFormat = NumberFormatter()
    var queryFormat = ""
    
    init(queryFormat: String) {
        self.queryFormat = queryFormat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: false)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        self.createTitleLabel(titleText: Localized("monthly"), style: .center)
        self.initChart(bar: bar)
        
        self.fetchMonthlyTasks()
        self.initTableView(chartView: self.chartView)
        
        self.emptyDataLabel.font = UIFont.systemFont(ofSize: 16)
        self.emptyDataLabel.textColor = Colors.mainTextColor
        self.emptyDataLabel.text = Localized("noMonthlyData")
        self.view.addSubview(self.emptyDataLabel)
        self.emptyDataLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.monthTableView)
        }
    }
    
    // MARK: - actions
    fileprivate func fetchMonthlyTasks() {
        let tasks = RealmManager.shared.queryMonthlyTask(format: queryFormat)
        
        for task in tasks {
            // 如果是重复任务
            if let repeatUUID = task.repeaterUUID {
                if self.taskDict[repeatUUID] == nil {
                    var array: [Int]
                    if task.taskStatus() == .completed {
                        array = [1, 1]
                    } else {
                        array = [0, 1]
                    }
                    self.taskDict[repeatUUID] = array
                    self.monthlyTasks.append(task)
                } else {
                    if var array = self.taskDict[repeatUUID],
                        array.count == 2 {
                        if task.taskStatus() == .completed {
                            array[0] = 1 + array[0]
                            array[1] = 1 + array[1]
                        } else {
                            array[1] = 1 + array[1]
                        }
                        
                        self.taskDict[repeatUUID] = array
                    }
                }
            } else {
                self.monthlyTasks.append(task)
            }
        }
        
        if tasks.count > 0 {
            self.monthTableView.reloadData()
            self.emptyDataLabel.isHidden = true
        } else {
            self.emptyDataLabel.isHidden = false
        }
    }
}

extension MonthViewController: UITableViewDelegate, UITableViewDataSource {
    fileprivate func initTableView(chartView: LineChartView) {
        self.monthTableView.backgroundColor = Colors.mainBackgroundColor
        self.monthTableView.delegate = self
        self.monthTableView.dataSource = self
        self.monthTableView.allowsSelection = false
        self.view.addSubview(self.monthTableView)
        self.monthTableView.snp.makeConstraints { (make) in
            make.top.equalTo(chartView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
        self.monthTableView.tableFooterView = UIView()
        self.monthTableView
            .register(MonthTableViewCell.nib, forCellReuseIdentifier: MonthTableViewCell.reuseId)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.monthlyTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MonthTableViewCell.reuseId,
                                                 for: indexPath) as! MonthTableViewCell
        
        let task = self.monthlyTasks[indexPath.row]
        cell.taskNameLabel.text = task.realTaskToDo()
        
        if let repeaterUUID = task.repeaterUUID {
            if let repeater = RealmManager.shared.queryRepeaterWithUUID(repeatUUID: repeaterUUID),
                let createdDate = task.createdDate,
                let repeaterType = RepeaterTimeType(rawValue: repeater.repeatType) {
                
                cell.infoLabel.text =
                    String(format: Localized("repeaterMonth"), repeaterType.repeaterTitle(createDate: createdDate))
                
                if let arr = self.taskDict[repeaterUUID],
                    arr.count == 2 {
                    cell.leftDetailLabel.text =
                        String(format: Localized("repeaterTimes"), arr[1])
                    
                    let rateInt = Int(Double(arr[0]) / Double(arr[1]) * 100)
                    let rate = NSNumber(value: rateInt)
                    let rateString = (self.monthRepeatFormat.string(from: rate) ?? "") + "%"
                    cell.rightDetailLabel.text =
                        String(format: Localized("repeaterRates"), rateString)
                } else {
                    cell.leftDetailLabel.text = ""
                    cell.rightDetailLabel.text = ""
                }
            }
        } else {
            cell.configPostpone(task: task)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MonthTableViewCell.rowHeight
    }
}

extension MonthViewController: IAxisValueFormatter {
    fileprivate func initChart(bar: UIView) {
        let cardView = UIView()
        cardView.backgroundColor = Colors.cellCardColor
        cardView.addCardShadow()
        cardView.layer.cornerRadius = 4
        self.view.addSubview(cardView)
        cardView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(150)
        }
        
        self.monthRepeatFormat.numberStyle = .decimal
        self.monthRepeatFormat.maximumFractionDigits = 2
        
        self.chartView.chartDescription?.textColor = Colors.mainIconColor
        self.chartView.leftAxis.labelTextColor = Colors.mainIconColor
        self.chartView.xAxis.labelTextColor = Colors.mainIconColor
        cardView.addSubview(chartView)
        
        self.chartView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        self.chartView.isUserInteractionEnabled = false
        self.chartView.chartDescription?.text = Localized("completionRates")
        self.chartView.dragEnabled = false
        self.chartView.setScaleEnabled(false)
        self.chartView.pinchZoomEnabled = false
        self.chartView.drawGridBackgroundEnabled = false
        self.chartView.leftAxis.enabled = true
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.negativeSuffix = "%"
        leftAxisFormatter.positiveSuffix = "%"
        
        self.chartView.leftAxis.valueFormatter =
            DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        self.chartView.leftAxis.axisMaximum = 100
        self.chartView.leftAxis.axisMinimum = 0
        self.chartView.leftAxis.drawGridLinesEnabled = false
        self.chartView.rightAxis.enabled = false
        self.chartView.xAxis.drawGridLinesEnabled = false
        self.chartView.xAxis.labelPosition = .bottom
        self.chartView.xAxis.valueFormatter = self
        self.chartView.xAxis.setLabelCount(6, force: true)
        self.chartView.legend.enabled = false
        self.chartView.animate(yAxisDuration: 1.5)
        
        self.setMonthData()
    }
    
    fileprivate func setMonthData() {
        guard let count = NSDate().dayCountsInMonth() else { return }
        var values = Array<ChartDataEntry>()
        
        var lastDay = 0
        let checkIns = RealmManager.shared.monthlyCheckIn(format: self.queryFormat)
            
        for day in 0..<count {
            
            if lastDay >= checkIns.count {
                values.append(ChartDataEntry(x: Double(day), y: 0))
            } else {
                let checkIn = checkIns[lastDay]
                
                if "\(queryFormat).\(String(format: "%02d", day))" == checkIn.formatedDate {
                    var rate: Double = 0
                    if checkIn.createdCount > 0 {
                        rate = Double(checkIn.completedCount) / Double(checkIn.createdCount) * 100.0
                    }
                    values.append(ChartDataEntry(x: Double(day), y: rate))
                    lastDay += 1
                } else {
                    values.append(ChartDataEntry(x: Double(day), y: 0))
                }
            }
        }
        
        let set1 = LineChartDataSet(values: values, label: "date 1")
        set1.setColor(UIColor.clear)
        set1.fillColor = Colors.cellLabelSelectedTextColor
        set1.drawCirclesEnabled = false
        set1.drawCircleHoleEnabled = false
        set1.mode = .cubicBezier
        set1.drawValuesEnabled = false
        set1.drawFilledEnabled = true
        
        var dataSets = Array<IChartDataSet>()
        dataSets.append(set1)
        
        let data = LineChartData(dataSets: dataSets)
        self.chartView.data = data
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(value) + 1)"
    }
}

