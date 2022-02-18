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
    lazy var subtitles = Subtitles(subtitles: "")
    private var seekTime: CMTime?
    var timeSlider: CustomSlider = {
        let slider = CustomSlider()
        let image = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        slider.minimumTrackTintColor = .mainOrange
        slider.maximumTrackTintColor = .white
        slider.setThumbImage(image, for: .normal)
        slider.value = 0
        return slider
    }()
    var isSliderMoved = false
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
    let audioToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let muteOn = UIImage(systemName: "speaker.slash")
        button.setImage(muteOn, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(handleAudioMute), for: .touchUpInside)
        return button
    }()
    var subtitleFontSize: CGFloat = 13
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
        
//        let backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.backgroundColor = UIColor.clear
        label.font = UIFont.appBoldFontWith(size: fontSize)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "default setting..."
        label.alpha = UserDefaults.standard.bool(forKey: "subtitle") ? 1 : 0
        return label
    }()
    // 22.02.17 html tag 를 attributed 로 설정할 경우 라벨 내 중앙 정렬 이슈로 뷰 겹쳐서 사용
    let subtitleBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.clipsToBounds = true
        view.layer.cornerRadius = 13
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
        return view
    }()
    let actionBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
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
    var isAudioMute: Bool = true {
        didSet {
            if isAudioMute {
                audioToggleButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
            } else {
                audioToggleButton.setImage(UIImage(systemName: "speaker"), for: .normal)
            }
            avPlayer?.isMuted = isAudioMute
            autoPlayAudioMute = isAudioMute
        }
    }
    
    var delegate: AutoPlayDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            subtitleFontSize = 16
        } else {
            subtitleFontSize = 13
        }
        
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
        
