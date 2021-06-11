//
//  PIPController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/07.
//

import UIKit
import AVKit

struct PIPVideoData {
    
    var isPlayPIP: Bool = false
    var videoURL: NSURL?
    var currentVideoTime: Float = 0.0
    var videoTitle: String = ""
    var teacherName: String = ""
}

class PIPController: UIViewController {

    // MARK: - Properties
    
    // Data
    var isOnPIP: Bool = false
    var pipVideoData: PIPVideoData? {
        didSet { setupVideo() }
    }
    
    // PIP 현재 재생시간을 CMTime으로 전달받기 위한 연산 프로퍼티
    // "영상 > sTags클릭 > 검색화면 > PIP재생 > 다시 이전영상" 에서 dismiss 시, 활용하고 있다.
    var currentVideoTime: CMTime {
        guard let player = self.player else { return CMTime() }
        return player.currentTime()
    }
    
    /**
     [didSet 로직]
     true : 영상 > 검색 > 영상 : PIP 영상을 실행하지 않는다.
     false: 영상 > 검색       : PIP 영상을 실행한다.
     */
    var isPlayPIP: Bool = true
    
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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(isPlayPIP: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.isPlayPIP = isPlayPIP
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        let pipDataManager = PIPDataManager.shared
        
        
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
                        
                        if let pipVideoData = self.pipVideoData {
                            if pipVideoData.isPlayPIP {
                                self.player?.play()
                            } else {
                                self.player?.pause()
                            }
                        }
                        
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

