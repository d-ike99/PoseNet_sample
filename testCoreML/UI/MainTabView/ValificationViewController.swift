//
//  ValificationViewController.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/14.
//

import UIKit
import AVKit

class ValificationViewController: UIViewController {

    // poseNet
    /// poseNet Module
    internal var poseNet: PoseNet!
    /// The set of parameters passed to the pose builder when detecting poses.
    private var poseBuilderConfiguration = PoseBuilderConfiguration()
    ///
    
    // 部品
    /// 写真アプリアクセスコントローラー
    var imagePickerController: UIImagePickerController!
    /// 動画表示関連の部品
    var playerItem: AVPlayerItem!
    var avplayer: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var playerItem2: AVPlayerItem!
    var avplayer2: AVPlayer!
    var playerLayer2: AVPlayerLayer!
    /// 画面部品
    var playerView: PlayerView!
    var playerView2: PlayerView!
    var link: CADisplayLink!
    var link2: CADisplayLink!
    /// progress bar
    var bar: UIProgressView!
    
    // 表示用部品
    var videoURL: URL?
    var videoURL2: URL?
    var poses1: [[Pose]]?
    var poses2: [[Pose]]?
    
    // tmp
    var imageView: UIImageView!
    internal var AnalysisObj: Int! = 0
    internal var tmpCGImage: CGImage?
    
    override func viewDidLoad() {
        // poseNet設定
        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        
        // navigation barの非表示設定
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 画面部品設定
        /// 写真へアプリのアクセス
        self.imagePickerController = UIImagePickerController()
        
        /// 部品
        let testButton: UIButton = UIButton()
        testButton.frame = CGRect(x: 10, y: 50, width: 60, height: 30)
        testButton.setTitle("読込", for: .normal)
        testButton.setTitleColor(.red, for: .normal)
        testButton.tag = 1
        testButton.addTarget(self, action: #selector(accessPicApp), for: UIControl.Event.touchUpInside)
        
        /// 動画表示1
        let playerFrame = CGRect(x: self.view.frame.width / 6, y: 30, width: self.view.frame.width / 3 * 2, height: self.view.frame.height / 5 * 2)
        self.playerView = PlayerView(frame: playerFrame)
        playerView.backgroundColor = .systemGray
        playerView.delegate = self
        
        let playerFrame2 = CGRect(x: self.view.frame.width / 6, y: 60 + self.view.frame.height / 5 * 2, width: self.view.frame.width / 3 * 2, height: self.view.frame.height / 5 * 2)
        self.playerView2 = PlayerView(frame: playerFrame2)
        playerView2.backgroundColor = .systemGray
        playerView2.delegate = self
        
        /// tmp
        imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: self.view.frame.height / 2, width: 50, height: 50)
        
        /// progress bar
        self.bar = UIProgressView()
        bar.frame = CGRect(x: self.view.frame.width / 4, y: self.view.frame.height / 3, width: self.view.frame.width / 2, height: 10)
        bar.progress = 0
        bar.isHidden = true
        bar.progressTintColor = .systemBlue
        bar.transform = CGAffineTransform(scaleX: 1.0, y: 5)
        
        self.view.backgroundColor = .systemGray5
        self.view.addSubview(testButton)
        self.view.addSubview(playerView)
        self.view.addSubview(playerView2)
        self.view.addSubview(imageView)
        self.view.addSubview(bar)
    }
    
    //画面消える時にremove
    deinit{
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "status")
    }

   //監視イベント
   //Unknown 、ReadyToPlay 、 Failed状態があり、readyToPlayの際のみ再生
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
            if keyPath == "loadedTimeRanges"{
                // TODO
            }else if keyPath == "status"{
                if playerItem.status == AVPlayerItem.Status.readyToPlay{
                    //self.avplayer.play()
                }else{
                    print("error")
                }
            }
    }
    
    // 「ファイル」ボタン押下処理
    @objc func accessPicApp(_ sender: UIButton){
        print("UIBarButtonItem。カメラロールから動画を選択")
        
        // アクセス対象のplayerViewの判断
        self.AnalysisObj = sender.tag
        
        // 写真アプリのアクセス設定
        /// パラメータ設定
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        /// 動画取得設定
        imagePickerController.mediaTypes = ["public.movie"]
        
        /// 写真アプリ表示処理
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // シークバー関連の更新
    @objc func update(){
        // 動画の再生位置に従い、シークバーを更新する
        let currentTime = CMTimeGetSeconds(self.avplayer.currentTime())
        
//        print("playerItem.duration.value: ", playerItem.duration.value)
//        print("playerItem.duration.value: ", playerItem.duration.timescale)
        
        ///
        let totalTime   = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
        let timeStr = "\(formatPlayTime(secounds: currentTime))/\(formatPlayTime(secounds: totalTime))"
        playerView.timeLabel.text = timeStr
        
        /// スライダー更新
        if !self.playerView.sliding {
            // 播放进度
            self.playerView.slider.value = Float(currentTime/totalTime)
        }
        
        // グラフ更新
        /// 位置の割合を算出する
        let ratio: Double = Double(currentTime) / Double(totalTime)
        self.playerView.updateGraphPose(poseRatio: ratio)
    }
}

