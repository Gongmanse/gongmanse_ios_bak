/*
 "영상" 페이지 전체를 컨트롤하는 Controller 입니다.
 * 상단 탭바를 담당하는 객체: VideoMenuBar
 * 상단 탭바의 각각의 항목을 담당하는 객체: TabBarCell 폴더 내부 객체
 * 하단 "노트보기", "강의 QnA" 그리고 "재생목록"을 담당하는 객체: BottomCell 폴더 내부 객체
 */
import AVFoundation
import AVKit
import Foundation
import UIKit

class VideoController: UIViewController, VideoMenuBarDelegate{
    
    // MARK: - Properties
    /* VideoContainterView */
    // Constraint 객체 - 세로모드
    private var videoContainerViewPorTraitWidthConstraint: NSLayoutConstraint?          // 세로모드 시, 동영상에 적용될 넓이 제약조건
    private var videoContainerViewPorTraitHeightConstraint: NSLayoutConstraint?         // 세로모드 시, 동영상에 적용될 높이 제약조건
    private var videoContainerViewPorTraitTopConstraint: NSLayoutConstraint?            // 세로모드 시, 동영상에 적용될 상단 제약조건
    private var videoContainerViewPorTraitLeftConstraint: NSLayoutConstraint?           // 세로모드 시, 동영상에 적용될 좌측 제약조건

    // Constraint 객체 - 가로모드
    private var videoContainerViewLandscapeWidthConstraint: NSLayoutConstraint?          // 가로모드 시, 동영상에 적용될 넓이 제약조건
    private var videoContainerViewLandscapeHeightConstraint: NSLayoutConstraint?         // 가로모드 시, 동영상에 적용될 높이 제약조건
    private var videoContainerViewLandscapeTopConstraint: NSLayoutConstraint?            // 가로모드 시, 동영상에 적용될 상단 제약조건
    private var videoContainerViewLandscapeLeftConstraint: NSLayoutConstraint?           // 가로모드 시, 동영상에 적용될 좌측 제약조건
    
    /* CustomTabBar */
    // Constraint 객체 - 세로모드
    private var customMenuBarPorTraitHeightConstraint: NSLayoutConstraint?                // 세로모드 시, 동영상에 적용될 높이 제약조건
    private var customMenuBarPorTraitTopConstraint: NSLayoutConstraint?                   // 세로모드 시, 동영상에 적용될 상단 제약조건
    private var customMenuBarPorTraitLeftConstraint: NSLayoutConstraint?                  // 세로모드 시, 동영상에 적용될 좌측 제약조건
    private var customMenuBarPorTraitRightConstraint: NSLayoutConstraint?                 // 세로모드 시, 동영상에 적용될 좌측 제약조건
    // Constraint 객체 - 가로모드
    private var customMenuBarLandscapeRightConstraint: NSLayoutConstraint?                // 가로모드 시, 동영상에 적용될 넓이 제약조건
    private var customMenuBarLandscapeHeightConstraint: NSLayoutConstraint?               // 가로모드 시, 동영상에 적용될 높이 제약조건
    private var customMenuBarLandscapeTopConstraint: NSLayoutConstraint?                  // 가로모드 시, 동영상에 적용될 상단 제약조건
    private var customMenuBarLandscapeLeftConstraint: NSLayoutConstraint?                 // 가로모드 시, 동영상에 적용될 좌측 제약조건
    
    /* teacherInfoView */
    // Constraint 객체 - 세로모드
    private var teacherInfoViewPorTraitCenterXConstraint: NSLayoutConstraint?              // 세로모드 시, 동영상에 적용될 넓이 제약조건
    private var teacherInfoViewPorTraitHeightConstraint: NSLayoutConstraint?             // 세로모드 시, 동영상에 적용될 높이 제약조건
    private var teacherInfoViewPorTraitTopConstraint: NSLayoutConstraint?                // 세로모드 시, 동영상에 적용될 상단 제약조건
    private var teacherInfoViewPorTraitWidthConstraint: NSLayoutConstraint?               // 세로모드 시, 동영상에 적용될 좌측 제약조건

