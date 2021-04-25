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
        // ログ
        print("callPoseNet start")
        
        // 前処理
        /// URLから、動画を取得
        let asset = AVAsset(url: mediaURL)
                        
        /// tmp
        let time: CMTime = asset.duration
        print("time: ", time)
        
        let progress_time: Int64 = (time.value / 10 ) / 20
        print("progress_time: ", progress_time)
        
        /// set AVAssetReader
        let reader = try! AVAssetReader(asset: asset)
        let videoTrack = asset.tracks(withMediaType: .video).first!
        print("test: ", asset.tracks(withMediaType: .video))
        let outputSettings = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)]
        let trackReaderOutput = AVAssetReaderTrackOutput(track: videoTrack,
                                                         outputSettings: outputSettings)
        let fps = videoTrack.nominalFrameRate
        print("fps: ", fps)

        reader.add(trackReaderOutput)
        reader.startReading()
        
        // バーの初期化
//        self.bar.isHidden = false
//        self.bar.progress = 0
        
        // poseNetによる解析
        do {
            /// フレーム数分ループ
            while let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
                if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    /// ピクセルバッファをベースにCoreImageのCIImageオブジェクトを作成
                    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                    
                    /// 画面回転
                    let orientation :CGImagePropertyOrientation = CGImagePropertyOrientation.right
                    let orientation2 :CGImagePropertyOrientation = CGImagePropertyOrientation.right
                    let orientedImage = ciImage.oriented(orientation)
                    let orientedImage2 = orientedImage.oriented(orientation2)
                    
                    /// CGImageを作成
                    let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
                    let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
                    let imageRect:CGRect = CGRect(x: 0, y: 0, width: pixelBufferWidth, height: pixelBufferHeight )
                    let ciContext = CIContext.init()
                    let cgimage = ciContext.createCGImage(orientedImage2, from: imageRect )
                                    
                    /// Pose
                    self.tmpCGImage = cgimage
                    
                    /// 予測(結果は、delegateにて処理を委譲)
                    poseNet.predict(cgimage!)
                }
            }
        } catch {
            throw APIError.generateImage("画像変換失敗")
        }
        
        // poseNet後処理
        /// playerViewの「グラフ」更新
        self.playerView.updateGraphData(poseData: self.poses1!)
    }
    
    // 新規動画作成
    internal func createPoseMovie(asset: AVAsset){
        
        /// 初期化
        var createImages: [UIImage] = [UIImage]()
                
        /// set AVAssetReader
        let reader = try! AVAssetReader(asset: asset)
        let videoTrack = asset.tracks(withMediaType: .video).first!
        let outputSettingss = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)]
        let trackReaderOutput = AVAssetReaderTrackOutput(track: videoTrack,
                                                         outputSettings: outputSettingss)
        
        reader.add(trackReaderOutput)
        reader.startReading()
        
        // 合成処理
        do {
            var loop_i: Int = 0
            while let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
                if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    /// ピクセルバッファをベースにCoreImageのCIImageオブジェクトを作成
                    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                    
                    /// 画面回転
                    let orientation :CGImagePropertyOrientation = CGImagePropertyOrientation.right
                    let orientation2 :CGImagePropertyOrientation = CGImagePropertyOrientation.right
                    let orientedImage = ciImage.oriented(orientation)
                    let orientedImage2 = orientedImage.oriented(orientation2)
                    
                    /// CIImageからCGImageを作成
                    let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
                    let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
                    let imageRect:CGRect = CGRect(x: 0, y: 0, width: pixelBufferWidth, height: pixelBufferHeight )
                    let ciContext = CIContext.init()
                    let cgimage = ciContext.createCGImage(orientedImage2, from: imageRect )
                    
                    /// 画像合成
                    createImages.append( self.tmpPoseImageView.createNewImage(poses: self.poses1![loop_i], on: cgimage!) )
                    
                    /// カウント
                    loop_i += 1
                    print("loop_i: ", loop_i)
                }
            }
        }
        
        // 動画作成
        /// 生成した動画を保存するパス
        let tempDir = FileManager.default.temporaryDirectory
        let previewURL:URL = tempDir.appendingPathComponent("preview.mp4")
        
        /// 既にファイルがある場合は削除する
        let fileManeger = FileManager.default
        if fileManeger.fileExists(atPath: previewURL.path) {
            try! fileManeger.removeItem(at: previewURL)
        }
        
        /// サイズ指定
        let size = createImages.first!.size
        
        guard let videoWriter = try? AVAssetWriter(outputURL: previewURL, fileType: AVFileType.mp4) else {
            abort()
        }

        let outputSettings: [String : Any] = [
            AVVideoCodecKey: AVVideoCodecType.hevc,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        
        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
        videoWriter.add(writerInput)
        
        let sourcePixelBufferAttributes: [String:Any] = [
            AVVideoCodecKey: Int(kCVPixelFormatType_32ARGB),
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        writerInput.expectsMediaDataInRealTime = true

        // 動画生成開始
        if (!videoWriter.startWriting()) {
            print("Failed to start writing.")
            return
        }
        
        videoWriter.startSession(atSourceTime: CMTime.zero)
        
        var frameCount: Int64 = 0
        let durationForEachImage: Int64 = 1
        let fps: Int32 = 30
        
        for image in createImages {
            if !adaptor.assetWriterInput.isReadyForMoreMediaData {
                print("skip frameCount: ", frameCount)
                continue
            }
            
            //let frameTime: CMTime = CMTimeMake(value: frameCount * Int64(fps) * durationForEachImage, timescale: fps)
            let frameTime: CMTime = CMTimeMake(value: frameCount * durationForEachImage, timescale: fps)
            guard let buffer = pixelBuffer(for: image.cgImage) else {
                continue
            }
            //時間経過を確認(確認用)
            let second = CMTimeGetSeconds(frameTime)
            print(second)
            
            if !adaptor.append(buffer, withPresentationTime: frameTime) {
                print("Failed to append buffer. [image : \(image)]")
            }
            
            frameCount += 1
            print("frameCount: ", frameCount)
        }
        
        // 動画生成終了
        writerInput.markAsFinished()
        videoWriter.endSession(atSourceTime: CMTimeMake(value: frameCount * Int64(fps) * durationForEachImage, timescale: fps))
        videoWriter.finishWriting {
            print("Finish writing!")
        }
        
    }
    
    func pixelBuffer(for cgImage: CGImage?) -> CVPixelBuffer? {
        guard let cgImage = cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let options = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary
        
        var buffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                            kCVPixelFormatType_32ARGB, options, &buffer)
        
        guard let pixelBuffer = buffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let pxdata = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * width,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(x:0, y:0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
