//
//  GraphView.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/02/14.
//

import UIKit
import Charts


class GraphView: UIView {

    // line chart view
    var chartView2 = LineChartView()

    // chart data
    var dataEntriesX = [ChartDataEntry]()
    var dataEntriesY = [ChartDataEntry]()

    var xValue: Double = 8

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 部品の設定
        setupViews()
        setupInitialDataEntries()
        setupChartData()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// 部品設定
extension GraphView {
    func setupViews() {
        //y
        chartView2.translatesAutoresizingMaskIntoConstraints = false
        chartView2.frame = CGRect(x: 0, y: (self.frame.height / 2) - 100, width: self.frame.width, height: 250)
        chartView2.leftAxis.axisMaximum = 700 //y左軸最大値
        chartView2.leftAxis.axisMinimum = 0.0 //y左軸最小値
        chartView2.leftAxis.labelCount = 5 //y軸ラベルの表示数
        chartView2.leftAxis.drawTopYLabelEntryEnabled = true //y軸の最大値


        chartView2.dragXEnabled = true
        self.chartView2.setVisibleXRange(minXRange: 0.0, maxXRange: 30.0)

        chartView2.rightAxis.enabled = false //y右軸を非表示
        chartView2.legend.enabled = true //凡例を表示


        self.addSubview(chartView2)
    }

    func setupInitialDataEntries() {
        (0..<Int(xValue)).forEach {
            let dataEntryX = ChartDataEntry(x: Double($0), y: 0)
            let dataEntryY = ChartDataEntry(x: Double($0), y: 0)
            dataEntriesX.append(dataEntryX)
            dataEntriesY.append(dataEntryY)
        }
    }

    func setupChartData() {
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

// update graph
extension GraphView {
    // update chart view
    public func didUpdatedChartView(poses: [Pose]) {

        // TODO: - 取得したposeを(yValue: Double, getXValue: Double)に変換する
        var pose1: CGPoint?
        var pose2: CGPoint?
        
        var pose1valid: Bool! = false
        var pose2valid: Bool! = false
        
        for pose in poses {
            // Draw the segment lines.
            for segment in PoseImageView.jointSegments {
                let jointA = pose[segment.jointA]
                let jointB = pose[segment.jointB]

                guard jointA.isValid, jointB.isValid else {
                    continue
                }
            }
            pose1 = pose[.leftShoulder].position
            pose2 = pose[.rightElbow].position
            
            //pose1valid = pose[.].isValid
            pose2valid = pose[.rightElbow].isValid
        }


        // 新しいデータを作成する（補足：1点のデータ）
        if pose1valid {
            let newDataEntryX: ChartDataEntry = ChartDataEntry(x: self.xValue, y: Double(pose1!.y))
            updateChartView(with: newDataEntryX, dataEntries: &dataEntriesX, dispIndex: 0)
            
            print("testY", pose1!.y)
            print("testX", pose1!.x)
        }
        
        if pose2valid {
            let newDataEntryY: ChartDataEntry = ChartDataEntry(x: self.xValue, y: Double(pose2!.y))
            updateChartView(with: newDataEntryY, dataEntries: &dataEntriesY, dispIndex: 1)
        }

        self.xValue += 1
    }

    // viewの更新
    internal func updateChartView(with newDataEntry: ChartDataEntry, dataEntries: inout [ChartDataEntry], dispIndex: Int) {

        // データの追加
        dataEntries.append(newDataEntry)
        chartView2.data?.addEntry(newDataEntry, dataSetIndex: dispIndex)

        // viewの表示更新
        chartView2.notifyDataSetChanged()

        //　移動する？
        chartView2.moveViewToX(newDataEntry.x)
    }
}