//        avPlayer?.volume = 3
//        avPlayer?.actionAtItemEnd = .none

        avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: videoAreaView.frame.size.width, height: videoAreaView.frame.size.height)
        
        avPlayerLayer?.masksToBounds = true
        avPlayerLayer?.cornerRadius = 13

        videoAreaView.layer.insertSublayer(avPlayerLayer!, at: 0)

        // This notification is fired when the video ends, you can handle it in the method.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
        
        print("videoAreaView.subviews.count : \(videoAreaView.subviews.count)")
        if videoAreaView.subviews.count == 1 {// loading progress
            print("add subViews")
            videoAreaView.addSubview(subtitleBackView)
        
            videoAreaView.addSubview(subtitleLabel)

            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.centerXAnchor.constraint(equalTo: videoAreaView.centerXAnchor).isActive = true
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: videoAreaView.frame.size.width - 20).isActive = true
//            subtitleLabel.leftAnchor.constraint(greaterThanOrEqualTo: videoAreaView.leftAnchor, constant: 10).isActive = true
//            subtitleLabel.rightAnchor.constraint(greaterThanOrEqualTo: videoAreaView.rightAnchor, constant: -10).isActive = true
            subtitleLabel.bottomAnchor.constraint(equalTo: videoAreaView.bottomAnchor, constant: 0).isActive = true
            
            subtitleBackView.anchor(top: subtitleLabel.topAnchor,
                                  left: videoAreaView.leftAnchor,
                                  bottom: subtitleLabel.bottomAnchor,
                                  right: videoAreaView.rightAnchor)
                
            videoAreaView.addSubview(timeSlider)
            timeSlider.anchor(left: videoAreaView.leftAnchor,
                              bottom: subtitleLabel.topAnchor,
                              right: videoAreaView.rightAnchor,
                              paddingLeft: 10,
                              paddingBottom: 0,
                              paddingRight: 10,
                              height: 25)
            
            actionBackView.addSubview(audioToggleButton)
            audioToggleButton.anchor(top: actionBackView.topAnchor,
                                  bottom: actionBackView.bottomAnchor,
                                  right: actionBackView.rightAnchor,
                                  paddingTop: 5,
                                  paddingBottom: 5,
                                  paddingRight: 5)
        
            actionBackView.addSubview(subtitleToggleButton)
            subtitleToggleButton.anchor(top: actionBackView.topAnchor,
                                  left: actionBackView.leftAnchor,
                                  bottom: actionBackView.bottomAnchor,
                                  right: audioToggleButton.leftAnchor,
                                  paddingTop: 5,
                                  paddingLeft: 5,
                                  paddingBottom: 5,
                                  paddingRight: 10)
            
            videoAreaView.addSubview(actionBackView)
            actionBackView.anchor(top: videoAreaView.topAnchor,
                                  right: videoAreaView.rightAnchor,
                                  paddingTop: 5,
                                  paddingRight: 5)
        } else {
            print("show subViews")
        }
        subtitleBackView.isHidden = false
        actionBackView.isHidden = false
        subtitleLabel.isHidden = false
        timeSlider.isHidden = false
        
        isAudioMute = autoPlayAudioMute
    }

    func stopPlayback(isEnded: Bool){
        if videoAreaView.isHidden { return }
        
        if isEnded {
            print("call delegate \(String(describing: delegate))")
            delegate?.playerItemDidReachEnd()
        }
        print("=================stopPlayback=============\(String(describing: videoID))")
        
        // stop video & hide video area
        requestDelayTimer?.invalidate()
        avPlayer?.pause()
        videoPlayerItem = nil
        avPlayer = nil
        timeSlider.value = 0
        subtitleLabel.text = " "
        removePeriodicTimeObserver()
        
        videoAreaView.isHidden = true
        loadingView.isHidden = true
        loadingView.stopAnimating()
        
        subtitleBackView.isHidden = true
        actionBackView.isHidden = true
        subtitleLabel.isHidden = true
        timeSlider.isHidden = true
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
//        print("playerItemDidReachEnd")
        stopPlayback(isEnded: true)
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

                        let subtitleInKor = self.makeStringKoreanEncoded("\(fileBaseURL)/" + response.data.sSubtitle)
                        let subtitleRemoteUrl = URL(string: subtitleInKor)
                        self.open(fileFromRemote: subtitleRemoteUrl!)
                    }
                }
            } else {
                DetailVideoDataManager().DetailVideoDataManager(videoID) { response in
                    print("response : \(response.data)")
                    print("response data : \(response.data.sTitle)")
                    if !self.videoAreaView.isHidden {
                        self.setVideoItem(url: URL(string: response.data.source_url!)!)

                        let subtitleInKor = self.makeStringKoreanEncoded("\(fileBaseURL)/" + response.data.sSubtitle)
                        let subtitleRemoteUrl = URL(string: subtitleInKor)
                        self.open(fileFromRemote: subtitleRemoteUrl!)
                    }
                }
            }
        }
    }
    
    //MARK: - request subtitle info
    func makeStringKoreanEncoded(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
    func open(fileFromRemote filePath: URL,
              encoding: String.Encoding = String.Encoding.utf8)
    {
        subtitleLabel.text = " "
        URLSession.shared.dataTask(with: filePath,
                                   completionHandler: { (data, response, error) -> Void in
                                    
                                       if let httpResponse = response as? HTTPURLResponse {
                                           let statusCode = httpResponse.statusCode
                                           // 정상적으로 네트워킹이 되었는지 확인한다.
                                           if statusCode != 200 {
                                               NSLog("Subtitle Error: \(httpResponse.statusCode) - \(error?.localizedDescription ?? "")")
                                               return
                                           }
                                       }
                                    
                                       // UI를 메인스레드에서 업데이트한다.
                                       DispatchQueue.main.async {
                                           self.subtitleLabel.text = " "
                                           if let checkData = data as Data? {
                                               if let contents = String(data: checkData, encoding: encoding) {
                                                   self.show(subtitles: contents)
                                               }
                                           }
                                       }
                                   }).resume()
    }
    func show(subtitles string: String) {
        subtitles.parsedPayload = Subtitles.parseSubRip(string)
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
        avPlayer?.isMuted = self.isAudioMute
        avPlayer?.play()
        
        if let seekTime = seekTime {
            print("seek to \(seekTime.seconds)")
            avPlayer?.seek(to: seekTime)
        }
    }
    
    //MARK: - 슬라이더를 이동하면 player의 값을 변경해주는 메소드(.valueChaned 시 호출되는 콜백메소드)
    @objc func timeSliderValueChanged(_ slider: UISlider, event: UIEvent) {
        let seconds = Int64(slider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        // slider 이동 중 사라지지 않도록 event 제어, slider 이동 완료된 후 seek 하도록 수정.
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                isSliderMoved = true

            case .ended:
                print("touch ended")
                isSliderMoved = false
                avPlayer?.seek(to: targetTime)
                avPlayer?.isMuted = self.isAudioMute
                
            default:
                print("touch state : \(touchEvent.phase)")
            }
        }
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
    
    //MARK: - 오디오 출력
    @objc func handleAudioMute() {
        isAudioMute.toggle()
    }
    
    func addPeriodicTimeObserver() {
        self.timeObserverToken = avPlayer?.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),// 확인 주기 변경
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                guard let strongSelf = self else { return }
                // 재생 컨트롤러 처리
//                if strongSelf.avPlayer?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
//                    print("readyToPlay")
//                }
                if !strongSelf.isSliderMoved {
                    strongSelf.timeSlider.value = Float(time.seconds)
                }
                
                // 자막처리
                let label = strongSelf.subtitleLabel
                
                // "Subtitles"에서 (자막의 시간만)필터링한 자막값을 옵셔널언랩핑한다.
                if let subtitleText = Subtitles.searchSubtitles(strongSelf.subtitles.parsedPayload, time.seconds) {
//                    print("subtitleText : \(subtitleText)")// html tag 포함.
                    
                    // load HTML String
                    if subtitleText.contains("#") {
//                        print("has hashTag")
                        label.attributedText = subtitleText.htmlAttributedString(font: UIFont.appBoldFontWith(size: strongSelf.subtitleFontSize))
                        
                        // 자막이 필터링된 값 중 "#"가 있는 keyword를 찾아서 텍스트 속성부여 + gesture를 추가기위해 if절 로직을 실행한다.
//                        print("# subtitleFinal : \(subtitleFinal)")
//                        // "#"을 기준으로 자막을 나눈다.
//                        let subtitleArray = subtitleText.split(separator: "#")
//                        print("subtitleArray : \(subtitleArray)")
//
//                        // "#"의 개수를 확인한다.
//                        let hashtagCounter = subtitleFinal.getOnlyText(regex: "#")
//                        print("hashtagCounter : \(hashtagCounter), \(hashtagCounter.count)")
//
//                        // #"의 개수 프로퍼티
//                        let numberOfHasgtags = hashtagCounter.count
//
//                        // 키워드 개수에 맞게 글자 속성 부여 및 클릭 시 호출되도록 설정 메소드
//                        // - "subtitleLabel"의 foregroundColor 변경(default: .orange)
//                        // - "subtitleLabel"의 Font 변경(default: 14)
//                        // - "subtitleLabel" 클릭 시, 클릭한 키워드 판별로직
//                        strongSelf.manageTextInSubtitle(numberOfHasgtags: numberOfHasgtags,
//                                                        subtitleArray: subtitleArray,
//                                                        sTagsArray: strongSelf.sTagsArray,
//                                                        keywordAttriString: keywordAttriString,
//                                                        subtitleFinal: subtitleFinal,
//                                                        label: label)
                    } else  {
                        label.text = subtitleText
                    }
                }
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
