//
//  OutroVideoController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/03.
//

import AVFoundation
import UIKit

protocol OuttroVideoControllerDelegate: AnyObject {
    func playVideoEndedOuttro()
}


class OutroVideoController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: OuttroVideoControllerDelegate?
    
    @IBOutlet weak var outtroVideoContainerView: UIView!
    
    // Programmatic
    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupLayout()
    }
    
    
    // MARK: - Actions
    
    /// 영상 종료 시, 호출될 콜백메소드
    @objc func outtroVideoDidReachEnd(notification: NSNotification) {
        player?.pause()
        dismiss(animated: false) {
            self.delegate?.playVideoEndedOuttro()
        }
    }
    
    // MARK: - Heleprs
    
    func setupLayout() {
        let outttroURL
            = URL(fileURLWithPath:Bundle.main.path(forResource: "아웃트로01",
                                                   ofType: "mov")!)
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        
        guard let playerLayer = playerLayer else {
            fatalError("레이어 생성에 실패했습니다.")
        }
        playerLayer.frame = outtroVideoContainerView.layer.bounds
        outtroVideoContainerView.layer.addSublayer(playerLayer)
        
        let videoAsset = AVURLAsset(url: outttroURL)
        
        videoAsset.loadValuesAsynchronously(forKeys: ["", ""]) {
            
            DispatchQueue.main.async {
                let loopItem = AVPlayerItem(asset: videoAsset)
                self.player?.insert(loopItem, after: nil)
                self.player?.play()
            }
        }
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(outtroVideoDidReachEnd),
                         name: NSNotification.Name.outtroVideoDidReachEnd,
                         object: nil)
    }
    
}




