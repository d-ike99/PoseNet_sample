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
    
    var imageView: UIImageView!
    
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
        playButton.addTarget(self, action: #selector(playMovie), for: UIControl.Event.touchUpInside)

        
        // 動画表示1
        self.imageView = UIImageView()
        imageView.frame = CGRect(x: self.view.frame.width / 4, y: 30, width: self.view.frame.width / 4 * 3, height: self.view.frame.height / 3)
        imageView.backgroundColor = .systemGray
        
        self.view.backgroundColor = .systemGray5
        self.view.addSubview(testButton)
        self.view.addSubview(playButton)
        self.view.addSubview(imageView)
    }
    
    // 日付ボタン押下処理
    @objc func accessPicApp(_ sender: UIButton){
        print("UIBarButtonItem。カメラロールから動画を選択")
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        //imagePickerController.mediaTypes = ["public.image", "public.movie"]
        //動画だけ
        imagePickerController.mediaTypes = ["public.movie"]
        //画像だけ
        //imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func playMovie(_ sender: UIButton) {
        
        print("videoURL: ", videoURL as? Any)
        
        if let videoURL = videoURL{
            let playerItem = AVPlayerItem(url: videoURL)
            
            let player = AVPlayer(playerItem: playerItem)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true){
                print("動画再生")
                playerViewController.player!.play()
            }
        }
    }
}

extension ValificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        videoURL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerReferenceURL")] as? URL
        
        
        print("videoURL: ", videoURL!)
        
        // サムネイル表示
        //imageView.image = previewImageFromVideo(videoURL!)!
        imageView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    // 動画から画像を取り出す（サムネイルの選定）
    private func previewImageFromVideo(_ url:URL) -> UIImage? {

        print("動画からサムネイルを生成する")
        let asset = AVAsset(url:url)
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
}
