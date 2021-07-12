import UIKit
import AVKit

extension VideoController {
    /// 강의 및 선생님 정보 View 하단에 있는 버튼 toggle 기능담당 메소드
    @objc func handleToggle() {
        if teacherInfoFoldConstraint!.isActive == true {
            teacherInfoFoldConstraint!.isActive = false
            teacherInfoUnfoldConstraint!.isActive = true
        } else {
            teacherInfoFoldConstraint!.isActive = true
            teacherInfoUnfoldConstraint!.isActive = false
        }
        pageCollectionView.reloadData()
    }

    
    /// 화면 Orientation 변경 버튼 호출시, 호출되는 콜백메소드
    @objc func presentFullScreenMode() {
        setRemoveNotification()
        
        // 화면을 "LandscapeRight"로 고정한다.
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)
        
        // vc에 현재 재생되는 시간을 전달한다.
        let currentTime = player.currentTime()
        let vc = VideoFullScreenController(playerCurrentTime: currentTime, urlData: self.videoAndVttURL)
        vc.id = self.id
        vc.delegate = self
        
        NotificationCenter.default.removeObserver(self)
        removePeriodicTimeObserver()
        player.pause()
        present(vc, animated: true)
    }

    /// 데이터 구성을 위한 메소드
    func configureDataAndNoti() {
        // 관찰자를 추가한다.
        setNotification()
        
        guard let id = id else { return }
        let inputData = DetailVideoInput(video_id: id, token: Constant.token)
        
        // "상세화면 영상 API"를 호출한다.
        if Constant.isGuestKey || Constant.remainPremiumDateInt == nil {
            GuestKeyDataManager().GuestKeyAPIGetData(videoID: id, viewController: self)
            videoDataManager.addVideoIDLog(videoID: id)
        } else {
            DetailVideoDataManager().DetailVideoDataManager(inputData, viewController: self)
        }
    }
    
    /// 전반적인 UI 구현 메소드
    func configureUI() {
        // 강의정보 키워드 클릭 시, 영상을 일시중지하기 위한 Delegation
        lessonInfoController.isChangedName = self.isChangedName
        lessonInfoController.delegate = self
        
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        navigationController?.hidesBarsOnSwipe = true
        
        // 강의정보 View를 대신할 Controller 추가
        self.addChild(lessonInfoController)
        lessonInfoController.didMove(toParent: self)
        lessonInfoView.addSubview(lessonInfoController.view)
        lessonInfoController.view.frame = lessonInfoView.bounds
        
        // 세로모드 제약조건 정의한다.
        setConstraintInPortrait()
        setupPageCollectionView() // View 중단부터 하단에 있는 "노트보기", "강의 QnA" 그리고 "재생목록" 페이지 구현 메소드
        changeConstraintToVideoContainer(isPortraitMode: false) // 최초 제약조건 부여
        
        // 영상 플레이어컨트롤러 하단 상태표시슬라이드 display 여부
        playerController.showsPlaybackControls = false
        
        // 시작 시, 영상 컨트롤 버튼을 숨긴다.
        self.blackViewOncontrolMode.backgroundColor = .clear
        self.videoControlContainerView.alpha = 0
        self.playPauseButton.alpha = 0
        self.videoForwardTimeButton.alpha = 0
        self.videoBackwardTimeButton.alpha = 0
        self.videoSettingButton.alpha = 0
        self.subtitleToggleButton.alpha = 0
        
        timeSlider.transform = CGAffineTransform (scaleX: 1.05, y: 1.05)
        timeSlider.setThumbImage(#imageLiteral(resourceName: "checkFalse"), for: .normal)
    }
    
    /// customMenuBar의 sroll관련 로직을 처리하는 메소드
    func customMenuBar(scrollTo index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        // 현재 재생중인 cell 포커싱 + 하이라이트를 위한 로직 06.16
        self.pageCollectionView.reloadItems(at: [IndexPath(item: 2, section: 0)])
    }
    
    /// "노트보기" ... 등 CollectionView 설정을 위한 메소드
    func setupPageCollectionView() {
        pageCollectionView.isScrollEnabled = false
        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        pageCollectionView.backgroundColor = .white
        pageCollectionView.showsHorizontalScrollIndicator = false
        pageCollectionView.isPagingEnabled = true
        pageCollectionView.register(BottomNoteCell.self,
                                    forCellWithReuseIdentifier: BottomNoteCell.reusableIdentifier)
        pageCollectionView.register(BottomQnACell.self,
                                    forCellWithReuseIdentifier: BottomQnACell.reusableIdentifier)
        pageCollectionView.register(BottomPlaylistCell.self,
                                    forCellWithReuseIdentifier: BottomPlaylistCell.reusableIdentifier)
        pageCollectionView.register(VideoPlaylistCell.self,
                                    forCellWithReuseIdentifier: VideoPlaylistCell.reusableIdentifier)
        view.addSubview(pageCollectionView)
    }
    
    /// 동영상 바로 하단에 위치한 강의정보 및 선생님 정보가 적힌 View 설정을 위한 메소드
    func configureToggleButton() {
        view.addSubview(toggleButton)
        toggleButton.setDimensions(height: 32, width: 30)
        toggleButton.layer.cornerRadius = 8
        toggleButton.anchor(top: lessonInfoView.bottomAnchor,
                            right: lessonInfoView.rightAnchor,
                            paddingTop: -5,
                            paddingRight: 10)
        toggleButton.addTarget(self, action: #selector(handleToggle), for: .touchUpInside)
    }
    
    /// 영상관련 Notification 토큰 제거 메소드
    func setRemoveNotification() {
        // 영상 관련 토큰을 제거한다.
        NotificationCenter.default.removeObserver(self, name: .removeVideoVCToken, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        // 영상 속도 및 자막 유무 Notificaion 06.22 기준 Delegation
        NotificationCenter.default.removeObserver(self, name: .switchSubtitleOnOff, object: nil)
        NotificationCenter.default.removeObserver(self, name: .changePlayVideoRate, object: nil)
    }
    
    
    /// 영상관련 Notification 토큰 추가 메소드
    func setNotification() {

        // SearchAfterVC > 영상 테이블뷰 셀 클릭 시 호출하기 위해 생성한 NotificationCenter
        // 중간에 addObser가 풀려서 호출이 안되는 상태 06.17
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(removeNotificationFromSearchAfterVC(_:)),
                         name: NSNotification.Name.removeVideoVCToken,
                         object: nil)
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(playerItemDidReachEnd),
                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(changeValueToPlayer),
                         name: .changePlayVideoRate, object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(switchIsOnSubtitle),
                         name: .switchSubtitleOnOff, object: nil)
    }
}

// MARK: - Notificaion

extension Notification.Name {
    
    static let removeVideoVCToken = Notification.Name("removeVideoVCToken")
    
    static let detectVideoEnded = Notification.Name("videoEnded")

    /// 자막보기 설정
    static let switchSubtitleOnOff = Notification.Name("switchSubtitleOnOff")
    
    /// 영상 속도 조절
    static let changePlayVideoRate = Notification.Name("changePlayVideoRate")
}
