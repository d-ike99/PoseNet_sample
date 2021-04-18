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
    
    internal func callPoseNet(mediaURL: URL!) throws {
        // URLから、動画を取得
        let asset = AVAsset(url: mediaURL)
        
        // 画像変換器生成
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        // 全体フレーム取得
        let time: CMTime = asset.duration
        print("time: ", time)
        
        var tmp_time: CMTime = time
        let progress_time: Int64 = time.value / 20
        
        // poseNetによる解析
        do {
            for time_i in (0..<time.value) {
                /// 画像初期化
                let imageRef: CGImage
                
                /// 取得対象の画像指定
                tmp_time.value = min(time.value, time_i)
                imageRef = try imageGenerator.copyCGImage(at: tmp_time, actualTime: nil)
                
                /// PoseNet解析時（delegateで、poseBuilder生成時）用に、一時画像を保存
                self.tmpCGImage = imageRef
                
                /// 予測(結果は、delegateにて処理を委譲)
                poseNet.predict(imageRef)
                
                /// 解析状況通知
                if time_i % progress_time == 0 {
                    let progress_per: Double = Double(time_i) / Double(time.value) * 100
                    print("\(String(format: "%.2f%", progress_per))/ % 解析完了 ")
                }
            }
        } catch {
            throw APIError.generateImage("画像変換失敗")
        }
    }
}
