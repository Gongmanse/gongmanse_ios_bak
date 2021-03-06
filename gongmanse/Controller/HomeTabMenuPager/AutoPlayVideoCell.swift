//
//  AutoPlayVideoCell.swift
//  gongmanse
//
//  Created by 조철희 on 2022/02/23.
//

import Foundation
import AVFoundation
import UIKit

class AutoPlayVideoCell: UICollectionViewCell {
    var requestDelayTimer: Timer? //동영상 정보 요청 딜레이 체크
    var videoID: String!
    var delegate: AutoPlayDelegate?
    var videoAreaView: UIView = UIView()
    
    override func awakeFromNib() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            subtitleFontSize = 16
        } else {
            subtitleFontSize = 11
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        requestDelayTimer?.invalidate()
    }
    
    //MARK: - video controller & subtitle view
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
    var subtitleFontSize: CGFloat = 11
    var subtitleLabel: UILabel = {
        let fontSize: CGFloat!
        if UIDevice.current.userInterfaceIdiom == .pad {
            fontSize = 16
        } else {
            fontSize = 11
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
        label.text = " "
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

    // MARK: - video player setting
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    func setupMoviePlayer() {
        avPlayer = AVPlayer.init(playerItem: videoPlayerItem)
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect

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
        if videoAreaView.subviews.count == 0 {// loading progress 있을경우 1
            print("add subViews")
            videoAreaView.addSubview(subtitleBackView)
        
            videoAreaView.addSubview(subtitleLabel)

            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.centerXAnchor.constraint(equalTo: videoAreaView.centerXAnchor).isActive = true
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: videoAreaView.frame.size.width - 20).isActive = true
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
        
        subtitleBackView.isHidden = true
        actionBackView.isHidden = true
        subtitleLabel.isHidden = true
        timeSlider.isHidden = true
    }
    
    
    func startPlayback(_ seekTime: CMTime?){
        if !videoAreaView.isHidden { return }
        
        print("=================startPlayback=============\(String(describing: videoID))")
        
        // request video url
        self.seekTime = seekTime
        
        videoAreaView.isHidden = false
        
        // locked when user controll finish.
        requestDelayTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.waitDelay), userInfo: nil, repeats: false)
    }
    
    func startNow(_ seekTime: CMTime?){
        if !videoAreaView.isHidden { return }
        
        print("=================startNow=============\(String(describing: videoID))")
        
        // request video url
        self.seekTime = seekTime
        videoAreaView.isHidden = false
        requestVideoUrl()
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
//                    print("response : \(response.data)")
//                    print("response data : \(response.data.sTitle)")
                    if !self.videoAreaView.isHidden {
                        self.setVideoItem(url: URL(string: response.data.source_url)!)

                        let subtitleInKor = self.makeStringKoreanEncoded("\(fileBaseURL)/" + response.data.sSubtitle)
                        let subtitleRemoteUrl = URL(string: subtitleInKor)
                        self.open(fileFromRemote: subtitleRemoteUrl!)
                    }
                }
            } else {
                DetailVideoDataManager().DetailVideoDataManager(videoID) { response in
//                    print("response : \(response.data)")
//                    print("response data : \(response.data.sTitle)")
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
        
        setupMoviePlayer()
        
        videoPlayerItem = AVPlayerItem(url: url)
        setDuration = false
//        var duration = CMTime()
//        if let playerItem = videoPlayerItem {
//            duration = playerItem.asset.duration
//        }
//        let endSeconds: Float64 = CMTimeGetSeconds(duration)
        timeSlider.maximumValue = 180//Float(endSeconds)
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
                
            case .moved:
                print("touch moved")
                
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
    
    private var setDuration = false
    func addPeriodicTimeObserver() {
        self.timeObserverToken = avPlayer?.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 60),// 자막 갱신 확인 주기
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                guard let strongSelf = self else { return }

                if !strongSelf.isSliderMoved {
                    strongSelf.timeSlider.value = Float(time.seconds)
                }
                
                // 자막처리
                let label = strongSelf.subtitleLabel
                
                // "Subtitles"에서 (자막의 시간만)필터링한 자막값을 옵셔널언랩핑한다.
                // 22.03.02 하이라이트 데이터 설정 오류로 일단 효과 제거 후 자막사용
                if let subtitleText = Subtitles.searchSubtitles(strongSelf.subtitles.parsedPayload, time.seconds)?.replacingOccurrences(of: "ffff00", with: "ffffff") {
                    
                    if !strongSelf.setDuration {
                        print("strongSelf.setDuration")
                        strongSelf.setDuration = true
                        var duration = CMTime()
                        if let playerItem = strongSelf.videoPlayerItem {
                            duration = playerItem.asset.duration
                        }
                        let endSeconds: Float64 = CMTimeGetSeconds(duration)
                        strongSelf.timeSlider.maximumValue = Float(endSeconds)
                    }
                    
                    // load HTML String
                    if subtitleText.contains("#") {
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