    // Constraint 객체 - 가로모드
    private var teacherInfoViewLandscapeRightConstraint: NSLayoutConstraint?             // 가로모드 시, 동영상에 적용될 넓이 제약조건
    private var teacherInfoViewLandscapeHeightConstraint: NSLayoutConstraint?            // 가로모드 시, 동영상에 적용될 높이 제약조건
    private var teacherInfoViewLandscapeTopConstraint: NSLayoutConstraint?               // 가로모드 시, 동영상에 적용될 상단 제약조건
    private var teacherInfoViewLandscapeLeftConstraint: NSLayoutConstraint?              // 가로모드 시, 동영상에 적용될 좌측 제약조건

    /* topBorderLine */
    // Constraint 객체 - 세로모드
    private var topBorderLinePorTraitCenterXConstraint: NSLayoutConstraint?              // 세로모드 시, 동영상에 적용될 넓이 제약조건
    private var topBorderLinePorTraitHeightConstraint: NSLayoutConstraint?             // 세로모드 시, 동영상에 적용될 높이 제약조건
    private var topBorderLinePorTraitTopConstraint: NSLayoutConstraint?                // 세로모드 시, 동영상에 적용될 상단 제약조건
    private var topBorderLinePorTraitWidthConstraint: NSLayoutConstraint?               // 세로모드 시, 동영상에 적용될 좌측 제약조건
    /* bottomBorderLine */
    // Constraint 객체 - 세로모드
    private var bottomBorderLinePorTraitCenterXConstraint: NSLayoutConstraint?              // 세로모드 시, 동영상에 적용될 넓이 제약조건
    private var bottomBorderLinePorTraitHeightConstraint: NSLayoutConstraint?             // 세로모드 시, 동영상에 적용될 높이 제약조건
    private var bottomBorderLinePorTraitBottomConstraint: NSLayoutConstraint?                // 세로모드 시, 동영상에 적용될 상단 제약조건
    private var bottomBorderLinePorTraitWidthConstraint: NSLayoutConstraint?               // 세로모드 시, 동영상에 적용될 좌측 제약조건
    
    
    /* pageCollectionView */
    // Constraint 객체 - 세로모드
    private var pageCollectionViewPorTraitRightConstraint: NSLayoutConstraint?           // 세로모드 시, 동영상에 적용될 넓이 제약조건
    private var pageCollectionViewPorTraitBottomConstraint: NSLayoutConstraint?          // 세로모드 시, 동영상에 적용될 높이 제약조건
    private var pageCollectionViewPorTraitTopConstraint: NSLayoutConstraint?             // 세로모드 시, 동영상에 적용될 상단 제약조건
    private var pageCollectionViewPorTraitLeftConstraint: NSLayoutConstraint?            // 세로모드 시, 동영상에 적용될 좌측 제약조건

    // Constraint 객체 - 가로모드
    private var pageCollectionViewLandscapeRightConstraint: NSLayoutConstraint?           // 가로모드 시, 동영상에 적용될 넓이 제약조건
    private var pageCollectionViewLandscapeBottomConstraint: NSLayoutConstraint?          // 가로모드 시, 동영상에 적용될 높이 제약조건
    private var pageCollectionViewLandscapeTopConstraint: NSLayoutConstraint?             // 가로모드 시, 동영상에 적용될 상단 제약조건
    private var pageCollectionViewLandscapeLeftConstraint: NSLayoutConstraint?            // 가로모드 시, 동영상에 적용될 좌측 제약조건
    
    
    // Constraint 객체 - 선생님 정보 및 강의정보 View
    private var teacherInfoFoldConstraint: NSLayoutConstraint?    // 최초로드 시, 선생님정보 및 강의 정보에 적용될 제약조건
    private var teacherInfoUnfoldConstraint: NSLayoutConstraint?  // 클릭 시, 선생님정보 및 강의 정보에 적용될 제약조건
    
    
    // MARK: Video Properties
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    // 영상 ProgressView / 현재시간 ~ 종료시간 Label / 화면전환 객체 상위 Container View
    private let videoControlContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // 타임라인 timerSlider
    private var timeSlider: UISlider = {
        let slider = UISlider()
        let image = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        slider.minimumTrackTintColor = .mainOrange
        slider.setThumbImage(image, for: .normal)
        slider.value = 0.5
        return slider
    }()
    
