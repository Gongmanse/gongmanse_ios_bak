//
//  PIPController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/07.
//

import UIKit
import AVKit

struct PIPVideoData {
    
    var isOnPIP: Bool
    var videoURL: NSURL?
    var currentVideoTime: Float
    var videoTitle: String
    var teacherName: String
}

class PIPController: UIViewController {

    // MARK: - Properties
    
    // Data
    var isOnPIP: Bool = false
    var pipVideoData: PIPVideoData? {
        didSet { setupVideo() }
    }
    
    // AVPlayer
    // AVPlayer
    var asset: AVAsset?
    var player: AVPlayer?
    var playerController = AVPlayerViewController()
    var playItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    var timeObserverToken: Any?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    deinit {
        print("DEBUG: PIP 모드가 종료됩니다.")
    }
    
    // MARK: - Actions
    
    /// 영상 종료 시, 호출될 콜백메소드
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        print("DEBUG: PIP를 종료합니다.")
    }
    
    // MARK: - Heleprs
    
    func setupLayout() {
        
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor,
                             left: view.leftAnchor,
                             bottom: view.bottomAnchor,
                             right: view.rightAnchor)
    }
    
    func setupVideo() {
        
        guard let pipVideoData = self.pipVideoData else { return }
        
        self.asset = AVAsset(url: pipVideoData.videoURL! as URL)
        
        let keys: [String] = ["playable"]
        
        asset?.loadValuesAsynchronously(forKeys: keys, completionHandler: {
            
            var error: NSError? = nil
            guard let asset = self.asset else { return }
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
                case .loaded:
                    DispatchQueue.main.async {
                        let item = AVPlayerItem(asset: asset)
                        self.player = AVPlayer(playerItem: item)
                        let playerLayer = AVPlayerLayer(player: self.player)
                        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                        playerLayer.frame = self.containerView.bounds
                        self.containerView.layer.addSublayer(playerLayer)
                        let seconds: Int64 = Int64(pipVideoData.currentVideoTime)
                        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
                        self.player?.seek(to: targetTime)
                        self.player?.play()
                    }
                    break
                    
            case .failed:
                DispatchQueue.main.async {
                    print("DEBUG: 실패했습니다.")
                }
                break
                
            case .cancelled:
                DispatchQueue.main.async {
                    print("DEBUG: 취소했습니다.")
                }
            default:
                break
            }
        })
    }

    public func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player!.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func dismissVC() {
        dismiss(animated: true)
    }
}
