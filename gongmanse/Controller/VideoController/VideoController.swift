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
    
    var id: String?
    
    /* VideoContainterView */
    // Constraint 객체 - 세로모드
    var videoContainerViewPorTraitWidthConstraint: NSLayoutConstraint?
    var videoContainerViewPorTraitHeightConstraint: NSLayoutConstraint?
    var videoContainerViewPorTraitTopConstraint: NSLayoutConstraint?
    var videoContainerViewPorTraitLeftConstraint: NSLayoutConstraint?
    
    // Constraint 객체 - 가로모드
    var videoContainerViewLandscapeWidthConstraint: NSLayoutConstraint?
    var videoContainerViewLandscapeHeightConstraint: NSLayoutConstraint?
    var videoContainerViewLandscapeTopConstraint: NSLayoutConstraint?
    var videoContainerViewLandscapeLeftConstraint: NSLayoutConstraint?
    
    /* CustomTabBar */
    // Constraint 객체 - 세로모드
    var customMenuBarPorTraitHeightConstraint: NSLayoutConstraint?
    var customMenuBarPorTraitTopConstraint: NSLayoutConstraint?
    var customMenuBarPorTraitLeftConstraint: NSLayoutConstraint?
    var customMenuBarPorTraitRightConstraint: NSLayoutConstraint?
    var customMenuBarPorTraitWidthConstraint: NSLayoutConstraint?
    
    // Constraint 객체 - 가로모드
    var customMenuBarLandscapeRightConstraint: NSLayoutConstraint?
    var customMenuBarLandscapeHeightConstraint: NSLayoutConstraint?
    var customMenuBarLandscapeTopConstraint: NSLayoutConstraint?
    var customMenuBarLandscapeLeftConstraint: NSLayoutConstraint?
    var customMenuBarLandscapeWidthConstraint: NSLayoutConstraint?
    
    /* teacherInfoView */
    // Constraint 객체 - 세로모드
    var teacherInfoViewPorTraitCenterXConstraint: NSLayoutConstraint?
    var teacherInfoViewPorTraitHeightConstraint: NSLayoutConstraint?
    var teacherInfoViewPorTraitTopConstraint: NSLayoutConstraint?
    var teacherInfoViewPorTraitWidthConstraint: NSLayoutConstraint?
    
    // Constraint 객체 - 가로모드
    var teacherInfoViewLandscapeRightConstraint: NSLayoutConstraint?
    var teacherInfoViewLandscapeHeightConstraint: NSLayoutConstraint?
    var teacherInfoViewLandscapeTopConstraint: NSLayoutConstraint?
    var teacherInfoViewLandscapeLeftConstraint: NSLayoutConstraint?
    
    /* topBorderLine */
    // Constraint 객체 - 세로모드
    var topBorderLinePorTraitCenterXConstraint: NSLayoutConstraint?
    var topBorderLinePorTraitHeightConstraint: NSLayoutConstraint?
    var topBorderLinePorTraitTopConstraint: NSLayoutConstraint?
    var topBorderLinePorTraitWidthConstraint: NSLayoutConstraint?
    
    /* bottomBorderLine */
    // Constraint 객체 - 세로모드
    var bottomBorderLinePorTraitCenterXConstraint: NSLayoutConstraint?
    var bottomBorderLinePorTraitHeightConstraint: NSLayoutConstraint?
    var bottomBorderLinePorTraitBottomConstraint: NSLayoutConstraint?
    var bottomBorderLinePorTraitWidthConstraint: NSLayoutConstraint?
    
    
    /* pageCollectionView */
    // Constraint 객체 - 세로모드
    var pageCollectionViewPorTraitRightConstraint: NSLayoutConstraint?
    var pageCollectionViewPorTraitBottomConstraint: NSLayoutConstraint?
    var pageCollectionViewPorTraitTopConstraint: NSLayoutConstraint?
    var pageCollectionViewPorTraitLeftConstraint: NSLayoutConstraint?
    
    // Constraint 객체 - 가로모드
    var pageCollectionViewLandscapeRightConstraint: NSLayoutConstraint?
    var pageCollectionViewLandscapeBottomConstraint: NSLayoutConstraint?
    var pageCollectionViewLandscapeTopConstraint: NSLayoutConstraint?
    var pageCollectionViewLandscapeLeftConstraint: NSLayoutConstraint?
    
    /* Constraint 객체 - 선생님 정보 및 강의정보 View */
    /// 최초로드 시, 선생님정보 및 강의 정보에 적용될 제약조건
    var teacherInfoFoldConstraint: NSLayoutConstraint?
    /// 클릭 시, 선생님정보 및 강의 정보에 적용될 제약조건
    var teacherInfoUnfoldConstraint: NSLayoutConstraint?
    
    // MARK: Video Properties
    
    /// AVPlayerController를 담을 UIView
    let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    /// 영상 ProgressView / 현재시간 ~ 종료시간 Label / 화면전환 객체 상위 Container View
    let videoControlContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: Video Player Control Button
    /// 재생 및 일시정지 버튼
    let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "play.circle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(playPausePlayer), for: .touchUpInside)
        return button
    }()
    
    /// 동영상 앞으로 가기
    let videoForwardTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "goforward.10")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(moveForwardPlayer), for: .touchUpInside)
        return button
    }()
    
    /// 동영상 뒤로 가기
    let videoBackwardTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "gobackward.10")?.withRenderingMode(.alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(moveBackwardPlayer), for: .touchUpInside)
        return button
    }()
    
    /// 타임라인 timerSlider
    var timeSlider: UISlider = {
        let slider = UISlider()
        let image = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        slider.minimumTrackTintColor = .mainOrange
        slider.setThumbImage(image, for: .normal)
        slider.value = 1
        return slider
    }()
    
    /// ProgressView 좌측에 위치한 현재시간 레이블
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: 11)
        label.text = "0:00"
        label.textColor = .white
        return label
    }()
    
    /// ProgressView 우측에 위치한 종료시간 레이블
    let endTimeTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: 11)
        label.text = "03:00"
        label.textColor = .white
        return label
    }()
    
    /// 가로화면(전체화면)으로 전환되는 버튼
    let changeOrientationButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "rectangle.lefthalf.inset.fill.arrow.left")?
            .withRenderingMode(.alwaysOriginal)
        button.addTarget(self, action: #selector(handleOrientation), for: .touchUpInside)
        button.setImage(image, for: .normal)
        return button
    }()
    
    let subtitleToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "textbox")?
            .withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleSubtitleToggle), for: .touchUpInside)
        return button
    }()
    
    var isClickedSubtitleToggleButton: Bool = false
    
    let videoSettingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "slider.horizontal.3")?
            .withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleSettingButton), for: .touchUpInside)
        return button
    }()
    
    /// 뒤로가기버튼
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        button.tintColor = .lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 5
        return button
    }()
    
    // AVPlayer 관련 프로퍼티
    var playerController = AVPlayerViewController()
    var timeObserverToken: Any?
    lazy var playerItem = AVPlayerItem(url: videoURL! as URL)
    lazy var player = AVPlayer(playerItem: playerItem)
    var videoURL = NSURL(string: "")
    var vttURL = ""
    var sTagsArray = [String]()
    var tempsTagsArray = [String]()
    
    
    /// AVPlayer 자막역햘을 할 UILabel
    var subtitleLabel: UILabel = {
        let label = UILabel()
        let backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.backgroundColor = backgroundColor
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "default setting..."
        return label
    }()
    
    /// 자막 기능을 담고 있는 자막 인스턴스(subtitleTextLabel에 text를 넣어줌)
    lazy var subtitles = Subtitles(subtitles: "")
    
    /// 자막을 클릭 했을 때, 제스쳐로 인지할 제스쳐 인스턴스
    lazy var gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedSubtitle))
    
    /// 가로방향으로 스크롤할 수 있도록 구현한 CollectionView
    var pageCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    /// 상단 탭바 객체 생성
    var customMenuBar = VideoMenuBar()
    
    /// tearchInfoView의 상단 오랜지색 구분선
    let topBorderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    /// tearchInfoView의 하단 오랜지색 구분선
    let bottomBorderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    /// 강의 및 선생님 정보를 담을 뷰
    let teacherInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .progressBackgroundColor
        return view
    }()
    
    /// "teachInfoView" 하단에 토글 기능을 담당할 UIButton
    let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.backgroundColor = .mainOrange
        return button
    }()
    
    var isPlaying: Bool {
        player.rate != 0 && player.error == nil
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataAndNoti()
        configureUI()                    // 전반적인 UI 구현 메소드
        configureToggleButton()          // 선생님 정보 토글버튼 메소드
        configureVideoControlView()      // 비디오 상태바 관련 메소드
    }
    
    // MARK: - Actions
    
    // sTag 텍스트 내용을 클릭했을 때, 이곳에 해당 텍스트의 NSRange가 저장된다.
    /// sTags로 가져온 keyword의 NSRange 정보를 담은 array
    var keywordRanges: [NSRange] = []
    /// sTags로 가져온 keyword의 Range\<Int> 정보를 담은 array
    var sTagsRanges = [Range<Int>]()
    /// 현재 자막에 있는 keyword Array
    var currentKeywords = ["", "", "", "", "", "", "", "", "", "", "", ""]
    
    /// "subtitleLabel"을 클릭 시, 호출될 콜백메소드
    @objc func didTappedSubtitle(sender: UITapGestureRecognizer) {
        
        // "subtitleLabel"을 클릭할 때만 호출되도록 한다.
        sender.numberOfTapsRequired = 1
        
        // 데이터 정상적으로 저장되었는지 확인하기 위한 Print
        print("DEBUG: 0Rangs is \(keywordRanges[0])")
        print("DEBUG: 1Rangs is \(keywordRanges[1])")
        print("DEBUG: 2Rangs is \(keywordRanges[2])")
        print("DEBUG: 3Rangs is \(keywordRanges[3])")
        print("DEBUG: 4Rangs is \(keywordRanges[4])")
        print("DEBUG: 5Rangs is \(keywordRanges[5])")
        print("DEBUG: 6Rangs is \(keywordRanges[6])")
        print("DEBUG: 7Rangs is \(keywordRanges[7])")
        
        /// 클릭한 위치와 subtitle의 keyword의 Range를 비교
        /// - keyword Range 내 subtitle 클릭 위치가 있다면, true
        /// - keyword Range 내 subtitle 클릭 위치가 없다면, false
        if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[0] ) {
            print("DEBUG: 지금 sTag가 1 개입니까?")
            let vc = TestSearchController(clickedText: currentKeywords[0])
            present(vc, animated: true)
            
        } else if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[2]) {
            print("DEBUG: \(currentKeywords[2])?")
            let vc = TestSearchController(clickedText: currentKeywords[2])
            present(vc, animated: true)
            
        } else if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[4]) {
            print("DEBUG: \(currentKeywords[4])?")
            let vc = TestSearchController(clickedText: currentKeywords[4])
            present(vc, animated: true)
            
        } else {
            print("DEBUG: 키워드가 없나요?")
        }
    }
    
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
    
    /// 우측상단에 뒤로가기 버튼 로직
    @objc func handleBackButtonAction() {
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        player.pause()
        NotificationCenter.default.removeObserver(self)
        //        removePeriodicTimeObserver()
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
        
        let playImage = UIImage(systemName: "play.circle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let pauseImage = UIImage(systemName: "pause.circle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
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
    
    /// 알림 호출 시, 호출될 콜백메소드
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        
        player.seek(to: CMTime.zero)
        player.pause()
    }
    
    /// Portrait과 Landscape로 전환 될때마다 호출되는 메소드
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        
        // 화면 회전 시, 강제로 "노트보기" Cell로 이동하도록 한다.
        pageCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                        at: UICollectionView.ScrollPosition.left,
                                        animated: true)
        super.viewWillTransition(to: size, with: coordinator)
        
        /// true == 가로모드, false == 세로모드
        if UIDevice.current.orientation.isLandscape {
            changeConstraintToVideoContainer(isPortraitMode: true)
            
        } else {
            changeConstraintToVideoContainer(isPortraitMode: false)
        }
    }
    
    /// 화면 Orientation 변경 버튼 호출시, 호출되는 콜백메소드
    @objc func handleOrientation() {
        
        // 화면 회전 시, 강제로 "노트보기" Cell로 이동하도록 한다.
        pageCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                        at: UICollectionView.ScrollPosition.left,
                                        animated: true)
        
        let landscapeLeftValue = UIInterfaceOrientation.landscapeLeft.rawValue
        let portraitValue = UIInterfaceOrientation.portrait.rawValue
        
        if UIDevice.current.orientation.rawValue == landscapeLeftValue {
            UIDevice.current.setValue(portraitValue, forKey: "orientation")
        } else {
            UIDevice.current.setValue(landscapeLeftValue, forKey: "orientation")
        }
    }
    
    @objc func handleSubtitleToggle() {
        
        if self.isClickedSubtitleToggleButton {
            self.isClickedSubtitleToggleButton = false
            UIView.animate(withDuration: 0.22) {
                self.subtitleLabel.alpha = 1
            }
            
        } else {
            self.isClickedSubtitleToggleButton = true
            UIView.animate(withDuration: 0.22) {
                self.subtitleLabel.alpha = 0
            }
            
        }
    }
    
    /// 클릭 시, 속도가 1.25배 빨라지는 메소드 (추후 변경 예정)
    @objc func handleSettingButton() {
        player.playImmediately(atRate: 1.25)
    }
    
    // MARK: - Helpers
    
    /// 데이터 구성을 위한 메소드
    func configureDataAndNoti() {
        
        // 관찰자를 추가한다.
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
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
        toggleButton.anchor(top: teacherInfoView.bottomAnchor,
                            right: teacherInfoView.rightAnchor,
                            paddingTop: -5,
                            paddingRight: 10)
        toggleButton.addTarget(self, action: #selector(handleToggle), for: .touchUpInside)
    }
}