    // ProgressView 좌측에 위치한 현재시간 레이블
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: 13)
        label.text = "0:00"
        label.textColor = .white
        return label
    }()
    
    // ProgressView 우측에 위치한 종료시간 레이블
    private let endTimeTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: 13)
        label.text = "03:00"
        label.textColor = .white
        return label
    }()
    
    // 뒤로가기버튼
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 5
        return button
    }()
    
    var playerController = AVPlayerViewController()
    var timeObserverToken: Any?
    lazy var playerItem = AVPlayerItem(url: videoUrl! as URL)
    lazy var player = AVPlayer(playerItem: playerItem)
    
    let videoUrl = NSURL(string: "https://file.gongmanse.com/access/lectures/video?access_key=NDhmYTU0ZmJiMWYyODQ2ZjFlMzEzOTRkZDE3MGYzMzZhM2FkMDRhN2Q3YTMwNGVlMWM3NzVkYWQ2NDRkNTZjZTgyNGNhZjgxOTJiZWZjYTRiMzMyNWNmZDg3YzFjNTAyZTg1ZmFhNWFkZGU0MzA3NmFkOTM4OWI5MjU0Y2I5MWNOOW84QUMwcm9FOU9lZWJaNE9YVFNGbFd0ZnhBZGRLVU00VUFpSFRVL250L1ZTMVlkelJsODgvLzFyeGVKb0hrblVzUGozNW1EdXFHTURFUi9oMXJKZzdWYXd4WG5OK3lpM05oc1kvZFk0b0h2aHhLeG5mZmR6WVJtNTdYMHpPWVg2QlJEeU5hcVpjWHpYZlJPaEJ2NEx0YXZXNm10ZlFxNXBtaGpWODNkT0F6NkhOQlNKdnJ4dVRuTXBXUytGS3NKMmxWa2l2K0dtVmVpZkZGMis4RFBxMCtrc0tFRkd3N2xSQyt3eFdFV04yRDVxbUVkUEM5eWtvSEd3Qnk0NHFJS2JHVElCTGxEckR2SGVVMjd4NERQUT09")

    // 가로방향으로 스크롤할 수 있도록 구현한 CollectionView
    var pageCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // 상단 탭바 객체 생성
    var customMenuBar = VideoMenuBar()
    
    // 선생님 정보 View 객체 생성
    
    private let topBorderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    private let bottomBorderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    private let teacherInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .progressBackgroundColor
        return view
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.backgroundColor = .mainOrange
        return button
    }()
    
    // Portrait과 Landscape로 전환 될때마다 호출되는 메소드
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            changeConstraintToVideoContainer(isPortraitMode: true)  // 세로모드
        } else {
            changeConstraintToVideoContainer(isPortraitMode: false) // 가로모드
        }
    }


    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()                    // 전반적인 UI 구현 메소드
        configureToggleButton()          // 선생님 정보 토글버튼 메소드
        playVideo()                      // 동영상 재생 메소드로 현재 테스트를 위해 이곳에 둠 04.07 추후에 인트로 영상을 호출한 이후에 이 메소드를 호출할 계획
        configureVideoControlView()      // 비디오 상태바 관련 메소드
    }


    // MARK: - Actions
    
    @objc func handleToggle() {
        print("DEBUG: clicked button")
        if teacherInfoFoldConstraint!.isActive == true {
            teacherInfoFoldConstraint!.isActive = false
            teacherInfoUnfoldConstraint!.isActive = true
        } else {
            teacherInfoFoldConstraint!.isActive = true
            teacherInfoUnfoldConstraint!.isActive = false
        }
        pageCollectionView.reloadData()
    }
    
    @objc func handleBackButtonAction() {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        player.pause()
        removePeriodicTimeObserver()
        self.dismiss(animated: true, completion: nil)
    }
    
    // 슬라이더를 이동하면 player의 값을 변경해주는 메소드(.valueChaned 시 호출되는 콜백메소드)
    @objc func timeSliderValueChanged(_ slider: UISlider) {
        let seconds: Int64 = Int64(slider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player.seek(to: targetTime)
        
        if player.rate == 0 {
            player.play()
        }
    }
    
    
    // MARK: - Helpers

    // 전반적인 UI 구현 메소드
    func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        navigationController?.hidesBarsOnSwipe = true
        
        // 세로모드 제약조건 정의
        setConstraintInPortrait()
        setupCustomTabBar()              // "노트보기", "강의 QnA" 그리고 "재생목록" 탭바 구현 메소드
        setupPageCollectionView()        // View 중단부터 하단에 있는 "노트보기", "강의 QnA" 그리고 "재생목록" 페이지 구현 메소드
        changeConstraintToVideoContainer(isPortraitMode: false) // 최초 제약조건 부여
    }
    
    func setupCustomTabBar(){
    }
    
    func customMenuBar(scrollTo index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func setupPageCollectionView(){
        pageCollectionView.isScrollEnabled = false
        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        pageCollectionView.backgroundColor = .white
        pageCollectionView.showsHorizontalScrollIndicator = false
        pageCollectionView.isPagingEnabled = true
        pageCollectionView.register(BottomNoteCell.self, forCellWithReuseIdentifier: BottomNoteCell.reusableIdentifier)
        pageCollectionView.register(BottomQnACell.self, forCellWithReuseIdentifier: BottomQnACell.reusableIdentifier)
        pageCollectionView.register(BottomPlaylistCell.self, forCellWithReuseIdentifier: BottomPlaylistCell.reusableIdentifier)
        view.addSubview(pageCollectionView)
    }
    
    func configureToggleButton() {
        view.addSubview(toggleButton)
        toggleButton.setDimensions(height: 32, width: 30)
        toggleButton.layer.cornerRadius = 8
        toggleButton.anchor(top: teacherInfoView.bottomAnchor,
                            right: teacherInfoView.rightAnchor,
                            paddingTop: -5,
                            paddingRight: 10)
        toggleButton.addTarget(self, action: #selector(handleToggle), for: .touchUpInside)
    }
    
    
    
}



//MARK:- UICollectionViewDelegate, UICollectionViewDataSource

extension VideoController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier, for: indexPath) as! BottomNoteCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomQnACell.reusableIdentifier, for: indexPath) as! BottomQnACell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomPlaylistCell.reusableIdentifier, for: indexPath) as! BottomPlaylistCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier, for: indexPath) as! BottomNoteCell
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemAt = Int(targetContentOffset.pointee.x / self.view.frame.width)
        let indexPath = IndexPath(item: itemAt, section: 0)
        customMenuBar.videoMenuBarTabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
}
//MARK:- UICollectionViewDelegateFlowLayout
extension VideoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: pageCollectionView.frame.width, height: pageCollectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



