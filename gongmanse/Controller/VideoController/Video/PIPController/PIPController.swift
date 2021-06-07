//
//  PIPController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/07.
//

import UIKit
import AVKit

class PIPController: UIViewController {

    // MARK: - Properties
    // AVPlayer
    // AVPlayer
    var asset: AVAsset?
    var player: AVPlayer?
    var playerController = AVPlayerViewController()
    var playItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
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
        
        self.asset = AVAsset(url: URL(string: "https://file.gongmanse.com/access/lectures/video?access_key=ZGRkZTU5OGRlMDAxNTY2ZTk3MDM2OTU4OGY5NDBlZTU4ZmUyMzg2NDRkZWEyMGQ5ZjI1YmE3NmI3NGFjMzkxYWQ5ZDcxMzRlMzNmMWE2NzBmYTBlZDQyNzgyNjdlNmIzNmRhMjcwY2MzYTZkNWRjZjBmOTY3NDMwZGNjNTJmYTJPN3U4ZWpucEhYNzkvNFJpUUo5Y1FPb21BSlBJaDdUbDBtQjBTVU9MN01ZQjc1dHN1R2ltVG9LeFlsV29FRFoxQW1oSmYxOHNEVkI2eUltalQ1OUhkRVlGakhJb0Z6OFQvQWRHeHV5S0YwYnFFRmc0dlpOckpXRlNHNDlqaWUrSmltWFZOWCtJZTRFbHducVRPdFBXU2g3dytCMjJUVEpmS21FeWVZUjNmZzc1bm1HdzVIT0szb0p3S01RYmY0WXAzVjk3S3gvTnBGeXZpckRnV0VGaDhiVWJoWVVRc0xxTjhyNGNGSG1xUzhIOFRBbitObmxnSlNOR2cvdUZvZXQzSHJDQTR4YTd4akRwTTVZbWY3SDNUQXpxQzJHTmpYRlFYb01pWWVVcmxsNWs1QzlIYVRrWXNYQ1NTZXlBSmlkK3dtVEYyNWVOL2RQbnlWbnowMFdrc0ZWT21xNm1PMWpmektQWi9pWmU3RDg9")!)
        
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


}
