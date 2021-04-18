//
//  PlayerView.swift
//  testCoreML
//
//  Created by 池田和浩 on 2021/04/15.
//

import UIKit
import AVFoundation

protocol TestPlayerViewDelegate: NSObjectProtocol {
    func testPlayer(playerView: PlayerView, sliderTouchUpOut slider: UISlider)
    func testPlayer(playerView: PlayerView, playAndPause playBtn: UIButton)
}

class PlayerView: UIView {
    
    // delegate
    weak var delegate: TestPlayerViewDelegate?
    
    // 変数
    public var sliding: Bool!
    public var playing: Bool!
    
    // 部品
    var playerLayer:AVPlayerLayer?  //player
    public var timeLabel: UILabel!  //label
    weak var slider: UISlider!{     // slider
        // スライダーの値が更新されるたびに、スライダーの画面更新
        didSet{
            slider.setThumbImage(UIImage(systemName: "bolt.fill"), for: UIControl.State.normal)
            slider.frame = CGRect(x: 50, y: bounds.maxY - 30, width: bounds.maxX / 2, height: 30)
            
            // スライダーのタップ、リリース挙動
            slider.addTarget(self, action: #selector(sliderTouchDown), for: UIControl.Event.touchDown)
            slider.addTarget(self, action: #selector(sliderTouchUpOut), for: UIControl.Event.touchUpOutside)
            slider.addTarget(self, action: #selector(sliderTouchUpOut), for: UIControl.Event.touchUpInside)
            slider.addTarget(self, action: #selector(sliderTouchUpOut), for: UIControl.Event.touchCancel)
            
            self.addSubview(slider)
        }
    }
    var playAndPauseBtn: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // プレイヤー領域設定
        let playerRect = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.maxX, height: self.bounds.maxY / 4 * 3)
        playerLayer?.frame = playerRect
        
        // シークラベル
        let labelRect = CGRect(x: bounds.maxX - 120, y: bounds.maxY - 30, width: 120, height: 30)
        self.timeLabel = UILabel(frame: labelRect)
        
        // シークラベルの制御状況
        self.sliding = false
        self.playing = false
        
        // 再生・停止ボタン
        self.playAndPauseBtn = UIButton()
        playAndPauseBtn.frame = CGRect(x: 10, y: bounds.maxY - 30, width: 40, height: 30)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause), for: UIControl.Event.touchUpInside)
        
        self.slider = UISlider()
        
        // 表示
        self.addSubview(timeLabel)
        self.addSubview(playAndPauseBtn)
        
        // 背景色
        self.backgroundColor = .systemGray
    }
    
    // スライダー押下
    @objc func sliderTouchDown(slider:UISlider){
        // 再生進捗管理？
        self.sliding = true
    }
    // スライダーリリース
    @objc func sliderTouchUpOut(slider:UISlider){
        delegate?.testPlayer(playerView: self, sliderTouchUpOut: slider)
    }
    
    @objc func playAndPause(btn: UIButton){
        let tmp = !playing

        playing = tmp

        if playing {
            playAndPauseBtn.setImage(UIImage(systemName: "stop.circle"), for: UIControl.State.normal)
        }else{
            playAndPauseBtn.setImage(UIImage(systemName: "play.circle"), for: UIControl.State.normal)
        }

        delegate?.testPlayer(playerView: self, playAndPause: btn)
    }
}