// MARK: - Video Method

extension VideoController: AVPlayerViewControllerDelegate {
    
    // View 최상단 영상 시작 메소드
    func playVideo() {
        playerController.delegate = self
        
        // 1 URL을 player에 추가한다
        let videoURL = videoUrl
        player = AVPlayer(url: videoURL! as URL)
        playerController.player = player
        self.addChild(playerController)
        
        // 2 자막 파일을 한글 인코딩을 한다
        let subtitleInKor = makeStringKoreanEncoded("https://file.gongmanse.com/uploads/videos/2017/남윤희/통분/170616_수학_초등_남윤희_067_통분.vtt")
        let subtitleURL = URL(string: subtitleInKor)
        
        // 3 playerController에 자막URL을 추가한다
        playerController.addSubtitles(controller: self).open(fileFromRemote: subtitleURL!)
        
        // 4 playController 색상 / frame / subview 추가 처리한다
        playerController.subtitleLabel?.textColor = .white
        let convertedHeight = convertHeight(231, standardView: view)
        let convertedConstant = convertHeight(65.45, standardView: view)
        
        playerController.view.setDimensions(height: convertedHeight - convertedConstant, width: view.frame.width)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.width, height: convertedHeight)
        playerController.view.contentMode = .scaleToFill
        view.addSubview(playerController.subtitleLabel!)
        //        playerController.subtitleLabel?.setDimensions(height: 40, width: view.frame.width)
        playerController.subtitleLabel?.anchor(left: videoContainerView.leftAnchor,
                                               bottom: videoContainerView.bottomAnchor,
                                               width: view.frame.width)
//        playerController.subtitleLabel?.centerX(inView: view)
        playerController.didMove(toParent: self)
        // 5 실행한다
        player.play()
        player.isMuted = false
        // Setting
        playerController.showsPlaybackControls = false  // 하단 상태표시슬라이드 display 여부
    }
    
    func configureVideoControlView() {
        
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
        backButton.addTarget(self, action: #selector(handleBackButtonAction), for: .touchUpInside)
        backButton.setDimensions(height: 20, width: 20)
        // 타임라인 timerSlider
        let convertedWidth = convertWidth(244, standardView: view)
        videoControlContainerView.addSubview(timeSlider)
        timeSlider.setDimensions(height: 5, width: convertedWidth)
        timeSlider.centerX(inView: videoControlContainerView)
        timeSlider.centerY(inView: videoControlContainerView)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged), for: .valueChanged)
    
        let duration: CMTime = playerItem.asset.duration
        let seconds: Float64 = CMTimeGetSeconds(duration)
        timeSlider.maximumValue = Float(seconds)
        timeSlider.minimumValue = 0
        timeSlider.isContinuous = true
        
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(targetViewDidTapped))
        gesture.numberOfTapsRequired = 1
        playerController.view.isUserInteractionEnabled = true
        playerController.view.addGestureRecognizer(gesture)
        
        addPeriodicTimeObserver()
    }
    
    @objc func targetViewDidTapped() {
        if videoControlContainerView.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.videoControlContainerView.alpha = 0
            }
            
        } else {
            UIView.animate(withDuration: 0.3) {
                self.videoControlContainerView.alpha = 1
            }
        }
    }
    
    func addPeriodicTimeObserver() {
        
        
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                          queue: .main) {
            [weak self] time in
            // update player transport UI
            self?.timeSlider.value = Float(time.seconds)

        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
}

