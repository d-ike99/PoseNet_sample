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
    var backgroundView: UIView!
    var backgroundGraphView: UIView!
    var playerLayer:AVPlayerLayer?  //player
    public var timeLabel: UILabel!  //label
    var sliderFlg: Bool! = false
    var slider: UISlider! {     // slider
        // スライダーの値が更新されるたびに、スライダーの画面更新
        didSet{
            slider.setThumbImage(UIImage(systemName: "bolt.fill"), for: UIControl.State.normal)
        }
        
    }
    var playAndPauseBtn: UIButton!
    var poseGraph: GraphView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUpView()
        self.setUpGraph()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 画面部品設定
        /// プレイヤー領域設定
        let playerRect = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.maxX, height: self.bounds.maxY / 4 * 2)
        playerLayer?.frame = playerRect
    }
    
    public func setUpView(){
        /// background
        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.maxX, height: self.bounds.maxY))
        self.backgroundView.backgroundColor = .clear
        
        /// シークラベル
        let labelRect = CGRect(x: bounds.maxX - 120, y: bounds.maxY - 30, width: 120, height: 30)
        self.timeLabel = UILabel(frame: labelRect)
        timeLabel.textAlignment = .right
        
        /// シークラベルの制御状況
        self.sliding = false
        self.playing = false
        
        /// 再生・停止ボタン
        self.playAndPauseBtn = UIButton()
        playAndPauseBtn.frame = CGRect(x: 10, y: bounds.maxY - 30, width: 40, height: 30)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause), for: UIControl.Event.touchUpInside)
        playAndPauseBtn.setImage(UIImage(systemName: "play.circle"), for: UIControl.State.normal)
        
        /// slider
        self.slider = UISlider()
        slider.frame = CGRect(x: 50, y: bounds.maxY - 30, width: bounds.maxX / 2, height: 30)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: UIControl.Event.touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUpOut), for: UIControl.Event.touchUpOutside)
        slider.addTarget(self, action: #selector(sliderTouchUpOut), for: UIControl.Event.touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUpOut), for: UIControl.Event.touchCancel)
        
        /// 表示
        self.backgroundView.addSubview(slider)
        self.backgroundView.addSubview(timeLabel)
        self.backgroundView.addSubview(playAndPauseBtn)
        self.addSubview(backgroundView)
        
        /// 背景色
        self.backgroundColor = .systemGray
    }
    
    public func setUpGraph(){
        /// 表示領域
        let viewRect = CGRect(x: self.bounds.minX, y: self.bounds.maxY / 2, width: self.bounds.maxX, height: self.bounds.maxY / 3)
        let graphRect = CGRect(x: self.bounds.minX, y: 0, width: self.bounds.maxX, height: self.frame.height / 3)
        
        /// background
        self.backgroundGraphView = UIView(frame: viewRect)
        self.backgroundGraphView.backgroundColor = .clear
        
        /// グラフ
        poseGraph = GraphView(frame: graphRect)
        
        /// 表示
        self.backgroundGraphView.addSubview(poseGraph)
        self.addSubview(backgroundGraphView)
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

/// MARK: - Update Display
extension PlayerView {
    public func resetView(resetGraph: Bool){
        /// 部品リセット・セットアップ
        self.backgroundView.removeFromSuperview()
        self.setUpView()

        /// 部品リセット・セットアップ（graph）
        if resetGraph {
            self.backgroundGraphView.removeFromSuperview()
            self.setUpGraph()
        }
        
        /// 画面更新
        self.setNeedsDisplay()
    }
    
    
    /// <#Description#>
    public func updateGraphData(poseData: [[Pose]]){
        for one_pose in poseData {
            poseGraph.didUpdatedChartView(poses: one_pose)
        }
    }
    
    public func updateGraphPose(poseRatio: Double){
        self.poseGraph.updateDispPos(poseRatio: poseRatio)
    }
}
