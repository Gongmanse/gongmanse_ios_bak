import AVKit

// MARK: - Video Method

extension VideoController {
    /// 자막표시여부 버튼을 클릭하면 호출하는 콜백메소드
    @objc func handleSubtitleToggle() {
        if self.subtitleLabel.alpha == 0 {
            self.isClickedSubtitleToggleButton = true
            UIView.animate(withDuration: 0.22) {
                self.subtitleLabel.alpha = 1
                self.subtitleToggleButton.tintColor = .mainOrange
                self.subtitleToggleButton.setImage(UIImage(named: "smallCaptionOn"), for: .normal)
            }
            
        } else {
            self.isClickedSubtitleToggleButton = false
            UIView.animate(withDuration: 0.22) {
                self.subtitleLabel.alpha = 0
                self.subtitleToggleButton.setImage(UIImage(named: "자막토글버튼_제거"), for: .normal)
            }
            
        }
    }
    
    /// 클릭 시, 설정 BottomPopupController 호출하는 메소드
    @objc func handleSettingButton() {
        let vc = VideoSettingPopupController()
        vc.currentStateIsVideoPlayRate = currentVideoPlayRate == 1 ? "기본" : "\(currentVideoPlayRate)배"
        print("DEBUG: VideoController에서 보내준 값 \(isClickedSubtitleToggleButton)")
        vc.currentStateSubtitle = isClickedSubtitleToggleButton
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    /// Notificaion에 의해 호촐되는 영상속도 콜백메소드
    @objc func changeValueToPlayer(_ sender: Notification) {
        if let data = sender.userInfo {
            if let playrate = data["playRate"] {
                let rate = playrate as? Float ?? Float(1.0)
                currentVideoPlayRate = rate
                player.playImmediately(atRate: rate)
            }
        }
    }
    
    /// Notificaion에 의해 호촐되는 자막표시여부 콜백메소드
    @objc func switchIsOnSubtitle(_ sender: Notification) {
        if let data = sender.userInfo {
            if let condition = data["isOnSubtitle"] {
                
                UIView.animate(withDuration: 0.22) {
                    if condition as? Bool ?? true {
                        self.subtitleLabel.alpha = 1
                        self.isClickedSubtitleToggleButton = true

                    } else {
                        self.subtitleLabel.alpha = 0
                        self.isClickedSubtitleToggleButton = false

                    }
                }
            }
        }
    }
    
    /// 우측상단에 뒤로가기 버튼 로직
    @objc func handleBackButtonAction() {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        player.pause()
        NotificationCenter.default.removeObserver(self)
        removePeriodicTimeObserver()
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 슬라이더를 이동하면 player의 값을 변경해주는 메소드(.valueChaned 시 호출되는 콜백메소드)
    @objc func timeSliderValueChanged(_ slider: UISlider) {
        let seconds: Int64 = Int64(slider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
        
        if player.rate == 0 {
            player.play()
        }
    }
    
    /// 플레이어 재생 및 일시정지 액션을 담당하는 콜백메소드
    @objc func playPausePlayer() {
        let playImage = UIImage(named: "영상재생버튼")
        let pauseImage = UIImage(named: "영상일시정지버튼")
        
        /// 연산프로퍼티 "isPlaying" 에 따라서 플레이어를 정지 혹은 재생시킨다.
        if isPlaying {
            playPauseButton.setBackgroundImage(pauseImage, for: .normal)
            player.pause()
            
        } else {
            playPauseButton.setBackgroundImage(playImage, for: .normal)
            player.play()
        }
    }
    
    /// 동영상 앞으로 가기 기능을 담당하는 콜백 메소드
    @objc func moveForwardPlayer() {
        /// 10초를 계산하기 위한 프로퍼티
        let seconds = Double(230) / Double(23.98)
        
        /// 23 프레임을 기준으로 10초를 입력한 CMTime 프로퍼티
        let oneFrame = CMTime(seconds: seconds, preferredTimescale: 600)
        
        /// CMTimeAdd를 적용한 프로퍼티
        let addTime = CMTimeAdd(player.currentTime(), oneFrame)
        player.seek(to: addTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// 동영상 뒤로 가기 기능을 담당하는 콜백 메소드
    @objc func moveBackwardPlayer() {
        let seconds = Double(230) / Double(23.98)
        let oneFrame = CMTime(seconds: seconds, preferredTimescale: 60)
        let subTractTime = CMTimeSubtract(player.currentTime(), oneFrame)
        player.seek(to: subTractTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// 영상 종료 시, 호출될 콜백메소드
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        player.seek(to: CMTime.zero)
        player.pause()
    }
}


extension VideoController: AVPlayerViewControllerDelegate {
    
    func open(fileFromLocal filePath: URL,
              encoding: String.Encoding = String.Encoding.utf8) {
        let contents = try! String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
    }
    
    func open(fileFromRemote filePath: URL,
              encoding: String.Encoding = String.Encoding.utf8) {
        subtitleLabel.text = "..."
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
                                    DispatchQueue.main.async(execute: {
                                        self.subtitleLabel.text = ""
                                        if let checkData = data as Data? {
                                            if let contents = String(data: checkData, encoding: encoding) {
                                                self.show(subtitles: contents)
                                            }
                                        }
                                    })
                                   }).resume()
    }
    
    func show(subtitles string: String) {
        // subtitle에 파싱한 값을 넣는다.
        subtitles.parsedPayload = Subtitles.parseSubRip(string)
        addPeriodicNotification(parsedPayload: (subtitles.parsedPayload!))
    }
    
    func showByDictionary(dictionaryContent: NSMutableDictionary) {
        // 파싱한 데이터가 Dictionary이고 해당 값을 넣는다.
        subtitles.parsedPayload = dictionaryContent
        addPeriodicNotification(parsedPayload: (subtitles.parsedPayload!))
    }
    
    /* keyword 텍스트에 적절한 변화를 주고, 클릭 시 action이 호출될 수 있도록 관리하는 메소드 */
    /// "Player"가 호출된 후, 일정시간마다 호출되는 메소드
    func addPeriodicNotification(parsedPayload: NSDictionary) {
        
        // 영상 시간을 나타내는 UISlider에 최대 * 최소값을 주기 위해서 아래 프로퍼티를 할당한다.
        let duration: CMTime = playerItem.asset.duration
//        let duration: CMTime = queuePlayerItem.items().first!.asset.duration
        let endSeconds: Float64 = CMTimeGetSeconds(duration)
        
        endTimeTimeLabel.text = convertTimeToFitText(time: Int(endSeconds))
        timeSlider.maximumValue = Float(endSeconds)
        timeSlider.minimumValue = 0
        timeSlider.isContinuous = true
        
        // gesture 관련 속성을 설정한다.
        gesture.numberOfTapsRequired = 1
        subtitleLabel.isUserInteractionEnabled = true
        subtitleLabel.addGestureRecognizer(gesture)
        
        /// keyword의 숫자만큼 "keywordRanges" 인덱스를 생성한다.
        /// - 여기서 추가된 element만큼 클릭 시, keyword 위치를 받을 수 있다.
        /// - 10개를 만든다면 10의 키워드 위치를 저장할 수 있다.
        /// - 키워드 위치를 저장할 프로퍼티에 공간을 확보한다
        // Default 값을 "100,100" 임의로 부여한다.
        for _ in 0...11 {self.keywordRanges.append(NSRange(location: 100, length: 100))}
        
        // Default 값을 "100...103" 임의로 부여한다.
        for _  in 0...11 {self.sTagsRanges.append(Range<Int>(100...103))}
        
        // "forInterval"의 시간마다 코드로직을 실행한다.
        self.player.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 60),
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                guard let strongSelf = self else { return }
                let label = strongSelf.subtitleLabel
                
                // 영상의 시간이 흐름에 따라 UISlider가 이동하도록한다.
                strongSelf.timeSlider.value = Float(time.seconds)
                
                // 영상의 시간이 흐름에 따라 Slider 좌측 Label의 텍스트를 변경한다.
                let currentTimeInt = Int(time.seconds)
                strongSelf.currentTimeLabel.text
                    = strongSelf.convertTimeToFitText(time: currentTimeInt)
                
                if time.seconds >= endSeconds {
                    NotificationCenter.default.post(name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                    object: nil)
                }
                
                // "Subtitles"에서 (자막의 시간만)필터링한 자막값을 옵셔널언랩핑한다.
                if let subtitleText = Subtitles.searchSubtitles(strongSelf.subtitles.parsedPayload,
                                                                time.seconds) {
                    /// 슬라이싱한 최종결과를 저장할 프로퍼티
                    var subtitleFinal = String()
                    /// 태그의 개수를 파악하기 위해 정규표현식을 적용한 string 프로퍼티
                    let tagCounter = (subtitleText.getOnlyText(regex: "<"))
                    /// 태그의 개수를 Int로 캐스팅한 Int 프로퍼티
                    let numberOfsTags = Int(Double(tagCounter.count) * 0.5)
                    /// ">"값을 기준으로 자막을 슬라이싱한 텍스트
                    let firstSlicing = subtitleText.split(separator: ">")
                    
                    // "<"값을 기준으로 자막을 슬라이싱한 후, "subtitleFinal에 결과를 입력한다.
                    if numberOfsTags >= 1 {
                        subtitleFinal = strongSelf.filteringFontTagInSubtitleText(text: subtitleText)
                        
                        //                        subtitleFinal = strongSelf.sliceSubtitleText(slicedText: firstSlicing,
                        //                                                                     arrayIndex: numberOfsTags * 2)
                    } else {
                        subtitleFinal = subtitleText
                    }
                    
                    /// 자막이 변경된 경우 실행되는 조건문
                    /// - 자막이 변경되었다면, `true`로 판정되고 기존의 keyword를 defaultvalue로 할당한다.
                    /// - 자막이 변경되지 않았다면, `false`로 판정되고 if절을 통과한다.
                    if subtitleFinal.count != label.text?.count {
                        // default 값 입력
                        for rangeIndex in 0...strongSelf.sTagsRanges.count-1 {
                            strongSelf.sTagsRanges[rangeIndex] = Range(100...103)
                            strongSelf.keywordRanges[rangeIndex] = NSRange(location: 100, length: 100)
                        }
                    }
                    
                    // 필터링된 최종 값을 label.text에 입력한다.
                    label.text = subtitleFinal
                    /// sTag값에 해당하는 text에 색상과 폰트를 설정하기 위한 프로퍼티
                    let keywordAttriString = NSMutableAttributedString(string: subtitleFinal)
                    
                    /* API에서 sTag 값을 받아올 위치 */
                    strongSelf.sTagsArray.removeAll()
                    for index in 0 ... strongSelf.tempsTagsArray.count - 1 {
                        strongSelf.sTagsArray.append(strongSelf.tempsTagsArray[index])
                    }
                    
                    // 자막이 필터링된 값 중 "#"가 있는 keyword를 찾아서 텍스트 속성부여 + gesture를 추가기위해 if절 로직을 실행한다.
                    /* 자막에 "#"가 존재하는 경우 */
                    if subtitleFinal.contains("#") {
                        // "#"을 기준으로 자막을 나눈다.
                        let subtitleArray = subtitleText.split(separator: "#")
                        // "#"의 개수를 확인한다.
                        let hashtagCounter = (subtitleFinal.getOnlyText(regex: "#"))
                        /// #"의 개수 프로퍼티
                        let numberOfHasgtags = hashtagCounter.count
                        
                        /// 키워드 개수에 맞게 글자 속성 부여 및 클릭 시 호출되도록 설정 메소드
                        /// - "subtitleLabel"의 foregroundColor 변경(default: .orange)
                        /// - "subtitleLabel"의 Font 변경(default: 14)
                        /// - "subtitleLabel" 클릭 시, 클릭한 키워드 판별로직
                        strongSelf.manageTextInSubtitle(numberOfHasgtags: numberOfHasgtags,
                                                        subtitleArray: subtitleArray,
                                                        sTagsArray: strongSelf.sTagsArray,
                                                        keywordAttriString: keywordAttriString,
                                                        subtitleFinal: subtitleFinal,
                                                        label: label)
                    }
                }
            })
        
    }
    
    /// View 최상단 영상 시작 메소드
    func playVideo() {
        playerController.delegate = self
        
        // AVPlayer에 외부 URL을 포함한 값을 입력한다.
        player = AVPlayer(url: videoURL! as URL)
        playerController.player = player
        
        // AVPlayerController를 "ViewController" childController로 등록한다.
        self.addChild(playerController)
        
        /// 공만세 적용 한글 인코딩 결과 값
        let subtitleInKor = makeStringKoreanEncoded(vttURL)
        let subtitleRemoteUrl = URL(string: subtitleInKor)
        
        // 자막URL을 포함한 값을 AVPlayer와 연동한다.
        open(fileFromRemote: subtitleRemoteUrl!)
        
        // Text 색상 변경값 입력한다.
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.textColor = .white
        let convertedHeight = convertHeight(231, standardView: view)
        let convertedConstant = convertHeight(65.45, standardView: view)
        
        playerController.view.setDimensions(height: view.frame.width * 0.57,
                                            width: view.frame.width)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.width,
                                             height: convertedHeight - convertedConstant)
        playerController.view.contentMode = .scaleToFill
        
        playerController.didMove(toParent: self)
        
        player.play()
//        pageCollectionView.reloadData()
//        pageCollectionView.setNeedsDisplay()
        player.isMuted = false
    }
    
    
    func configureVideoControlView() {
        let playerHeight = view.frame.width * 0.57
        videoContainerView.addSubview(blackViewOncontrolMode)
        blackViewOncontrolMode.setDimensions(height: playerHeight, width: view.frame.width)
        blackViewOncontrolMode.centerX(inView: videoContainerView)
        blackViewOncontrolMode.centerY(inView: videoContainerView)
        
        // 동영상 컨트롤 컨테이너뷰 - AutoLayout
        videoContainerView.addSubview(videoControlContainerView)
        let height = convertHeight(15, standardView: view)
        
        videoControlContainerView.setDimensions(height: height, width: view.frame.width)
        videoControlContainerView.centerX(inView: videoContainerView)
        videoControlContainerView.anchor(bottom: videoContainerView.bottomAnchor,
                                         paddingBottom: 17)
        // backButton
        videoContainerView.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left:view.leftAnchor,
                          paddingTop: 10,
                          paddingLeft: 10)
        backButton.addTarget(self, action: #selector(handleBackButtonAction),
                             for: .touchUpInside)
        backButton.alpha = 1
        backButton.setDimensions(height: 30, width: 30)
        