// MARK: - 写真アプリからのdelegate
extension ValificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 動画取得delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 各種初期化
        /// Pose
        if AnalysisObj == 1 {
            self.poses1 = [[Pose]()]
        } else {
            self.poses2 = [[Pose]()]
        }
        /// AVPlayer
        
        
        // URL取得
        let mediaURL = info[.mediaURL] as? URL
        videoURL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerReferenceURL")] as? URL
        print("videoURL: ", videoURL!)
        print("mediaURL: ", mediaURL!)
        
        // AVPlayer設定
        self.settingVideoPlayer(url: mediaURL!)
        
        // サムネイル表示
//        previewImageFromVideo(mediaURL!)!
//        playerLayer.image = previewImageFromVideo(videoURL!)!
//        imageView.contentMode = .scaleAspectFit
        
        // 画面更新
        /// 写真アプリの画面消去
        imagePickerController.dismiss(animated: true) {
            // 骨格検出
            do {
                /// 骨格検出処理呼び出し
                try self.callPoseNet(mediaURL: mediaURL)
                
                /// 新規動画作成（呼び出した動画と、骨格検出のデータを合成した動画の作成（メモリ上に））
                
                // 定期的実行（シークバーを更新し続ける？？）
                self.link = CADisplayLink(target: self, selector: #selector(self.update))
                self.link.add( to: RunLoop.main, forMode: RunLoop.Mode.default)
                
            } catch APIError.generateImage(let message){
                // エラー内容表示
                print(message)

                // 各種初期化
                /// AVPlayer
                /// Poseなど
            } catch {
                
            }
        }
    }
    
    // 動画から画像を取り出す（サムネイルの選定）
    private func previewImageFromVideo(_ url:URL) -> UIImage? {

        print("動画からサムネイルを生成する")
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time: CMTime = asset.duration
        
        print("time: ", time)
        print("time value: ", time.value)
        print("time min: ", min(time.value,2))
        
        time.value = min(time.value,2)
        
        print("time: ", time)
        print("time value: ", time.value)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let test: UIImage = UIImage(cgImage: imageRef)
            
            self.imageView.image = test
            
            return test
        } catch {
            return nil
        }
    }
    
    private func settingVideoPlayer(url: URL){
        let asset = AVAsset(url:url)
        playerItem = AVPlayerItem(asset: asset) //誰を再生するか決める

        // FPS算出
        let fps = asset.tracks(withMediaType: AVMediaType.video)[0].nominalFrameRate
        print("fps: ", fps)
        
        // 状態監視
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        
        // AVPlayer・AVPlayerLayerインスタンス生成
        self.avplayer = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: avplayer)
        
        // 表示モードの設定
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        
        // 表示設定
        self.playerView.playerLayer = self.playerLayer
        self.playerView.layer.insertSublayer(playerLayer, at: 0)
    }
}

//MARK: - testdelegate
extension ValificationViewController: TestPlayerViewDelegate {
    // スライダーのタッチリリースdelegate
    func testPlayer(playerView: PlayerView, sliderTouchUpOut slider: UISlider) {
        // スライダーの位置から、移動対象の時間を取得
        let duration = slider.value * Float(CMTimeGetSeconds(self.avplayer.currentItem!.duration))
        let seekTime = CMTimeMake(value: Int64(duration), timescale: 1)
        
        // 位置を指定
        self.avplayer.seek(to: seekTime, completionHandler: { (b) in
            // sliding状態を戻す
            playerView.sliding = false
        })
    }
    
    func testPlayer(playerView: PlayerView, playAndPause playBtn: UIButton) {
        if !playerView.playing{
            self.avplayer.pause()
        }else{
            print("status: ", avplayer.status as Any)
            if self.avplayer.status == AVPlayer.Status.readyToPlay {
                self.avplayer.play()
            }
        }
    }
}

// MARK: - PoseNetからのdelegate
extension ValificationViewController: PoseNetDelegate {
    // playerView(playerView2)への表示する動画の、「一画像」の解析結果のdelegate
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        //print("poseNetにて、delegate実行します")
        // poseBuilder設定
        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: self.tmpCGImage!)
        
        // 1フレームのposeデータ取得
        let poses = poseBuilder.poses
        
        // [pose]生成
        if AnalysisObj == 1 {
            self.poses1?.append(poses)
            //print("poses1: poseデータ追加しました！")
        } else {
            self.poses2?.append(poses)
            //print("poses2: poseデータ追加しました！")
        }
    }
}
