import UIKit
import AVFoundation

class RecommendCVCell: UICollectionViewCell {
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var teachersName: UILabel!
    @IBOutlet weak var subjects: UILabel!
    @IBOutlet weak var term: UILabel!
    @IBOutlet weak var starRating: UILabel!
    
    @IBOutlet weak var videoAreaView: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    var requestDelayTimer: Timer? //동영상 정보 요청 딜레이 체크
    var videoID: String!
    
    //MARK: - video controller & subtitle
    private var seekTime: CMTime?
    var timeSlider: CustomSlider = {
        let slider = CustomSlider()
        let image = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        slider.minimumTrackTintColor = .mainOrange
        slider.maximumTrackTintColor = .white
        slider.setThumbImage(image, for: .normal)
        slider.value = 1
        return slider
    }()
    var timeObserverToken: Any?
    let subtitleToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "smallCaptionOn")
        button.setImage(image, for: .normal)
        button.tintColor = .mainOrange
        button.addTarget(self, action: #selector(handleSubtitleToggle), for: .touchUpInside)
        button.setImage(UIImage(named: UserDefaults.standard.bool(forKey: "subtitle") ? "smallCaptionOn" : "자막토글버튼_제거"), for: .normal)
        return button
    }()
    var subtitleLabel: UILabel = {
        let fontSize: CGFloat!
        if UIDevice.current.userInterfaceIdiom == .pad {
            fontSize = 16
        } else {
            fontSize = 13
        }
        let label = PaddingLabel()
        label.topInset = 5.0
        label.bottomInset = 5.0
        
        let backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.backgroundColor = backgroundColor
        label.font = UIFont.appBoldFontWith(size: fontSize)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "default setting..."
        label.alpha = UserDefaults.standard.bool(forKey: "subtitle") ? 1 : 0
        return label
    }()
    var isClickedSubtitleToggleButton: Bool = true {
        didSet {
            if self.isClickedSubtitleToggleButton {
                self.subtitleLabel.alpha = 1
                self.subtitleToggleButton.setImage(UIImage(named: "smallCaptionOn"), for: .normal)
            } else {
                self.subtitleLabel.alpha = 0
                self.subtitleToggleButton.setImage(UIImage(named: "자막토글버튼_제거"), for: .normal)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //비디오 썸네일 이미지 라운딩 처리
        videoThumbnail.layer.cornerRadius = 13
        videoAreaView.layer.cornerRadius = 13
        
        //과목 label background 라운딩 처리
        subjects.layer.cornerRadius = 7
        subjects.clipsToBounds = true
        
        //용어 label background 라운딩 처리
        term.layer.cornerRadius = 7
        term.clipsToBounds = true
    }
    
    // MARK: - video player setting
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        requestDelayTimer?.invalidate()
    }
    
    func setupMoviePlayer() {
        avPlayer = AVPlayer.init(playerItem: videoPlayerItem)
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        
        avPlayer?.volume = 3
        avPlayer?.actionAtItemEnd = .none
//        avPlayer?.layer.masksToBounds = true
//        avPlayer?.layer.cornerRadius = 13

        avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: videoAreaView.frame.size.width, height: videoAreaView.frame.size.height)
        
        avPlayerLayer?.masksToBounds = true
        avPlayerLayer?.cornerRadius = 13

        videoAreaView.layer.insertSublayer(avPlayerLayer!, at: 0)

        // This notification is fired when the video ends, you can handle it in the method.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
        
        videoAreaView.addSubview(subtitleLabel)
        subtitleLabel.anchor(left: videoAreaView.leftAnchor,
                             bottom: videoAreaView.bottomAnchor,
                             right: videoAreaView.rightAnchor,
                             paddingLeft: 13,
                             paddingBottom: 0,
                             paddingRight: 13)
        
        videoAreaView.addSubview(timeSlider)
        timeSlider.anchor(left: videoAreaView.leftAnchor,
                          bottom: subtitleLabel.topAnchor,
                          right: videoAreaView.rightAnchor,
                          paddingLeft: 10,
                          paddingBottom: 0,
                          paddingRight: 10,
                          height: 25)
        
        videoAreaView.addSubview(subtitleToggleButton)
        subtitleToggleButton.anchor(top: videoAreaView.topAnchor,
                                    right: videoAreaView.rightAnchor,
                                    paddingTop: 10,
                                    paddingRight: 10)
    }

    func stopPlayback(){
        if videoAreaView.isHidden { return }
        
        print("=================stopPlayback=============\(String(describing: videoID))")
        
        // stop video & hide video area
        requestDelayTimer?.invalidate()
        avPlayer?.pause()
        videoPlayerItem = nil
        avPlayer = nil
        avPlayerLayer?.removeFromSuperlayer()
        timeSlider.removeFromSuperview()
        subtitleToggleButton.removeFromSuperview()
        removePeriodicTimeObserver()
        
        videoAreaView.isHidden = true
        loadingView.isHidden = true
        loadingView.stopAnimating()
    }
    
    func startPlayback(_ seekTime: CMTime?){
        if !videoAreaView.isHidden { return }
        
        print("=================startPlayback=============\(String(describing: videoID))")
        // show progress & request video url
        self.seekTime = seekTime
        
        videoAreaView.isHidden = false
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
//        }
        
        requestDelayTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.waitDelay), userInfo: nil, repeats: false)
    }

    @objc func waitDelay() {
        requestVideoUrl()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        print("playerItemDidReachEnd")
//        let p: AVPlayerItem = notification.object as! AVPlayerItem
//        p.seek(to: CMTime.zero)
        stopPlayback()
    }
    
    //MARK: -  request video info
    func requestVideoUrl() {
        guard let _ = videoID else { return }
        
        if Reachability.isConnectedToNetwork() {
            if Constant.isGuestKey || Constant.remainPremiumDateInt == nil {
                GuestKeyDataManager().GuestKeyAPIGetData(videoID) { response in
                    print("response : \(response.data)")
                    print("response data : \(response.data.sTitle)")
                    if !self.videoAreaView.isHidden {
                        self.setVideoItem(url: URL(string: response.data.source_url)!)
                    }
                }
            } else {
                DetailVideoDataManager().DetailVideoDataManager(videoID) { response in
                    print("response : \(response.data)")
                    print("response data : \(response.data.sTitle)")
                    if !self.videoAreaView.isHidden {
                        
                        self.setVideoItem(url: URL(string: response.data.source_url!)!)
                    }
                }
            }
        }
    }
    
    func setVideoItem(url: URL) {
        print("setVideoItem")
        loadingView.isHidden = true
        loadingView.stopAnimating()
        
        setupMoviePlayer()
        
        videoPlayerItem = AVPlayerItem(url: url)
        var duration = CMTime()
        if let playerItem = videoPlayerItem {
            duration = playerItem.asset.duration
        }
        let endSeconds: Float64 = CMTimeGetSeconds(duration)
        timeSlider.maximumValue = Float(endSeconds)
        timeSlider.minimumValue = 0
        timeSlider.isContinuous = true
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged),
                             for: .valueChanged)
        addPeriodicTimeObserver()
        
        avPlayer?.play()
        
        if let seekTime = seekTime {
            print("seek to \(seekTime.seconds)")
            avPlayer?.seek(to: seekTime)
        }
    }
    
    //MARK: - 슬라이더를 이동하면 player의 값을 변경해주는 메소드(.valueChaned 시 호출되는 콜백메소드)
    @objc func timeSliderValueChanged(_ slider: UISlider) {
        let seconds = Int64(slider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        avPlayer?.seek(to: targetTime)
    }
    
    //MARK: - 자막표시여부 버튼을 클릭하면 호출하는 콜백메소드
    @objc func handleSubtitleToggle() {
        if subtitleLabel.alpha == 0 {
            isClickedSubtitleToggleButton = true
            UIView.animate(withDuration: 0.22) {
                self.subtitleLabel.alpha = 1
                self.subtitleToggleButton.tintColor = .mainOrange
                self.subtitleToggleButton.setImage(UIImage(named: "smallCaptionOn"), for: .normal)
            }
            
        } else {
            isClickedSubtitleToggleButton = false
            UIView.animate(withDuration: 0.22) {
                self.subtitleLabel.alpha = 0
                self.subtitleToggleButton.setImage(UIImage(named: "자막토글버튼_제거"), for: .normal)
            }
        }
    }
    
    func addPeriodicTimeObserver() {
        self.timeObserverToken = avPlayer?.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),// 확인 주기 변경
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                guard let strongSelf = self else { return }
                
                if strongSelf.avPlayer?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                    print("readyToPlay")
                }
                strongSelf.timeSlider.value = Float(time.seconds)
                strongSelf.subtitleLabel.text = "current time : \(Float(time.seconds))"
            }
        )
    }
            
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            avPlayer?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}
