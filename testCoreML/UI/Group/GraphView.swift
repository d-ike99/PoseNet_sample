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

// update graph
extension GraphView {
    // グラフの更新する
    public func didUpdatedChartView(poses: [Pose]) {
        /// 初期化
        var pose1: CGPoint?
        var tmp_maxY: CGFloat! = 0
        var tmp_minY: CGFloat! = 0
        /// poseデータの取得
        for pose in poses {
            // Draw the segment lines.
            for segment in PoseImageView.jointSegments {
                let jointA = pose[segment.jointA]
                let jointB = pose[segment.jointB]

                guard jointA.isValid, jointB.isValid else {
                    continue
                }
            }
            pose1 = pose[.rightWrist].position
        }

        /// グラフ表示用データの作成
        var get_pose: CGFloat?
        if pose1?.y != nil {
            get_pose = pose1!.y
            if tmp_maxY < pose1!.y {
                tmp_maxY = pose1!.y
            }
            if tmp_minY > pose1!.y {
                tmp_minY = pose1!.y
            }
        }
        else {
            get_pose = 0
        }
        let newDataEntryX: ChartDataEntry = ChartDataEntry(x: self.xValue, y: Double(get_pose!))
        
        /// グラフの表示内容更新
        updateChartView(with: newDataEntryX, dataEntries: &dataEntriesX, dispIndex: 0)
        
        chartView2.leftAxis.axisMaximum = Double(tmp_maxY + 50) //y左軸最大値
        chartView2.leftAxis.axisMinimum = Double(tmp_minY - 50)
        
        self.xValue += 1
    }

    // グラフの表示内容を更新する
    internal func updateChartView(with newDataEntry: ChartDataEntry, dataEntries: inout [ChartDataEntry], dispIndex: Int) {
        /// データの追加
        dataEntries.append(newDataEntry)
        chartView2.data?.addEntry(newDataEntry, dataSetIndex: dispIndex)

        /// viewの表示更新
        chartView2.notifyDataSetChanged()

        //　移動する？
        //chartView2.moveViewToX(newDataEntry.x)
    }
    
    // グラフの表示位置の更新
    public func updateDispPos(poseRatio: Double){
        self.chartView2.setNeedsDisplay()
        self.chartView2.highlightValue(x: round(self.xValue * poseRatio), dataSetIndex: 0)  // 本メソッドは、touchイベントを参考に、chartsのソースを調査した
    }
}
