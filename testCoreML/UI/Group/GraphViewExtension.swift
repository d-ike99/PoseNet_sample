//
//  GraphViewExtension.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/19.
//
import Charts
import UIKit

// 部品設定
extension GraphView {
    // グラフの画面設定
    internal func setupViews() {
        //y
        chartView2.translatesAutoresizingMaskIntoConstraints = false
        chartView2.frame = self.bounds
        //chartView2.leftAxis.axisMaximum = 50 //y左軸最大値
//        chartView2.leftAxis.axisMinimum = 0.0 //y左軸最小値
//        chartView2.leftAxis.labelCount = 1 //y軸ラベルの表示数
        chartView2.leftAxis.drawTopYLabelEntryEnabled = true //y軸の最大値

        chartView2.dragXEnabled = true
        //self.chartView2.setVisibleXRange(minXRange: 0.0, maxXRange: 30.0)

        chartView2.rightAxis.enabled = false //y右軸を非表示
        chartView2.legend.enabled = false //凡例を表示
        //chartView2.moveViewToX(<#T##xValue: Double##Double#>)

        self.addSubview(chartView2)
    }
    // グラフの初期データ投入
    internal func setupInitialDataEntries() {
//        (0..<Int(xValue)).forEach {
//            let dataEntryX = ChartDataEntry(x: Double($0), y: 0)
//            let dataEntryY = ChartDataEntry(x: Double($0), y: 0)
//            dataEntriesX.append(dataEntryX)
//            dataEntriesY.append(dataEntryY)
//        }
    }

    // 
    internal func setupChartData() {
        //y
        let chartDataSetX = LineChartDataSet(entries: dataEntriesX, label: "y-ac")
        chartDataSetX.drawCirclesEnabled = false
        chartDataSetX.setColor(NSUIColor.green)
        chartDataSetX.mode = .linear
        chartDataSetX.drawValuesEnabled = false

        let chartDataSetY = LineChartDataSet(entries: dataEntriesY, label: "lefyElbow")
        chartDataSetY.drawCirclesEnabled = false
        chartDataSetY.setColor(NSUIColor.blue)
        chartDataSetY.mode = .linear
        chartDataSetY.drawValuesEnabled = false

        var test: [LineChartDataSet] = [LineChartDataSet]()
        test.append(chartDataSetX)
        test.append(chartDataSetY)

        let chartData2 = LineChartData(dataSets: test)
        chartView2.data = chartData2
        chartView2.xAxis.labelPosition = .bottom

    }
}