// MARK: - Constraint Method

extension VideoController {
    // 세로모드 제약조건 정의
    func setConstraintInPortrait() {
        // 길이 환산: 제플린 값 -> View 값
        let videoContainerViewHeight = convertHeight(231, standardView: view)
        let convertedConstant = convertHeight(65.45, standardView: view)
        
        /* VideoContainerView */
        view.addSubview(videoContainerView)
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        // Portrait 제약조건 정의
        videoContainerViewPorTraitWidthConstraint = videoContainerView.widthAnchor.constraint(equalToConstant: view.frame.width)
        videoContainerViewPorTraitHeightConstraint = videoContainerView.heightAnchor.constraint(equalToConstant: videoContainerViewHeight - convertedConstant)
        videoContainerViewPorTraitTopConstraint = videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        videoContainerViewPorTraitLeftConstraint = videoContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        // Landscape 제약조건 정의
        videoContainerViewLandscapeWidthConstraint = videoContainerView.widthAnchor.constraint(equalToConstant: view.frame.width)
        videoContainerViewLandscapeHeightConstraint = videoContainerView.heightAnchor.constraint(equalToConstant: videoContainerViewHeight - convertedConstant)
        videoContainerViewLandscapeTopConstraint = videoContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        videoContainerViewLandscapeLeftConstraint = videoContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        
        /* CustomTabBar */
        view.addSubview(customMenuBar)
        customMenuBar.delegate = self
        customMenuBar.translatesAutoresizingMaskIntoConstraints = false
        // Portrait 제약조건 정의
        customMenuBarPorTraitLeftConstraint = customMenuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        customMenuBarPorTraitRightConstraint = customMenuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        customMenuBarPorTraitTopConstraint = customMenuBar.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        customMenuBarPorTraitHeightConstraint = customMenuBar.heightAnchor.constraint(equalToConstant: view.frame.height * 0.06)
        // Landscape 제약조건 정의
        customMenuBarLandscapeTopConstraint = customMenuBar.topAnchor.constraint(equalTo: view.topAnchor)
        customMenuBarLandscapeRightConstraint = customMenuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        customMenuBarLandscapeLeftConstraint = customMenuBar.leadingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        customMenuBarLandscapeHeightConstraint = customMenuBar.heightAnchor.constraint(equalToConstant: view.frame.height * 0.06)
        
        /* TeacherInfoView */
        view.addSubview(teacherInfoView)
        teacherInfoView.translatesAutoresizingMaskIntoConstraints = false
        teacherInfoFoldConstraint?.priority = UILayoutPriority(rawValue: 999)
        teacherInfoUnfoldConstraint?.priority = UILayoutPriority(rawValue: 999)
        teacherInfoFoldConstraint = teacherInfoView.heightAnchor.constraint(equalToConstant: 5)
        teacherInfoUnfoldConstraint = teacherInfoView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.28)
        // Portrait 제약조건 정의
        teacherInfoViewPorTraitTopConstraint = teacherInfoView.topAnchor.constraint(equalTo: customMenuBar.bottomAnchor)
        teacherInfoViewPorTraitCenterXConstraint = teacherInfoView.centerXAnchor.constraint(equalTo: customMenuBar.centerXAnchor)
        teacherInfoViewPorTraitWidthConstraint = teacherInfoView.widthAnchor.constraint(equalTo: view.widthAnchor)
        // Landscape 제약조건 정의
        teacherInfoViewLandscapeTopConstraint = teacherInfoView.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        teacherInfoViewLandscapeLeftConstraint = teacherInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        teacherInfoViewLandscapeRightConstraint = teacherInfoView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        
        /* TeacherInfoView (top/bottom)BorderLine */
        teacherInfoView.addSubview(topBorderLine)
        teacherInfoView.addSubview(bottomBorderLine)
        topBorderLine.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderLine.translatesAutoresizingMaskIntoConstraints = false
        topBorderLinePorTraitTopConstraint = topBorderLine.topAnchor.constraint(equalTo: teacherInfoView.topAnchor)
        topBorderLinePorTraitCenterXConstraint = topBorderLine.centerXAnchor.constraint(equalTo: teacherInfoView.centerXAnchor)
        topBorderLinePorTraitHeightConstraint = topBorderLine.heightAnchor.constraint(equalToConstant: 5)
        topBorderLinePorTraitWidthConstraint = topBorderLine.widthAnchor.constraint(equalTo: teacherInfoView.widthAnchor)
        bottomBorderLinePorTraitBottomConstraint = bottomBorderLine.bottomAnchor.constraint(equalTo: teacherInfoView.bottomAnchor)
        bottomBorderLinePorTraitCenterXConstraint = bottomBorderLine.centerXAnchor.constraint(equalTo: teacherInfoView.centerXAnchor)
        bottomBorderLinePorTraitHeightConstraint = bottomBorderLine.heightAnchor.constraint(equalToConstant: 5)
        bottomBorderLinePorTraitWidthConstraint = bottomBorderLine.widthAnchor.constraint(equalTo: teacherInfoView.widthAnchor)
        
        
    
