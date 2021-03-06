import AVKit

// MARK: - Video Method

extension VideoController {
    /// 자막표시여부 버튼을 클릭하면 호출하는 콜백메소드
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
    
    /// 클릭 시, 설정 BottomPopupController 호출하는 메소드
    @objc func handleSettingButton() {
        let vc = VideoSettingPopupController()
        vc.currentStateIsVideoPlayRate = currentVideoPlayRate == 1 ? "기본" : "\(currentVideoPlayRate)배"
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
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        player.pause()
        NotificationCenter.default.removeObserver(self)
        setRemoveNotification()
        removePeriodicTimeObserver()
        
        videoDataManager.isFirstPlayVideo = true
        
        //0711 - added by hp
        //뒤로가기 할때 비디오 로그에서 마지막로그 삭제
        videoDataManager.removeVideoLastLog()
        PIPDataManager.shared.currentVideoTime = 0
        
        controllerTimer?.invalidate()
        
        dismiss(animated: true, completion: nil)
    }
    
    // 슬라이더를 이동하면 player의 값을 변경해주는 메소드(.valueChaned 시 호출되는 콜백메소드)
    @objc func timeSliderValueChanged(_ slider: UISlider, event: UIEvent) {
        let seconds = Int64(slider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        // slider 이동 중 사라지지 않도록 event 제어, slider 이동 완료된 후 seek 하도록 수정.
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                isSliderMoved = true
                controllerTimer?.invalidate()
            case .ended:
                print("touch ended")
                isSliderMoved = false
                controllerTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: false)
                player.seek(to: targetTime)
                
            default:
                print("touch state : \(touchEvent.phase)")
            }
        }
        currentTimeLabel.text = convertTimeToFitText(time: Int(targetTime.seconds))
    }
    
    //재실행
    @objc func replayPlayer() {
        self.replayButton.alpha = 0
        
        self.setRemoveNotification()
        self.setNotification()
        
        self.isStartVideo = false
        self.isEndVideo = false
        self.playInOutroVideo(1)
        self.backButton.alpha = 1
    }
    
    /// 플레이어 재생 및 일시정지 액션을 담당하는 콜백메소드
    @objc func playPausePlayer() {
        /// 연산프로퍼티 "isPlaying" 에 따라서 플레이어를 정지 혹은 재생시킨다.
        if isPlaying {
            player.pause()
            
        } else {
            player.playImmediately(atRate: currentVideoPlayRate)
        }
        setPlayButtonImage()
    }
    
    /// 동영상 앞으로 가기 기능을 담당하는 콜백 메소드
    @objc func moveForwardPlayer() {
        /// 10초를 계산하기 위한 프로퍼티
        let seconds = 10.0//Double(230) / Double(23.98)
        
        /// 23 프레임을 기준으로 10초를 입력한 CMTime 프로퍼티
        let oneFrame = CMTime(seconds: seconds, preferredTimescale: 600)
        
        /// CMTimeAdd를 적용한 프로퍼티
        let addTime = CMTimeAdd(player.currentTime(), oneFrame)
        player.seek(to: addTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// 동영상 뒤로 가기 기능을 담당하는 콜백 메소드
    @objc func moveBackwardPlayer() {
        let seconds = 10.0//Double(230) / Double(23.98)
        let oneFrame = CMTime(seconds: seconds, preferredTimescale: 60)
        let subTractTime = CMTimeSubtract(player.currentTime(), oneFrame)
        player.seek(to: subTractTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// 영상 종료 시, 호출될 콜백메소드
    @objc func playerItemDidReachEnd(notification: NSNotification) {
//        player.seek(to: CMTime.zero)
        if isStartVideo == false { //인트로 동영상 종료
            self.backButton.alpha = 0
            isStartVideo = true
            
            if !isFullScreenMode {
                AppDelegate.AppUtility.lockOrientation(.all)
            }
            
            self.playVideo()
        } else if isEndVideo == false { //기본 영상 종료
            isEndVideo = true
            removePeriodicTimeObserver()
            self.playInOutroVideo(2)
            self.replayButton.alpha = 1
            self.backButton.alpha = 1
        } else { //아웃트로 동영상 종료
            self.replayButton.alpha = 0
            self.backButton.alpha = 0
            setRemoveNotification()
            
            autoPlayVideo()
        }
    }

    func autoPlayVideo() {
        // 플레이 리스트에서 현재 인덱스를 찾는다.
        // 그 인덱스에 +1을 한다.
        // +1 한 인덱스의 videoID를 추출한다.
        // videoID를 "DetailVideoDataManager"에 할당한다.
        // 영상이 실행된다.
        
        //로그인 체크한다
        if !Constant.isLogin {
            let pvc = self.presentingViewController!
            dismiss(animated: true) {
                pvc.presentAlert(message: "로그인 후 사용해 주세요.")
            }
            return
        }
        if Constant.remainPremiumDateInt == nil {
            let pvc = self.presentingViewController!
            dismiss(animated: true) {
                pvc.presentAlert(message: "이용권을 구매해 주세요.")
            }
            return
        }
        
        var nextVideoID = "" //다음 동영상ID
        let autoPlayDataManager = AutoplayDataManager.shared
        
        if autoPlayDataManager.isAutoPlay {
            for i in 0 ..< autoPlayDataManager.videoDataList.count {
                if autoPlayDataManager.videoDataList[i].videoId == videoDataManager.currentVideoID && i != autoPlayDataManager.videoDataList.count - 1 {
                    nextVideoID = autoPlayDataManager.videoDataList[i + 1].videoId ?? ""
                }
            }
        } else {
            for i in 0 ..< autoPlayDataManager.videoSeriesDataList.count {
                if autoPlayDataManager.videoSeriesDataList[i].id == videoDataManager.currentVideoID && i != autoPlayDataManager.videoSeriesDataList.count - 1 {
                    nextVideoID = autoPlayDataManager.videoSeriesDataList[i + 1].id ?? ""
                }
            }
        }
        if nextVideoID.isEmpty {
//            dismiss(animated: true, completion: nil)
            self.replayButton.alpha = 1
            self.backButton.alpha = 1
            return
        }
        
        
        let inputData = DetailVideoInput(video_id: nextVideoID,
                                         token: Constant.token)
        
        self.id = nextVideoID
        
        let isHidden1 = self.noteViewController?.view.isHidden ?? true
        let isHidden2 = self.qnaCell?.isHidden ?? true
        // "상세화면 영상 API"를 호출한다.
        DetailVideoDataManager().DetailVideoDataManager(inputData, viewController: self, showIntro: true, refreshList: false)
        
        videoDataManager.removeVideoLastLog()
        //하단 노트보기, QnA 불러온다, 재생목록은 시리즈ID를 받은다음에
        loadBottomNote(isHidden1)
        loadBottomQnA(isHidden2)
    }
}

extension VideoController: AVPlayerViewControllerDelegate {
    func open(fileFromLocal filePath: URL,
              encoding: String.Encoding = String.Encoding.utf8)
    {
        let contents = try! String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
    }
    
    func open(fileFromRemote filePath: URL,
              encoding: String.Encoding = String.Encoding.utf8)
    {
        subtitleLabel.text = ""
        subtitleLabel.isHidden = true
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
                                           self.subtitleLabel.text = ""
//                                           self.subtitleLabel.isHidden = false
                                           if let checkData = data as Data? {
                                               if let contents = String(data: checkData, encoding: encoding) {
                                                   self.show(subtitles: contents)
                                               }
                                           }
                                       }
                                   }).resume()
    }
    
    func show(subtitles string: String) {
        // subtitle에 파싱한 값을 넣는다.
        subtitles.parsedPayload = Subtitles.parseSubRip(string)
        addPeriodicNotification(parsedPayload: subtitles.parsedPayload!)
    }
    
    func showByDictionary(dictionaryContent: NSMutableDictionary) {
        // 파싱한 데이터가 Dictionary이고 해당 값을 넣는다.
        subtitles.parsedPayload = dictionaryContent
        addPeriodicNotification(parsedPayload: subtitles.parsedPayload!)
    }
    
    /* keyword 텍스트에 적절한 변화를 주고, 클릭 시 action이 호출될 수 있도록 관리하는 메소드 */
    /// "Player"가 호출된 후, 일정시간마다 호출되는 메소드
    func addPeriodicNotification(parsedPayload: NSDictionary) {
        // 영상 시간을 나타내는 UISlider에 최대 * 최소값을 주기 위해서 아래 프로퍼티를 할당한다.
        
        var duration = CMTime()
        if let playerItem = self.playerItem {
            duration = playerItem.asset.duration
        }
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
        for _ in 0...11 { keywordRanges.append(NSRange(location: 100, length: 100)) }
        
        // Default 값을 "100...103" 임의로 부여한다.
        for _ in 0...11 { sTagsRanges.append(Range<Int>(100...103)) }
        
        // "forInterval"의 시간마다 코드로직을 실행한다.
        self.timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 60),
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                guard let strongSelf = self else { return }
                
                if strongSelf.player.currentItem?.status == AVPlayerItem.Status.readyToPlay {

                    strongSelf.playerController1.view.isHidden = true
                    strongSelf.playerController.view.isHidden = false
                    strongSelf.subtitleLabel.isHidden = false
                }
                
                let label = strongSelf.subtitleLabel
                
                // 22.02.17 slider 이동 중에는 slider 위치의 시간이 표시되도록 수정
                if !strongSelf.isSliderMoved {
                    // 영상의 시간이 흐름에 따라 UISlider가 이동하도록한다.
                    strongSelf.timeSlider.value = Float(time.seconds)
                
                    // 영상의 시간이 흐름에 따라 Slider 좌측 Label의 텍스트를 변경한다.
                    let currentTimeInt = Int(time.seconds)
                    strongSelf.currentTimeLabel.text
                        = strongSelf.convertTimeToFitText(time: currentTimeInt)
                }
                if time.seconds >= endSeconds {
//                    NotificationCenter.default.post(name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
//                                                    object: nil)
                }
                
                // "Subtitles"에서 (자막의 시간만)필터링한 자막값을 옵셔널언랩핑한다.
                if let subtitleText = Subtitles.searchSubtitles(strongSelf.subtitles.parsedPayload,
                                                                time.seconds) {                    
                    /// 슬라이싱한 최종결과를 저장할 프로퍼티
                    var subtitleFinal = String()
                    /// 태그의 개수를 파악하기 위해 정규표현식을 적용한 string 프로퍼티
                    let tagCounter = subtitleText.getOnlyText(regex: "<")
                    /// 태그의 개수를 Int로 캐스팅한 Int 프로퍼티
                    let numberOfsTags = Int(Double(tagCounter.count) * 0.5)
                    /// ">"값을 기준으로 자막을 슬라이싱한 텍스트
//                    let firstSlicing = subtitleText.split(separator: ">")
                    
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
                        for rangeIndex in 0...strongSelf.sTagsRanges.count - 1 {
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
                    if strongSelf.tempsTagsArray.count > 0 {
                        for index in 0...strongSelf.tempsTagsArray.count - 1 {
                            strongSelf.sTagsArray.append(strongSelf.tempsTagsArray[index])
                        }
                    }
                    
                    // 자막이 필터링된 값 중 "#"가 있는 keyword를 찾아서 텍스트 속성부여 + gesture를 추가기위해 if절 로직을 실행한다.
                    /* 자막에 "#"가 존재하는 경우 */
                    if subtitleFinal.contains("#") {
                        print("# subtitleFinal : \(subtitleFinal)")
                        // "#"을 기준으로 자막을 나눈다.
                        let subtitleArray = subtitleText.split(separator: "#")
                        print("subtitleArray : \(subtitleArray)")
                        
                        // "#"의 개수를 확인한다.
                        let hashtagCounter = subtitleFinal.getOnlyText(regex: "#")
                        print("hashtagCounter : \(hashtagCounter), \(hashtagCounter.count)")
                        
                        // #"의 개수 프로퍼티
                        let numberOfHasgtags = hashtagCounter.count
                        
                        // 키워드 개수에 맞게 글자 속성 부여 및 클릭 시 호출되도록 설정 메소드
                        // - "subtitleLabel"의 foregroundColor 변경(default: .orange)
                        // - "subtitleLabel"의 Font 변경(default: 14)
                        // - "subtitleLabel" 클릭 시, 클릭한 키워드 판별로직
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
    
    func playInOutroVideo(_ _type: Int) {
        if _type == 1 {
            self.replayButton.alpha = 0
        }
        
        //컨트롤러를 숨기자
        if blackViewOncontrolMode.backgroundColor == .black {
            self.targetViewDidTapped()
        }
        
        subtitleLabel.isHidden = true
        playerController1.delegate = self
        
        let introURL = URL(fileURLWithPath:Bundle.main.path(forResource: _type == 1 ? "비율수정인트로영상" : "gong_outro1",
                                                            ofType: "mov")!)
        
        // Random Intro 적용할 때, 사용할 코드
        let introURL02 = URL(fileURLWithPath:Bundle.main.path(forResource: _type == 1 ? "인트로영상01" : "gong_outro2",
                                                            ofType: "mov")!)
        let introArr = [introURL, introURL02]
        let resultIntro = introArr.randomElement() ?? introURL
        
        player = AVPlayer(url: resultIntro)
        playerController1.player = player
//
        // AVPlayerController를 "ViewController" childController로 등록한다.
        addChild(playerController1)

//        let convertedHeight = convertHeight(231, standardView: view)
//        let convertedConstant = convertHeight(65.45, standardView: view)
//
//        playerController1.view.setDimensions(height: !isFullScreenMode ? view.frame.width * 0.57 : view.frame.height, width: view.frame.width)
//        playerController1.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.width,
//                                             height: convertedHeight - convertedConstant)
//        playerController1.view.contentMode = .scaleToFill
//
        playerController1.didMove(toParent: self)
        
        playerController1.view.isHidden = false
        playerController.view.isHidden = true
        
        DispatchQueue.main.async {
            self.player.play()
        }
        player.isMuted = false
    }
    
    /// View 최상단 영상 시작 메소드
    func playVideo() {
        if self.videoURL!.absoluteString!.isEmpty {
            ///인트로가 끝나더라도 동영상 데이터를 아직 불러오지 못한 경우
            return
        }
        subtitleLabel.isHidden = false
        playerController.delegate = self
                
//        // AVPlayer에 외부 URL을 포함한 값을 입력한다.
        player = AVPlayer(url: videoURL! as URL)
        playerController.player = player
//
        // AVPlayerController를 "ViewController" childController로 등록한다.
        addChild(playerController)

        /// 공만세 적용 한글 인코딩 결과 값
        let subtitleInKor = makeStringKoreanEncoded(vttURL)
        let subtitleRemoteUrl = URL(string: subtitleInKor)

        // 자막URL을 포함한 값을 AVPlayer와 연동한다.
        open(fileFromRemote: subtitleRemoteUrl!)

        // Text 색상 변경값 입력한다.
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.textColor = .white
//        let convertedHeight = convertHeight(231, standardView: view)
//        let convertedConstant = convertHeight(65.45, standardView: view)
//
//        playerController.view.setDimensions(height: !isFullScreenMode ? view.frame.width * 0.57 : view.frame.height, width: view.frame.width)
//        playerController.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.width,
//                                             height: convertedHeight - convertedConstant)
        playerController.view.contentMode = .scaleToFill
//
        playerController.didMove(toParent: self)
        
//        playerController1.view.isHidden = true
//        playerController.view.isHidden = false
        
        DispatchQueue.main.async {
//            print("videoPlayer play() : \(String(describing: self.autoPlaySeekTime))")
            if let seekTime = self.autoPlaySeekTime {
//                print("autoPlaySeekTime : \(seekTime.seconds), \(seekTime.timescale)")
                self.player.seek(to: seekTime)
                self.autoPlaySeekTime = nil// 다음 파일 재생 시 참조하지 않도록 seek 뒤 초기화.
            } else if let pipData = self.pipData {
//                print("pipData..")
                if !pipData.currentVideoTime.isNaN && pipData.currentVideoTime != 0.0 && self.videoDataManager.previousVideoID == self.id {
                    let seconds: Int64 = Int64(pipData.currentVideoTime)
                    let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
                    self.player.seek(to: targetTime)
                    self.pipData?.currentVideoTime = 0.0 //reset
                    PIPDataManager.shared.currentVideoTime = 0
                }
            }

            self.player.play()
            self.setPlayButtonImage()
        }
        
//        pageCollectionView.reloadData()
//        pageCollectionView.setNeedsDisplay()
        player.isMuted = false
    }
    
    // play 상태 변경 시 재생버튼 이미지 변경
    func setPlayButtonImage() {
        let playImage = UIImage(named: "영상재생버튼")
        let pauseImage = UIImage(named: "영상일시정지버튼")
        if !isPlaying {
            playPauseButton.setBackgroundImage(playImage, for: .normal)
        } else {
            playPauseButton.setBackgroundImage(pauseImage, for: .normal)
        }
    }
    
    func configureVideoControlView() {
//        let playerHeight = !isFullScreenMode ? view.frame.width * 0.57 : view.frame.height
        videoContainerView.addSubview(blackViewOncontrolMode)
//        blackViewOncontrolMode.setDimensions(height: playerHeight, width: view.frame.width)
//        blackViewOncontrolMode.centerX(inView: videoContainerView)
//        blackViewOncontrolMode.centerY(inView: videoContainerView)
        blackViewOncontrolMode.anchor(top: videoContainerView.topAnchor,
                                     left: videoContainerView.leftAnchor,
                                     bottom: videoContainerView.bottomAnchor,
                                     right: videoContainerView.rightAnchor)
        
        // 동영상 컨트롤 컨테이너뷰 - AutoLayout
        videoContainerView.addSubview(videoControlContainerView)
        let height = convertHeight(15, standardView: view)
        
//        videoControlContainerView.setDimensions(height: height, width: view.frame.width)
//        videoControlContainerView.centerX(inView: videoContainerView)
//        videoControlContainerView.anchor(bottom: videoContainerView.bottomAnchor,
//                                         paddingBottom: 30)
        
        videoControlContainerView.anchor(left: videoContainerView.leftAnchor,
                                     right: videoContainerView.rightAnchor,
                                     height: height)
        videoControlContainerViewBottomConstraint
            = videoControlContainerView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: -45)
        videoControlContainerViewBottomConstraint?.isActive = true
        
        // backButton
        
        // safearea영역에 생겨 클릭이 불가능했던것을 수정
        videoContainerView.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.safeAreaLayoutGuide.leftAnchor,
                          paddingTop: 10,
                          paddingLeft: 10)
        backButton.addTarget(self, action: #selector(handleBackButtonAction),
                             for: .touchUpInside)
        backButton.alpha = 0
        backButton.setDimensions(height: 30, width: 30)
        
        // 타임라인 timerSlider
//        let convertedWidth = convertWidth(244, standardView: view)
        videoControlContainerView.addSubview(timeSlider)
//        timeSlider.setDimensions(height: 25, width: convertedWidth - 32)
        timeSlider.anchor(left: videoControlContainerView.leftAnchor,
                          right: videoControlContainerView.rightAnchor,
                          paddingLeft: 83,
                          paddingRight: 83,
                          height: 25)
//        timeSlider.centerX(inView: videoControlContainerView)
        timeSlider.centerY(inView: videoControlContainerView, constant: 0)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged),
                             for: .valueChanged)
        // 현재시간을 나타내는 레이블
        videoControlContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.centerY(inView: timeSlider)
        currentTimeLabel.anchor(right: timeSlider.leftAnchor,
                                paddingRight: 15,
                                height: 13)
        // 종료시간을 나타내는 레이블
        videoControlContainerView.addSubview(endTimeTimeLabel)
        endTimeTimeLabel.centerY(inView: timeSlider)
        endTimeTimeLabel.anchor(left: timeSlider.rightAnchor,
                                paddingLeft: 15,
                                height: 13)
        // Orientation 변경하는 버튼
        videoControlContainerView.addSubview(changeOrientationButton)
        changeOrientationButton.centerY(inView: timeSlider)
        changeOrientationButton.anchor(left: endTimeTimeLabel.rightAnchor,
                                       paddingLeft: 2)
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
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(targetViewDidTapped))
        gesture.numberOfTapsRequired = 1
        blackViewOncontrolMode.isUserInteractionEnabled = true
        blackViewOncontrolMode.addGestureRecognizer(gesture)
    }
    
    /// 동영상 클릭 시, 동영상 조절버튼을 사라지도록 하는 메소드
    @objc func targetViewDidTapped() {
        if blackViewOncontrolMode.backgroundColor == .black {
            controllerTimer?.invalidate()
            
            UIView.animate(withDuration: 0.22, animations: {
                self.blackViewOncontrolMode.backgroundColor = .clear
                self.videoControlContainerView.alpha = 0
                self.playPauseButton.alpha = 0
                self.videoForwardTimeButton.alpha = 0
                self.videoBackwardTimeButton.alpha = 0
                self.videoSettingButton.alpha = 0
                self.subtitleToggleButton.alpha = 0
                self.backButton.alpha = 0
            }, completion: nil)
            
        } else {
            if !self.isStartVideo || self.isEndVideo { //인아웃트로 중에는 막자
                return
            }
            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut, animations: {
                self.blackViewOncontrolMode.backgroundColor = .black
                self.videoControlContainerView.alpha = 1
                self.playPauseButton.alpha = 1
                self.videoForwardTimeButton.alpha = 1
                self.videoBackwardTimeButton.alpha = 1
                self.videoSettingButton.alpha = 1
                self.subtitleToggleButton.alpha = 1
                self.backButton.alpha = 1
            }, completion: nil)
            
            controllerTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: false)
        }
    }
    
    @objc func startTimer() {
        UIView.animate(withDuration: 0.22, animations: {
            self.blackViewOncontrolMode.backgroundColor = .clear
            self.videoControlContainerView.alpha = 0
            self.playPauseButton.alpha = 0
            self.videoForwardTimeButton.alpha = 0
            self.videoBackwardTimeButton.alpha = 0
            self.videoSettingButton.alpha = 0
            self.subtitleToggleButton.alpha = 0
            self.backButton.alpha = 0
        }, completion: nil)
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}