        // 타임라인 timerSlider
        let convertedWidth = convertWidth(244, standardView: view)
        videoControlContainerView.addSubview(timeSlider)
        timeSlider.setDimensions(height: 5, width: convertedWidth - 32)
        timeSlider.centerX(inView: videoControlContainerView)
        timeSlider.centerY(inView: videoControlContainerView,constant: -10)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged),
                             for: .valueChanged)
        // 현재시간을 나타내는 레이블
        videoControlContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.centerY(inView: timeSlider)
        currentTimeLabel.anchor(right: timeSlider.leftAnchor,
                                paddingRight: 5,
                                height: 13)
        // 종료시간을 나타내는 레이블
        videoControlContainerView.addSubview(endTimeTimeLabel)
        endTimeTimeLabel.centerY(inView: timeSlider)
        endTimeTimeLabel.anchor(left: timeSlider.rightAnchor,
                                paddingLeft: 5,
                                height: 13)
        // Orientation 변경하는 버튼
        videoControlContainerView.addSubview(changeOrientationButton)
        changeOrientationButton.setDimensions(height: 20, width: 20)
        changeOrientationButton.centerY(inView: timeSlider)
        changeOrientationButton.anchor(left: endTimeTimeLabel.rightAnchor,
                                       paddingLeft: 5)
        // VideoSettingButton
        videoContainerView.addSubview(videoSettingButton)
        videoSettingButton.anchor(top: videoContainerView.topAnchor,
                                  right: videoContainerView.rightAnchor,
                                  paddingTop: 10,
                                  paddingRight: 10)
        // 자막 생성 및 제거 버튼
        videoContainerView.addSubview(subtitleToggleButton)
        subtitleToggleButton.centerY(inView: videoSettingButton)
        subtitleToggleButton.anchor(right: videoSettingButton.leftAnchor,
                                    paddingRight: 3)
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                    action: #selector(targetViewDidTapped))
        gesture.numberOfTapsRequired = 1
        blackViewOncontrolMode.isUserInteractionEnabled = true
        blackViewOncontrolMode.addGestureRecognizer(gesture)
    }
    
    /// 동영상 클릭 시, 동영상 조절버튼을 사라지도록 하는 메소드
    @objc func targetViewDidTapped() {
        if blackViewOncontrolMode.backgroundColor == .black {
            UIView.animate(withDuration: 0.22, animations: {
                self.blackViewOncontrolMode.backgroundColor = .clear
                self.videoControlContainerView.alpha = 0
                self.playPauseButton.alpha = 0
                self.videoForwardTimeButton.alpha = 0
                self.videoBackwardTimeButton.alpha = 0
                self.videoSettingButton.alpha = 0
                self.subtitleToggleButton.alpha = 0
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut, animations: {
                self.blackViewOncontrolMode.backgroundColor = .black
                self.videoControlContainerView.alpha = 1
                self.playPauseButton.alpha = 1
                self.videoForwardTimeButton.alpha = 1
                self.videoBackwardTimeButton.alpha = 1
                self.videoSettingButton.alpha = 1
                self.subtitleToggleButton.alpha = 1
            }, completion: nil)
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
}