//MARK:- UICollectionViewDelegate, UICollectionViewDataSource

extension VideoController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier,for: indexPath) as! BottomNoteCell
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomQnACell.reusableIdentifier, for: indexPath) as! BottomQnACell
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomPlaylistCell.reusableIdentifier, for: indexPath) as! BottomPlaylistCell
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier,for: indexPath) as! BottomNoteCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemAt = Int(targetContentOffset.pointee.x / self.view.frame.width)
        let indexPath = IndexPath(item: itemAt, section: 0)
        customMenuBar.videoMenuBarTabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout

extension VideoController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: pageCollectionView.frame.width, height: pageCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


// MARK: - Video Method

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
        player.isMuted = false
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
        backButton.addTarget(self, action: #selector(handleBackButtonAction),
                             for: .touchUpInside)
        backButton.alpha = 0.77
        backButton.setDimensions(height: 20, width: 20)
        
        // 타임라인 timerSlider
        let convertedWidth = convertWidth(244, standardView: view)
        videoControlContainerView.addSubview(timeSlider)
        timeSlider.setDimensions(height: 5, width: convertedWidth - 32)
        timeSlider.centerX(inView: videoControlContainerView)
        timeSlider.centerY(inView: videoControlContainerView)
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
        
        
        
        
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                    action: #selector(targetViewDidTapped))
        gesture.numberOfTapsRequired = 1
        playerController.view.isUserInteractionEnabled = true
        playerController.view.addGestureRecognizer(gesture)
    }
    
    /// 동영상 클릭 시, 동영상 조절버튼을 사라지도록 하는 메소드
    @objc func targetViewDidTapped() {
        
        if videoControlContainerView.alpha == 1 {
            UIView.animate(withDuration: 0.3) {
                self.videoControlContainerView.alpha = 0
                self.playPauseButton.alpha = 0
                self.videoForwardTimeButton.alpha = 0
                self.videoBackwardTimeButton.alpha = 0
                self.videoSettingButton.alpha = 0
                self.subtitleToggleButton.alpha = 0
            }
            
        } else {
            UIView.animate(withDuration: 0.3) {
                self.videoControlContainerView.alpha = 1
                self.playPauseButton.alpha = 1
                self.videoForwardTimeButton.alpha = 1
                self.videoBackwardTimeButton.alpha = 1
                self.videoSettingButton.alpha = 1
                self.subtitleToggleButton.alpha = 1
            }
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
}

// MARK: - API

extension VideoController {
    
    func didSucceedNetworking(response: DetailVideoResponse) {
        
        // source_url -> VideoURL
        if let sourceURL = response.data.source_url {
            self.videoURL = URL(string: sourceURL) as NSURL?
        }
        
        // sSubtitles -> vttURL
        self.vttURL =  "https://file.gongmanse.com/" + response.data.sSubtitle
        
        // sTags -> sTagsArray
        let receivedsTagsData = response.data.sTags
        let sTagsArray = receivedsTagsData.split(separator: ",")
        
        // 이전에 sTags 값이 있을 수 있으므로 값을 제거한다.
        self.sTagsArray.removeAll()
        
        // "sTagsArray"는 String.Sequence이므로 String으로 캐스팅한 후, 값을 할당한다.
        for index in 0 ... sTagsArray.count - 1 {
            let inputData = String(sTagsArray[index])
            self.tempsTagsArray.append(inputData)
        }
        playVideo()
    }
}