        /* pageCollectionView */
        // Portrait 제약조건 정의
        pageCollectionViewPorTraitLeftConstraint = pageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        pageCollectionViewPorTraitRightConstraint = pageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        pageCollectionViewPorTraitBottomConstraint = pageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        pageCollectionViewPorTraitTopConstraint = pageCollectionView.topAnchor.constraint(equalTo: teacherInfoView.bottomAnchor)
        // Landscape 제약조건 정의
        pageCollectionViewLandscapeLeftConstraint = pageCollectionView.leadingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        pageCollectionViewLandscapeRightConstraint = pageCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width)
        pageCollectionViewLandscapeBottomConstraint = pageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        pageCollectionViewLandscapeTopConstraint = pageCollectionView.topAnchor.constraint(equalTo: customMenuBar.bottomAnchor)
        
        /* playerController View */
        self.videoContainerView.addSubview(playerController.view)
        playerController.view.anchor(top: videoContainerView.topAnchor, left: videoContainerView.leftAnchor)
    }
    
    
    //  화면전환에 따른 Constraint 적용
    func changeConstraintToVideoContainer(isPortraitMode: Bool) {
        if !isPortraitMode { // 세로모드인 경우
            print("DEBUG: 세로모드")
            portraitConstraint(true)
            landscapeConstraint(false)
        } else {            // 가로모드인 경우
            print("DEBUG: 가로모드")
            portraitConstraint(false)
            landscapeConstraint(true)
        }
    }
    
    // Portait 제약조건 활성화 메소드
    func portraitConstraint(_ isActive: Bool) {
        pageCollectionView.reloadData()
        // "videoContainerView" 제약조건
        videoContainerViewPorTraitWidthConstraint?.isActive = isActive
        videoContainerViewPorTraitHeightConstraint?.isActive = isActive
        videoContainerViewPorTraitTopConstraint?.isActive = isActive
        videoContainerViewPorTraitLeftConstraint?.isActive = isActive
        // "customTabBar" 제약조건
        customMenuBarPorTraitLeftConstraint?.isActive = isActive
        customMenuBarPorTraitRightConstraint?.isActive = isActive
        customMenuBarPorTraitTopConstraint?.isActive = isActive
        customMenuBarPorTraitHeightConstraint?.isActive = isActive
        
        // "teacherInfoView" 제약조건
        teacherInfoViewPorTraitTopConstraint?.isActive = isActive
        teacherInfoViewPorTraitCenterXConstraint?.isActive = isActive
        teacherInfoViewPorTraitWidthConstraint?.isActive = isActive
        teacherInfoUnfoldConstraint?.isActive = !isActive
        teacherInfoFoldConstraint?.isActive = isActive
        
        // "topBorderLine" 제약조건
        // "bottomBorderLine" 제약조건
        topBorderLinePorTraitTopConstraint?.isActive = isActive
        topBorderLinePorTraitCenterXConstraint?.isActive = isActive
        topBorderLinePorTraitHeightConstraint?.isActive = isActive
        topBorderLinePorTraitWidthConstraint?.isActive = isActive
        bottomBorderLinePorTraitBottomConstraint?.isActive = isActive
        bottomBorderLinePorTraitCenterXConstraint?.isActive = isActive
        bottomBorderLinePorTraitHeightConstraint?.isActive = isActive
        bottomBorderLinePorTraitWidthConstraint?.isActive = isActive
        
        
        
        
        
        // "pageCollectionView" 제약조건
        pageCollectionViewPorTraitLeftConstraint?.isActive = isActive
        pageCollectionViewPorTraitRightConstraint?.isActive = isActive
        pageCollectionViewPorTraitBottomConstraint?.isActive = isActive
        pageCollectionViewPorTraitTopConstraint?.isActive = isActive
        
        
    }
    
    // Landscape 제약조건 활성화 메소드
    func landscapeConstraint(_ isActive: Bool) {
        pageCollectionView.reloadData()
        videoContainerViewLandscapeWidthConstraint?.isActive = isActive
        videoContainerViewLandscapeHeightConstraint?.isActive = isActive
        videoContainerViewLandscapeTopConstraint?.isActive = isActive
        videoContainerViewLandscapeLeftConstraint?.isActive = isActive
        // "customTabBar" 제약조건
        customMenuBarLandscapeRightConstraint?.isActive = isActive
        customMenuBarLandscapeTopConstraint?.isActive = isActive
        customMenuBarLandscapeLeftConstraint?.isActive = isActive
        customMenuBarLandscapeHeightConstraint?.isActive = isActive
        // "teacherInfoView" 제약조건
        teacherInfoUnfoldConstraint?.isActive = isActive
        teacherInfoFoldConstraint?.isActive = !isActive
        teacherInfoViewLandscapeTopConstraint?.isActive = isActive
        teacherInfoViewLandscapeLeftConstraint?.isActive = isActive
        teacherInfoViewLandscapeRightConstraint?.isActive = isActive
        // TODO: ToggleButton 제약조건
        
        // "pageCollectionView" 제약조건
        pageCollectionViewLandscapeLeftConstraint?.isActive = isActive
        pageCollectionViewLandscapeRightConstraint?.isActive = isActive
        pageCollectionViewLandscapeBottomConstraint?.isActive = isActive
        pageCollectionViewLandscapeTopConstraint?.isActive = isActive
        
        
        
        // TODO: "TeachInfoView" 제약조건
        // TODO: "CollectionView" 제약조건
    }
}
