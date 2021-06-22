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
        
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        super.viewDidLoad()
        setupIntroVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    
    // MARK: - Actions
    
    /// 영상 종료 시, 호출될 콜백메소드
    @objc func introPlayerItemDidReachEnd(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        player?.pause()
        player = nil
        
        playerLayer?.removeFromSuperlayer()
        dismiss(animated: false) {
            self.delegate?.playVideoEndedIntro()
        }
    }
    
    @objc func userTapView() {
        
        presentAlert(message: "로딩중입니다. 잠시만 기다려주세요.")
    }
    
    // MARK: - Heleprs
    
    func setupIntroVideo() {
        
//        IntroVideoContainerView.layer.bounds = CGRect(x: 0,
//                                                      y: 0,
//                                                      width: Constant.width,
//                                                      height: Constant.height * 0.32)
        
        
        
        
        
        
        var introVideoHeight = Constant.width == 375.0 ? view.frame.width * 0.52 : view.frame.width * 0.57
        
        print("DEBUG: Constant.height \(Constant.height)")
        switch Constant.height {
        case 926:
            introVideoHeight = view.frame.width * 0.6
        case 896:
            introVideoHeight = view.frame.width * 0.58
        case 812:
            introVideoHeight = view.frame.width * 0.52
        case 844:
            introVideoHeight = view.frame.width * 0.54
        case 736:
            introVideoHeight = view.frame.width * 0.57
        case 667:
            introVideoHeight = view.frame.width * 0.52
        default:
            introVideoHeight = view.frame.width * 0.55
        }
        
        
        IntroVideoContainerView.centerX(inView: view)
        IntroVideoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                       left: view.leftAnchor,
                                       right: view.rightAnchor,
                                       height: introVideoHeight)
    
        // 414.0 -> promax size
        
        // 375.0 -> se2
        let phoneWidth = Constant.width
        print("DEBUG: phoneWidth \(phoneWidth)")
        
        IntroVideoContainerView.contentMode = .scaleAspectFill
        
        let introURL = URL(fileURLWithPath:Bundle.main.path(forResource: "비율수정인트로영상",
                                                            ofType: "mov")!)
        
        // Random Intro 적용할 때, 사용할 코드
        let introURL02 = URL(fileURLWithPath:Bundle.main.path(forResource: "비율수정인트로영상",
                                                            ofType: "mov")!)
        let introArr = [introURL, introURL02]
        let resultIntro = introArr.randomElement()
        
    
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        
        guard let playerLayer = playerLayer else {
            fatalError("레이어 생성에 실패했습니다.")
        }
        playerLayer.frame = IntroVideoContainerView.layer.bounds
        IntroVideoContainerView.layer.addSublayer(playerLayer)
        IntroVideoContainerView.clipsToBounds = true
        
        let videoAsset = AVURLAsset(url: introURL)
//        let videoAsset = AVURLAsset(url: resultIntro)
        
        videoAsset.loadValuesAsynchronously(forKeys: ["", ""]) {
            
            DispatchQueue.main.async {
                let loopItem = AVPlayerItem(asset: videoAsset)
                self.player?.insert(loopItem, after: nil)
                self.player?.play()
            }
        }
        
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(introPlayerItemDidReachEnd),
                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                         object: nil)
        
        // 인트로 도중 클릭 시, alert을 호출한다.
        // 이를 위해 UITapGesutre를 추가한다.
        let viewTapGesutre = UITapGestureRecognizer(target: self, action: #selector(userTapView))
        view.addGestureRecognizer(viewTapGesutre)
        
    }
}

