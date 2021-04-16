//
//  ValificationViewController.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/14.
//

import UIKit
import AVKit

class ValificationViewController: UIViewController {

    // 部品
    var imagePickerController: UIImagePickerController!
    var videoURL: URL?
    
    // 動画表示関連の部品
    var playerItem: AVPlayerItem!
    var avplayer: AVPlayer!
    var playerLayer: AVPlayerLayer!

    // 表示部品
    var playerView: PlayerView!
    var link: CADisplayLink!
    
    override func viewDidLoad() {
        
        // navigation barの非表示設定
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 写真へアプリのアクセス
        self.imagePickerController = UIImagePickerController()
        
        // 部品
        let testButton: UIButton = UIButton()
        testButton.frame = CGRect(x: 10, y: 50, width: 60, height: 30)
        testButton.setTitle("動画読込", for: .normal)
        testButton.setTitleColor(.red, for: .normal)
        testButton.addTarget(self, action: #selector(accessPicApp), for: UIControl.Event.touchUpInside)
        
        let playButton: UIButton = UIButton()
        playButton.frame = CGRect(x: 10, y: 100, width: 60, height: 30)
        playButton.setTitle("再生", for: .normal)
        playButton.setTitleColor(.red, for: .normal)
        
        // 動画表示1
        let playerFrame = CGRect(x: self.view.frame.width / 4, y: 30, width: self.view.frame.width / 4 * 3, height: self.view.frame.height / 3)
        self.playerView = PlayerView(frame: playerFrame)
        playerView.backgroundColor = .systemGray
        playerView.delegate = self
        
        self.view.backgroundColor = .systemGray5
        self.view.addSubview(testButton)
        self.view.addSubview(playButton)
        self.view.addSubview(playerView)
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
                    self.avplayer.play()
                }else{
                    print("error")
                }
            }
    }
    
    // 日付ボタン押下処理
    @objc func accessPicApp(_ sender: UIButton){
        print("UIBarButtonItem。カメラロールから動画を選択")
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        //動画だけ
        imagePickerController.mediaTypes = ["public.movie"]
        //画像だけ
        //imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // シークバー関連の更新
    @objc func update(){
        // 動画の再生位置に従い、シークバーを更新する
        let currentTime = CMTimeGetSeconds(self.avplayer.currentTime())
        
//        print("playerItem.duration.value: ", playerItem.duration.value)
//        print("playerItem.duration.value: ", playerItem.duration.timescale)
        
        let totalTime   = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
        let timeStr = "\(formatPlayTime(secounds: currentTime))/\(formatPlayTime(secounds: totalTime))"
        playerView.timeLabel.text = timeStr
        
        // スライダー更新
        if !self.playerView.sliding {
            // 播放进度
            self.playerView.slider.value = Float(currentTime/totalTime)
        }
    }
}

// 写真アプリからのdelegate
extension ValificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // URL取得
        let mediaURL = info[.mediaURL] as? URL
        videoURL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerReferenceURL")] as? URL
        print("videoURL: ", videoURL!)
        print("mediaURL: ", mediaURL)
        
        // player設定
        self.settingVideoPlayer(url: mediaURL!)
        
        // サムネイル表示
//        playerLayer.image = previewImageFromVideo(videoURL!)!
//        imageView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    // 動画から画像を取り出す（サムネイルの選定）
    private func previewImageFromVideo(_ url:URL) -> UIImage? {

        print("動画からサムネイルを生成する")
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value,2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let test: UIImage = UIImage(cgImage: imageRef)
            return test
        } catch {
            return nil
        }
    }
    
    private func settingVideoPlayer(url: URL){
        let asset = AVAsset(url:url)
        playerItem = AVPlayerItem(asset: asset) //誰を再生するか決める

        var time = asset.duration
        print("time: ", time)
        
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
        
        // 定期的実行（シークバーを更新し続ける？？）
        self.link = CADisplayLink(target: self, selector: #selector(update))
        self.link.add( to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
}

extension ValificationViewController {
    private func formatPlayTime(secounds:TimeInterval)->String{
        if secounds.isNaN{
            return "00:00"
        }
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
}


extension ValificationViewController: TestPlayerViewDelegate {
    // スライダーのタッチリリースdelegate
    func testPlayer(playerView: PlayerView, sliderTouchUpOut slider: UISlider) {
        let duration = slider.value * Float(CMTimeGetSeconds(self.avplayer.currentItem!.duration))
        let seekTime = CMTimeMake(value: Int64(duration), timescale: 1)
        // 位置を特定
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
