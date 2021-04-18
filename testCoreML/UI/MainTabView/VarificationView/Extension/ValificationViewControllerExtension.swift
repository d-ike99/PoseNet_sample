//
//  ValificationViewControllerExtension.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/16.
//

import UIKit
import AVKit

extension ValificationViewController {
    internal func formatPlayTime(secounds:TimeInterval)->String{
        if secounds.isNaN{
            return "00:00"
        }
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    // 骨格検出処理
    internal func callPoseNet(mediaURL: URL!) throws {
        // 前処理
        /// URLから、動画を取得
        let asset = AVAsset(url: mediaURL)
        
        /// 画像変換器生成
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        /// 全体フレーム取得
        let time: CMTime = asset.duration
        print("time: ", time)
        
        var tmp_time: CMTime = time
        let progress_time: Int64 = (time.value / 10 ) / 20
        print("progress_time: ", progress_time)
        
        // バーの初期化
        self.bar.isHidden = false
        self.bar.progress = 0
        
        
        // poseNetによる解析
        do {
            /// フレーム数分ループ
            for time_i in (0..<time.value / 10) {
                
                /// 画像初期化
                let imageRef: CGImage
                
                /// 取得対象の画像指定
                tmp_time.value = min(time.value, time_i * 10)
                imageRef = try imageGenerator.copyCGImage(at: tmp_time, actualTime: nil)
                
                /// PoseNet解析時（delegateで、poseBuilder生成時）用に、一時画像を保存
                self.tmpCGImage = imageRef
                
                /// 予測(結果は、delegateにて処理を委譲)
                poseNet.predict(imageRef)
                
                /// 解析状況通知
                if (time_i) % progress_time == 0 {
                    let progress_per: Double = Double(time_i) / Double(time.value / 10) * 100
                    print("\(String(format: "%.2f%", progress_per))/ % 解析完了 ")
                    
                    /// 更新 (UIなのでメインスレッドで実行)
                    DispatchQueue.main.async {
                        
                        self.bar.setProgress(self.bar.progress + 0.05, animated: true)
                        self.view.setNeedsDisplay()
                    }
                }
                self.bar.isHidden = true
            }
        } catch {
            throw APIError.generateImage("画像変換失敗")
        }
        
        // poseNet後処理
        /// playerViewの「グラフ」更新
        self.playerView.updateGraphData(poseData: self.poses1!)
        
        /// 新規動画作成
        
    }
}
