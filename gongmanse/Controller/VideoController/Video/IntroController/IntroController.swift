//
//  IntroController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/01.
//

import UIKit
import AVFoundation

protocol IntroControllerDelegate: AnyObject {
    func playVideoEndedIntro()
}

class IntroController: UIViewController {

    // MARK: - Properties
    
    weak var delegate: IntroControllerDelegate?
    
    // IBOutlet
    @IBOutlet weak var IntroVideoContainerView: UIView!
    
    // Programmatic
    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        setupIntroVideo()
    }
    
    
    // MARK: - Actions
    
    /// 영상 종료 시, 호출될 콜백메소드
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        player?.pause()
        dismiss(animated: false) {
            self.delegate?.playVideoEndedIntro()
        }
    }
    
    // MARK: - Heleprs
    
    func setupIntroVideo() {
        
        let introURL = URL(fileURLWithPath:Bundle.main.path(forResource: "인트로영상01",
                                                            ofType: "mov")!)
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        
        guard let playerLayer = playerLayer else {
            fatalError("레이어 생성에 실패했습니다.")
        }
        playerLayer.frame = IntroVideoContainerView.layer.bounds
        IntroVideoContainerView.layer.addSublayer(playerLayer)
        
        let videoAsset = AVURLAsset(url: introURL)
        
        videoAsset.loadValuesAsynchronously(forKeys: ["", ""]) {
            
            DispatchQueue.main.async {
                let loopItem = AVPlayerItem(asset: videoAsset)
                self.player?.insert(loopItem, after: nil)
                self.player?.play()
            }
        }
        
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(playerItemDidReachEnd),
                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                         object: nil)
    }
}