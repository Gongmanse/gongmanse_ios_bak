import UIKit

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
        DetailVideoDataManager().DetailVideoDataManager(inputData, viewController: self)
    }
    
    /// 전반적인 UI 구현 메소드
    func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        navigationController?.hidesBarsOnSwipe = true
        
        // 강의정보 View를 대신할 Controller 추가
        let lessonInfoController = LessonInfoController()
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
    }
    
    /// customMenuBar의 sroll관련 로직을 처리하는 메소드
    func customMenuBar(scrollTo index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    /// "노트보기" ... 등 CollectionView 설정을 위한 메소드
    func setupPageCollectionView(){
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
    
    func setRemoveNotification() {
        NotificationCenter.default.removeObserver(self, name: .switchSubtitleOnOff, object: nil)
        NotificationCenter.default.removeObserver(self, name: .changePlayVideoRate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setNotification() {
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


extension Notification.Name {
    static let detectVideoEnded = Notification.Name("videoEnded")
}

// MARK: - Notificaion

extension Notification.Name {
    
    /// 자막보기 설정
    static let switchSubtitleOnOff = Notification.Name("switchSubtitleOnOff")
    
    /// 영상 속도 조절
    static let changePlayVideoRate = Notification.Name("changePlayVideoRate")
}
