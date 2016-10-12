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
    
    @IBOutlet weak var chartCardView: UIView!
    @IBOutlet weak var monthTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    fileprivate let chartView = LineChartView()
    fileprivate let checkIns: Array<CheckIn>
    fileprivate var needAdjustChartWeek = false
    
    init(checkIns: Array<CheckIn>) {
        self.checkIns = checkIns
        super.init(nibName: "MonthViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.checkIns = Array<CheckIn>()
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.view.backgroundColor = colors.mainGreenColor
        self.chartCardView.backgroundColor = colors.cloudColor
        
        self.chartView.chartDescription?.textColor = colors.mainTextColor
        self.chartView.leftAxis.labelTextColor = colors.mainTextColor
        self.chartView.xAxis.labelTextColor = colors.mainTextColor
        
        self.monthTableView.clearView()
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                         icon: backButtonIconString, color: colors.mainGreenColor,
                                         status: .normal)
    }
    
    fileprivate func initializeControl() {
        self.chartCardView.layer.cornerRadius = kCardViewCornerRadius
        self.initChart()
        self.initTableView()
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
    }
    
    // MARK: - actions
    func backAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
}

extension MonthViewController: UITableViewDelegate, UITableViewDataSource {
    fileprivate func initTableView() {
        self.monthTableView
            .register(MonthTableViewCell.nib, forCellReuseIdentifier: MonthTableViewCell.reuseId)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MonthTableViewCell.reuseId,
                                                 for: indexPath) as! MonthTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MonthTableViewCell.rowHeight
    }
}


extension MonthViewController: IAxisValueFormatter {
    fileprivate func initChart() {
        self.chartCardView.addSubview(chartView)
        self.chartCardView.addShadow()
        self.chartView.snp.makeConstraints { (make) in
            make.top.equalTo(self.chartCardView).offset(5)
            make.leading.equalTo(self.chartCardView)
            make.trailing.equalTo(self.chartCardView)
            make.bottom.equalTo(self.chartCardView).offset(-5)
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
        self.chartView.legend.enabled = false
        self.chartView.animate(yAxisDuration: 1.5)
        
        self.setMonthData()
    }
    
    fileprivate func setMonthData() {
        guard let count = NSDate().dayCountsInMonth() else { return }
        self.chartView.xAxis.setLabelCount(count, force: true)
        self.chartView.xAxis.labelCount = count
        
        var values = Array<ChartDataEntry>()
        
        if self.checkIns.count > 0 {
            var rats = self.checkIns.map { (c) -> Double in
                if c.createdCount == 0 {
                    return 0
                } else {
                    let rat = Double(c.completedCount) / Double(c.createdCount)
                    return rat * 100
                }
            }
            let appendCount = count - rats.count
            let appendArray = Array<Double>(repeating: 0.0, count: appendCount)
            rats.append(contentsOf: appendArray)
            
            for i in 0..<count {
                values.append(ChartDataEntry(x: Double(i), y: rats[i]))
            }
        }
        
        let set1 = LineChartDataSet(values: values, label: "date 1")
        set1.setColor(UIColor.clear)
        set1.fillColor = Colors().mainGreenColor
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
        let v = Int(value)
        let d = NSDate()
        let year = d.year()
        let month = d.month()
        
        guard let nd = NSDate(year: year, month: month, day: v)
            else { return "" }
        
        if v == 0 {
            self.needAdjustChartWeek = nd.weekday() != 1
        }
        
        if nd.weekday() == 1 {
            let s = nd.weekOfMonth() - (self.needAdjustChartWeek ? 1 : 0)
            if s > 4 {
                return ""
            } else {
                return String(format: Localized("monthlyWeek"), s)
            }
        } else {
            return ""
        }
    }
}

