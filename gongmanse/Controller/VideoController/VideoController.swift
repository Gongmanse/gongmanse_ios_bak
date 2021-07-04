/*
 "영상" 페이지 전체를 컨트롤하는 Controller 입니다.
 * 상단 탭바를 담당하는 객체: VideoMenuBar
 * 상단 탭바의 각각의 항목을 담당하는 객체: TabBarCell 폴더 내부 객체
 * 하단 "노트보기", "강의 QnA" 그리고 "재생목록"을 담당하는 객체: BottomCell 폴더 내부 객체
 */
import AVKit
import Foundation
import UIKit

/**
 PIP 관련 데이터를 관리하는 싱글톤 객체입니다.
 - 이전 영상에 대한 ID와 URL을 저장합니다.
   이를 통해, PIP에 이전 영상의 데이터를 보여줍니다.
 - 현재 영상 ID 데이터를 저장합니다. 이후, 이전영상 데이터ID에 입력합니다.
 */
class PIPDataManager {
    static let shared = PIPDataManager()
    
    var isPlayPIP: Bool = true
    
    var previousVideoURL: NSURL?
    var currentVideoURL: NSURL?
    
    var previousVideoID: String?
    var currentVideoID: String?
    
    var previousVideoTitle: String? = "클린코드"
    var currentVideoTitle: String? = "클린코드"
    
    var previousTeacherName: String? = "김우성"
    var currentTeacherName: String? = "김우성2"

    var noteViewController: LectureNoteController?
    
    /// videoController가 처음으로 호출되었는지 판단하는 연산 프로퍼티
    /// - ture  : 처음으로 호출 된 경우
    /// - false : 처음아 아닌 경우
    var isDisplayVideoFirstTime: Bool {
        return self.previousVideoID == nil
    }
    
    /// 다음화면으로 넘어갈 때, PIPVC에서 Float -> CMTime으로 변환해주므로 Float로 받아습니다.
    var currentVideoTime: Float? = 0.0 // 다음화면으로 넘어갈 때 사용
    
    /// "AVPlayer.seek" 파라미터가 CMTIME이므로 바로 접근하기 위해 변수를 2개로 만들었습니다.
    var currentVideoCMTime: CMTime? = CMTime() // 이전화면으로 돌아올 때 사용
    
    private init() {} // 싱글톤 인스턴스 2 개 생성 방지하기 위해 "private"으로 작성했습니다.
}

protocol VideoControllerDelegate: AnyObject {
    func recommandVCPresentVideoVC()
}

class VideoController: UIViewController, VideoMenuBarDelegate {
    // MARK: - Properties
    
    // video 영상 데이터 및 PIP 재생에 관련된 데이터를 관리하는 싱글톤 객체를 생성한다.
    let videoDataManager = VideoDataManager.shared
    
    weak var delegate: VideoControllerDelegate?
    
    /**
      PIP 창이 나와야하는 경우
      - 영상 > 키워드 클릭 > 검색화면 으로 화면을 이동했을 경우
      - 영상 > 관련시리즈 로 화면을 이동했을 경우
      두 가지 경우이다. 그러면 "VideoController" 에서 영상 PIP 객체를 생성하는 것이 아닌,
     "상세검색화면" 과 "관련 시리즈" 에서 PIP 객체를 가지고 있다가 실행시켜주면 된다.
      이를 구현하기 위한 객체로 PIP를 켜야할지 말아야할 지알려주는 변수이다.
      */
    var isDisplayPIP: Bool = true
    var teachername: String?
    var lessonname: String?
    
    var pipData: PIPVideoData?

    var currentVideoPlayRate = Float(1.0) {
        didSet {
            self.player.playImmediately(atRate: self.currentVideoPlayRate)
        }
    }
    
    var videoPlaylistVC: VideoPlaylistVC?
    
    var id: String?
    var seriesID: String?
        
    // 추천
    var recommendSeriesId: String?
    var recommendReceiveData: VideoInput?
    
    // 인기
    var popularSeriesId: String?
    var popularReceiveData: VideoInput?
    var popularViewTitle: String?
    
    // 국영수
    var koreanSeriesId: String?
    var koreanSwitchValue: UISwitch?
    var koreanReceiveData: VideoInput?
    var koreanSelectedBtn: UIButton?
    var koreanViewTitle: String?
    
    // 과학
    var scienceSeriesId: String?
    var scienceSwitchValue: UISwitch?
    var scienceReceiveData: VideoInput?
    var scienceSelectedBtn: UIButton?
    var scienceViewTitle: String?
    
    // 사회
    var socialStudiesSeriesId: String?
    var socialStudiesSwitchValue: UISwitch?
    var socialStudiesReceiveData: VideoInput?
    var socialStudiesSelectedBtn: UIButton?
    var socialStudiesViewTitle: String?
    
    // 기타
    var otherSubjectsSeriesId: String?
    var otherSubjectsSwitchValue: UISwitch?
    var otherSubjectsReceiveData: VideoInput?
    var otherSubjectsSelectedBtn: UIButton?
    var otherSubjectsViewTitle: String?
    
    var videoAndVttURL = VideoURL(videoURL: NSURL(string: ""), vttURL: "")
    lazy var lessonInfoController = LessonInfoController(videoID: id)
    
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
    
    /* lessonInfoView */
    // Constraint 객체 - 세로모드
    var lessonInfoViewPorTraitCenterXConstraint: NSLayoutConstraint?
    var lessonInfoViewPorTraitHeightConstraint: NSLayoutConstraint?
    var lessonInfoViewPorTraitTopConstraint: NSLayoutConstraint?
    var lessonInfoViewPorTraitWidthConstraint: NSLayoutConstraint?
    
    // Constraint 객체 - 가로모드
    var lessonInfoViewLandscapeRightConstraint: NSLayoutConstraint?
    var lessonInfoViewLandscapeHeightConstraint: NSLayoutConstraint?
    var lessonInfoViewLandscapeTopConstraint: NSLayoutConstraint?
    var lessonInfoViewLandscapeLeftConstraint: NSLayoutConstraint?
    
    /* topBorderLine */
    // Constraint 객체 - 세로모드
    var topBorderLinePorTraitCenterXConstraint: NSLayoutConstraint?
    var topBorderLinePorTraitHeightConstraint: NSLayoutConstraint?
    var topBorderLinePorTraitTopConstraint: NSLayoutConstraint?
    var topBorderLinePorTraitWidthConstraint: NSLayoutConstraint?
    
    // Constraint 객체 - 가로모드
    var topBorderLineLandScapeCenterXConstraint: NSLayoutConstraint?
    var topBorderLineLandScapeHeightConstraint: NSLayoutConstraint?
    var topBorderLineLandScapeTopConstraint: NSLayoutConstraint?
    var topBorderLineLandScapeWidthConstraint: NSLayoutConstraint?
    
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
    
    // 유사 PIP모드 Constraint
    var pipViewHeightConstraint: NSLayoutConstraint?
    
    /* Constraint 객체 - 선생님 정보 및 강의정보 View */
    /// 최초로드 시, 선생님정보 및 강의 정보에 적용될 제약조건
    var teacherInfoFoldConstraint: NSLayoutConstraint?
    /// 클릭 시, 선생님정보 및 강의 정보에 적용될 제약조건
    var teacherInfoUnfoldConstraint: NSLayoutConstraint?
    
    // MARK: Video Properties
    
    // MARK: PIP

    // 유사 PIP 기능을 위한 ContainerView
    let pipContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
        
    /* PIPView */
    private let lessonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DEFAULT"
        label.font = UIFont.appBoldFontWith(size: 13)
        label.textColor = .black
        return label
    }()
    
    private let teachernameLabel: UILabel = {
        let label = UILabel()
        label.text = "DEFAULT"
        label.font = UIFont.appBoldFontWith(size: 11)
        label.textColor = .gray
        return label
    }()
    
    private var isPlayPIPVideo: Bool = true
    private let pipPlayPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .black
//        button.addTarget(self, action: #selector(playPauseButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let xButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(xButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    /// AVPlayerController를 담을 UIView
    let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    let blackViewOncontrolMode: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.45
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
        let pauseImage = UIImage(named: "영상일시정지버튼")
        button.setBackgroundImage(pauseImage, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(playPausePlayer), for: .touchUpInside)
        return button
    }()
    
    /// 동영상 앞으로 가기
    let videoForwardTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "앞으로가기버튼")
        button.setImage(image, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(moveForwardPlayer), for: .touchUpInside)
        return button
    }()
    
    /// 동영상 뒤로 가기
    let videoBackwardTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "뒤로가기버튼")
        button.setImage(image, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(moveBackwardPlayer), for: .touchUpInside)
        return button
    }()
    
    /// 타임라인 timerSlider
    var timeSlider: CustomSlider = {
        let slider = CustomSlider()
        let image = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        slider.minimumTrackTintColor = .mainOrange
        slider.maximumTrackTintColor = .white
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
        let image = UIImage(named: "전체화면버튼")
        button.addTarget(self, action: #selector(presentFullScreenMode), for: .touchUpInside)
        button.setImage(image, for: .normal)
        return button
    }()
    
    let subtitleToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "smallCaptionOn")
        button.setImage(image, for: .normal)
        button.tintColor = .mainOrange
        button.addTarget(self, action: #selector(handleSubtitleToggle), for: .touchUpInside)
        return button
    }()
    
    var isClickedSubtitleToggleButton: Bool = true {
        didSet {
            if self.isClickedSubtitleToggleButton {
                self.subtitleLabel.alpha = 1
            } else {
                self.subtitleLabel.alpha = 0
            }
        }
    }
    
    let videoSettingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "동영상설정버튼")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleSettingButton), for: .touchUpInside)
        button.alpha = 1
        return button
    }()
    
    /// 뒤로가기버튼
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "동영상뒤로가기버튼"), for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 5
        return button
    }()
    
    // AVPlayer 관련 프로퍼티
    var playerController = AVPlayerViewController()
    var timeObserverToken: Any?
//    lazy var playerItem = AVPlayerItem(url: videoURL! as URL)
    var playerItem: AVPlayerItem?
//    lazy var queuePlayerItem = AVQueuePlayer(items: [playerItem])
    
    lazy var player = AVPlayer(playerItem: playerItem)
    var videoURL = NSURL(string: "")
    var vttURL = ""
    var sTagsArray = [String]()
    var tempsTagsArray = [String]()
    
    // MARK: Refactoring

    var asset: AVAsset?
    
    /// AVPlayer 자막역햘을 할 UILabel
    var subtitleLabel: UILabel = {
        let label = UILabel()
        let backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.backgroundColor = backgroundColor
        label.font = UIFont.appBoldFontWith(size: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "default setting..."
        return label
    }()
    
    /// 자막 기능을 담고 있는 자막 인스턴스(subtitleTextLabel에 text를 넣어줌)
    lazy var subtitles = Subtitles(subtitles: "")
    
    /// 자막을 클릭 했을 때, 제스쳐로 인지할 제스쳐 인스턴스
    lazy var gesture = UITapGestureRecognizer(target: self, action: #selector(didTappedSubtitle))
    
    var collectionViewLayout = UICollectionViewFlowLayout()
    
    /// 가로방향으로 스크롤할 수 있도록 구현한 CollectionView
    lazy var pageCollectionView: UICollectionView = {
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0,
                                                            width: 500,
                                                            height: 500),
                                              collectionViewLayout: collectionViewLayout)
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
    let lessonInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .progressBackgroundColor
        return view
    }()
    
    /// "lessonInfoView" 하단에 토글 기능을 담당할 UIButton
    let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "infoButton") // 이미지사이즈 조절할것.
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.backgroundColor = .mainOrange
        return button
    }()
    
    private let introOuttroContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    var isPlaying: Bool { self.player.rate != 0 && self.player.error == nil }
    
    // sTag 텍스트 내용을 클릭했을 때, 이곳에 해당 텍스트의 NSRange가 저장된다.
    /// sTags로 가져온 keyword의 NSRange 정보를 담은 array
    var keywordRanges: [NSRange] = []
    /// sTags로 가져온 keyword의 Range\<Int> 정보를 담은 array
    var sTagsRanges = [Range<Int>]()
    /// 현재 자막에 있는 keyword Array
    var currentKeywords = ["", "", "", "", "", "", "", "", "", "", "", ""]
    var isStartVideo = false
    
    // MARK: - Lifecycle
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    // PIP 창이 필요한 경우 init
    init(isPlayPIP: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.isDisplayPIP = isPlayPIP
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removePeriodicTimeObserver()
        setRemoveNotification()
        print("DEBUG: deinit is Activate")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        DispatchQueue.main.async {
            // TODO: 아래 코드 대신 등록된 Observer를 찾아서 제거해주어야한다.
//            self.player.currentItem?.removeObserver(self, forKeyPath: "duration", context: nil)
            NotificationCenter.default.removeObserver(self)
            self.player.pause()
            self.removePeriodicTimeObserver()
            self.setRemoveNotification()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // 인트로 종료될 때, delegat로 해주고 있어서 잠시 주석처리했음. 06.17
//        setNotification()
        
        // 인트로를 실행한다.
        if self.isStartVideo == false {
            let vc = IntroController()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false) {
                // 이 player의 Notification이 남아있어서 인트로종료 시, 아래 player의 Notification이 종료된다.
                self.setRemoveNotification()
                self.player.pause()
            }
            self.isStartVideo = true
        }
        else {
            AppDelegate.AppUtility.lockOrientation(.all)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 가로모드를 제한한다.
//        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        configureDataAndNoti()
        configureUI() // 전반적인 UI 구현 메소드
        configureToggleButton() // 선생님 정보 토글버튼 메소드
        configureVideoControlView() // 비디오 상태바 관련 메소드
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeInfoView), name: NSNotification.Name("1234"), object: nil)
    }
        
    @objc func closeInfoView() {
        if self.teacherInfoFoldConstraint!.isActive == false {
            self.teacherInfoFoldConstraint!.isActive = true
            self.teacherInfoUnfoldConstraint!.isActive = false
        }
    }
    
    // MARK: - Action
    
    @objc func xButtonDidTap() {
        UIView.animate(withDuration: 0.33) {
            self.pipContainerView.alpha = 0
        }
    }
    
    @objc func pipViewDidTap(_ sender: UITapGestureRecognizer) {
        let pipDataManager = PIPDataManager.shared
        self.pipContainerView.alpha = 0
        if let previousVideoID = videoDataManager.previousVideoID {
            setRemoveNotification()
            let inputData = DetailVideoInput(video_id: previousVideoID,
                                             token: Constant.token)
            // 여기에서 previousVideoID는 이전 ID가 명확하다.
            // 그런데 pipView를 누르기 직전의 URL은 현재 URL이 들어가있다.
            // 느낌상 새로 rootView를 바꿀때, 뭔가 문제가 있어보인다.
            // "상세화면 영상 API"를 호출한다.
            DetailVideoDataManager().DetailVideoDataManager(inputData, viewController: self)
            self.pageCollectionView.reloadData()
        }
    }
    
    // MARK: - Helper

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        let width = pageCollectionView.frame.width
//        let height = pageCollectionView.frame.height
//
//        collectionViewLayout.itemSize = CGSize(width: width,
//                                               height: height)
    }
    
    // Portrait과 Landscape로 전환 될때마다 호출되는 메소드
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator)
    {
        // 화면 회전 시, 강제로 "노트보기" Cell로 이동하도록 한다.
//        pageCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
//                                        at: UICollectionView.ScrollPosition.left,
//                                        animated: true)
        
        // 회전하기 전 현재 collectionview의 index를 가져온다
        let currentIndex = self.pageCollectionView.contentOffset.x / self.pageCollectionView.frame.size.width
        // 키보드 내리기
        self.view.endEditing(true)
        
        super.viewWillTransition(to: size, with: coordinator)
        
        /// true == 가로모드, false == 세로모드
        if UIDevice.current.orientation.isLandscape {
            changeConstraintToVideoContainer(isPortraitMode: true)
        } else {
            changeConstraintToVideoContainer(isPortraitMode: false) // 05.21 주석처리; 1차 배포를 위해
        }
        
        // 가로모드 대응을 위해 flowLayout을 재정의한다.
        guard let flowLayout = pageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
        
        // 회전하면서 collectionview의 paging width가 달라지고
        // 선택된 탭이 해제되는것을 수정
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.customMenuBar.videoMenuBarTabBarCollectionView.selectItem(at: IndexPath(row: Int(currentIndex), section: 0), animated: true, scrollPosition: .centeredVertically)
            self.customMenuBar.collectionView(self.customMenuBar.videoMenuBarTabBarCollectionView, didSelectItemAt: IndexPath(item: Int(currentIndex), section: 0))
        }
    }
    
    func introVideoStart() {
        let testView = UIView()
        testView.backgroundColor = .mainOrange
        view.addSubview(testView)
        testView.setDimensions(height: view.frame.width * 0.57,
                               width: view.frame.width)
        testView.anchor(top: view.topAnchor,
                        left: view.leftAnchor)
    }
    
    func configurePIPView(pipData: PIPVideoData?) {
//        guard let pipData = self.pipData else { return }
//        let pipDataManager = PIPDataManager.shared
        let pipHeight = view.frame.height * 0.085
        let pipVC = PIPController(isPlayPIP: false)
        
        /* pipContainerView - Constraint */
        view.addSubview(self.pipContainerView)
        self.pipContainerView.anchor(left: pageCollectionView.leftAnchor,
                                     bottom: view.bottomAnchor,
                                     right: pageCollectionView.rightAnchor,
                                     height: pipHeight)
        
        let pipTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.pipViewDidTap))
        self.pipContainerView.addGestureRecognizer(pipTapGesture)
        self.pipContainerView.isUserInteractionEnabled = true
        
        /* pipVC.view - Constraint  */
        let pipThumbnailImageView = UIImageView()
        pipThumbnailImageView.image = self.videoDataManager.previousvideoThumbnailImage ?? UIImage()
        self.pipContainerView.addSubview(pipThumbnailImageView)
        pipThumbnailImageView.anchor(top: self.pipContainerView.topAnchor)
        pipThumbnailImageView.centerY(inView: self.pipContainerView)
        pipThumbnailImageView.setDimensions(height: pipHeight, width: pipHeight * 1.77)
        
//        pipVC.pipVideoData = pipData
//        pipContainerView.addSubview(pipVC.view)
//        pipVC.view.anchor(top:pipContainerView.topAnchor)
//        pipVC.view.centerY(inView: pipContainerView)
//        pipVC.view.setDimensions(height: pipHeight, width: pipHeight * 1.77)
        
        /* xButton - Constraint */
        self.pipContainerView.addSubview(self.xButton)
        self.xButton.setDimensions(height: 25, width: 25)
        self.xButton.centerY(inView: self.pipContainerView)
        self.xButton.anchor(right: self.pipContainerView.rightAnchor,
                            paddingRight: 5)
        
        /* lessonTitleLabel - Constraint */
        self.pipContainerView.addSubview(self.lessonTitleLabel)
        self.lessonTitleLabel.anchor(top: self.pipContainerView.topAnchor,
                                     left: self.pipContainerView.leftAnchor,
                                     paddingTop: 13,
                                     paddingLeft: pipHeight * 1.77 + 5,
                                     height: 17)
        self.lessonTitleLabel.text = self.videoDataManager.previousVideoTitle
        
        /* teachernameLabel - Constraint */
        self.pipContainerView.addSubview(self.teachernameLabel)
        self.teachernameLabel.anchor(top: self.lessonTitleLabel.bottomAnchor,
                                     left: self.lessonTitleLabel.leftAnchor,
                                     paddingTop: 5,
                                     height: 15)
        if let previousTeacherName = videoDataManager.previousVideoTeachername {
            self.teachernameLabel.text = previousTeacherName + " 선생님"
        }
    }
    
    func setupIntroOuttroVideoContainerView() {
        // TODO: 인트로 및 아웃트로 를 위한 컨테이너뷰를 넣어야 한다.
//        introOuttroContainerView
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension VideoController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
//        self.noteViewController = LectureNoteController(id: self.id, token: Constant.token)
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier, for: indexPath) as! BottomNoteCell
            guard let id = self.id else { return UICollectionViewCell() }
            
//            let testVC = TestSearchController(clickedText: "2 개 생기는 이유좀 알려줘요")
//            let noteVC = DetailNoteController(id: id, token: Constant.token) // 05.25이전 노트컨트롤러
            let noteVC = LectureNoteController(id: id, token: Constant.token) // 05.25이후 노트컨트롤러
            self.addChild(noteVC)
//            self.addChild(self.noteViewController)
            
            noteVC.didMove(toParent: self)
            
            cell.view.addSubview(noteVC.view)
            noteVC.view.anchor(top: cell.view.topAnchor,
                               left: cell.view.leftAnchor,
                               bottom: cell.view.bottomAnchor,
                               right: cell.view.rightAnchor)
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomQnACell.reusableIdentifier, for: indexPath) as! BottomQnACell
            cell.videoID = self.id ?? ""
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoPlaylistCell.reusableIdentifier, for: indexPath) as! VideoPlaylistCell
            self.videoPlaylistVC = VideoPlaylistVC(seriesID: self.seriesID ?? "100")
            guard let videoPlaylistVC = self.videoPlaylistVC else { return UICollectionViewCell() }
            self.addChild(videoPlaylistVC)
            cell.addSubview(videoPlaylistVC.view)
            videoPlaylistVC.view.anchor(top: cell.topAnchor,
                                        left: cell.leftAnchor,
                                        bottom: cell.bottomAnchor,
                                        right: cell.rightAnchor)
            videoPlaylistVC.didMove(toParent: self)
            videoPlaylistVC.playVideoDelegate = self
            return cell
//        case 2:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomPlaylistCell.reusableIdentifier, for: indexPath) as! BottomPlaylistCell
//
//            cell.seriesID = self.seriesID
//
//            //추천
//            cell.recommendSeriesID = self.recommendSeriesId ?? ""
//            cell.receiveRecommendModelData = self.recommendReceiveData
//
//            //인기
//            cell.popularSeriesID = self.popularSeriesId ?? ""
//            cell.receivePopularModelData = self.popularReceiveData
//            cell.popularViewTitleValue = self.popularViewTitle ?? ""
//
//            //국영수
//            cell.koreanSeriesID = self.koreanSeriesId ?? ""
//            cell.koreanSwitchOnOffValue = self.koreanSwitchValue
//            cell.receiveKoreanModelData = self.koreanReceiveData
//            cell.koreanSelectedBtnValue = self.koreanSelectedBtn
//            cell.koreanViewTitleValue = self.koreanViewTitle ?? ""
//
//            //과학
//            cell.scienceSeriesID = self.scienceSeriesId ?? ""
//            cell.scienceSwitchOnOffValue = self.scienceSwitchValue
//            cell.recieveScienceModelData = self.scienceReceiveData
//            cell.scienceSelectedBtnValue = self.scienceSelectedBtn
//            cell.scienceViewTitleValue = self.scienceViewTitle ?? ""
//
//            //사회
//            cell.socialStudiesSeriesID = self.socialStudiesSeriesId ?? ""
//            cell.socialStudiesSwitchOnOffValue = self.socialStudiesSwitchValue
//            cell.recieveSocialStudiesModelData = self.socialStudiesReceiveData
//            cell.socialStudiesSelectedBtnValue = self.socialStudiesSelectedBtn
//            cell.socialStudiesViewTitleValue = self.socialStudiesViewTitle ?? ""
//
//            //기타
//            cell.otherSubjectsSeriesID = self.otherSubjectsSeriesId ?? ""
//            cell.otherSubjectsSwitchOnOffValue = self.otherSubjectsSwitchValue
//            cell.recieveOtherSubjectsModelData = self.otherSubjectsReceiveData
//            cell.otherSubjectsSelectedBtnValue = self.otherSubjectsSelectedBtn
//            cell.otherSubjectsViewTitleValue = self.otherSubjectsViewTitle ?? ""
//
//            cell.delegate = self
//            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier, for: indexPath) as! BottomNoteCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { return 3 }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        let itemAt = Int(targetContentOffset.pointee.x / self.view.frame.width)
        let indexPath = IndexPath(item: itemAt, section: 0)
        customMenuBar.videoMenuBarTabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension VideoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: self.pageCollectionView.frame.width,
                      height: self.pageCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
}

// MARK: - API

extension VideoController {
    /// 06.11 이후에 작성한 API메소드
    func didSuccessReceiveVideoData(response: DetailVideoResponse) {
        // token 버그 발생 시, 주석 해제해볼 것 06.22
//        setRemoveNotification()
        
        let autoPlayDM = AutoplayDataManager.shared
        autoPlayDM.mainSubjectListCount = 0
        
        self.player.pause()
        
        // 현재 VideoID를 추가한다.
        self.videoDataManager.addVideoIDLog(videoID: response.data.id)
        
        self.seriesID = response.data.iSeriesId
        self.lessonInfoController.seriesID = self.seriesID
        
        // videoURL을 저장한다.
        if let videoURL = response.data.source_url {
            let url = URL(string: videoURL) as NSURL?
            self.videoDataManager.addVideoURLLog(videoURL: url)
            self.videoURL = url
//            print("DEBUG: time \(self.playerItem.duration.seconds)")
            self.playerItem = AVPlayerItem(url: url! as URL)
            self.videoAndVttURL.videoURL = url
        }
        
        // videoSubtitleURL을 저장한다.
        let subtitleURL = "https://file.gongmanse.com/" + response.data.sSubtitle
        self.videoDataManager.addVideoSubtitleURLLog(videoSubtitleURL: subtitleURL)
        self.vttURL = "https://file.gongmanse.com/" + response.data.sSubtitle
        self.videoAndVttURL.vttURL = self.vttURL
        
        // sTags
        let receivedsTagsData = response.data.sTags
        let sTagsArray = receivedsTagsData.split(separator: ",").map { String($0) }
        self.lessonInfoController.sTagsArray = sTagsArray
        
        // 이전에 sTags 값이 있을 수 있으므로 값을 제거한다.
        self.sTagsArray.removeAll()
        
        // "sTagsArray"는 String.Sequence이므로 String으로 캐스팅한 후, 값을 할당한다.(자막에서 색상칠할 키워드 찾는용도)
        for index in 0 ... sTagsArray.count - 1 {
            let inputData = String(sTagsArray[index])
            self.tempsTagsArray.append(inputData)
        }
        
        // 선생님이름을 저장한다.
        let teachername = response.data.sTeacher
        self.teachername = response.data.sTeacher + " 선생님"
        self.lessonInfoController.teachernameLabel.text = teachername + " 선생님"
        self.videoDataManager.addVideoTeachername(teachername: teachername)
        
        // 영상제목을 저장한다.
        let lessonTitle = response.data.sTitle
        self.lessonname = response.data.sTitle
        self.lessonInfoController.lessonnameLabel.text = lessonTitle
        self.videoDataManager.addVideoTitle(videoTitle: lessonTitle)
        
        // 이후 코드는 이 컨트롤러에서 보여주는 UI를 업데이트 하기 위한 코드
        // "sSubject" -> LessonInfoController.sSubjectLabel.labelText
        let subjectname = response.data.sSubject
        self.lessonInfoController.sSubjectLabel.labelText = subjectname
        
        // "sSubjectColor" -> LessonInfoController.sSubjectLabel.labelBackgroundColor
        let subjectColor = response.data.sSubjectColor
        self.lessonInfoController.sSubjectLabel.labelBackgroundColor = UIColor(hex: "\(subjectColor)")
        
        // "sUnit" -> LessonInfoController.sUnitLabel01.labelText
        let unitname01 = response.data.sUnit
        if unitname01 == "" {
            self.lessonInfoController.sUnitLabel01.labelText = "DEFAULT"
        } else {
            self.lessonInfoController.sUnitLabel01.labelText = unitname01
        }

        // lessionInfo로 VideoID를 전달한다.
        self.lessonInfoController.videoID = self.id
        self.lessonInfoController.seriesID = self.seriesID
        
        // 재생목록에 데이터를 조회하기 위한 "SeriesID" 를 전달한다.
        self.recommendSeriesId = response.data.iSeriesId
        
        // 썸네일 이미지를 저장한다.
        let imageStringURL = response.data.sThumbnail
        let convertThumbnailImageURL = "https://file.gongmanse.com/" + makeStringKoreanEncoded(imageStringURL)
        let imageURL = URL(string: convertThumbnailImageURL)
        
        do {
            let thumbnailData = try Data(contentsOf: imageURL!)
            videoDataManager.addVideoThumbnailImage(videoImage: UIImage(data: thumbnailData)!)
        } catch {
            print("DEBUG: 이미지를 제대로 못 받아왔습니다.")
        }
        
        let isBookmark = response.data.sBookmarks
        self.lessonInfoController.isBookmark = isBookmark
        
        /// 내가준 점수
        if let lessonRating = response.data.iUserRating {
            self.lessonInfoController.myRating = lessonRating
        }
        
        /// 유저들의 평균점수
        let avgRating = response.data.iRating
        self.lessonInfoController.userRating = avgRating
        
        DispatchQueue.main.async {
            self.playVideo()
        }
        
        let pipData = PIPVideoData(isPlayPIP: false,
                                   videoURL: videoDataManager.previousVideoURL,
                                   currentVideoTime: 0.0,
                                   videoTitle: self.videoDataManager.previousVideoTitle ?? "",
                                   teacherName: self.videoDataManager.previousVideoTeachername ?? "")
        
        self.pipData = pipData
        
        if !self.videoDataManager.isFirstPlayVideo {
            self.configurePIPView(pipData: pipData)
        }
    }
    
    /// 06.11 이전에 작성한 API메소드
    func didSucceedNetworking(response: DetailVideoResponse) {
        setRemoveNotification()

        // source_url -> VideoURL
        let pipDataManager = PIPDataManager.shared
        
        // PIP
        if pipDataManager.currentVideoID == nil {
//            pipDataManager.previousVideoID = self.id
            pipDataManager.currentVideoID = self.id
        } else {
            pipDataManager.previousVideoID = pipDataManager.currentVideoID
            pipDataManager.currentVideoID = self.id
        }
        
        var videoURL: NSURL?
        if let sourceURL = response.data.source_url {
            let url = URL(string: sourceURL) as NSURL?
            self.videoURL = url
            videoURL = url
            self.videoAndVttURL.videoURL = url
            
            // PIP
            if pipDataManager.isDisplayVideoFirstTime {
                pipDataManager.previousVideoURL = url
                pipDataManager.currentVideoURL = url
            } else {
                pipDataManager.previousVideoURL = pipDataManager.currentVideoURL
                pipDataManager.currentVideoURL = url
            }
        }
        
        // sSubtitles -> vttURL
        self.vttURL = "https://file.gongmanse.com/" + response.data.sSubtitle
        self.videoAndVttURL.vttURL = self.vttURL
        
        // sTags -> sTagsArray
        let receivedsTagsData = response.data.sTags
        let sTagsArray = receivedsTagsData.split(separator: ",").map { String($0) }
        self.lessonInfoController.sTagsArray = sTagsArray
        
        // 이전에 sTags 값이 있을 수 있으므로 값을 제거한다.
        self.sTagsArray.removeAll()
        
        // "sTagsArray"는 String.Sequence이므로 String으로 캐스팅한 후, 값을 할당한다.(자막에서 색상칠할 키워드 찾는용도)
        for index in 0 ... sTagsArray.count - 1 {
            let inputData = String(sTagsArray[index])
            self.tempsTagsArray.append(inputData)
        }
        
        // "sTeacher" -> LessonInfoController.teachernameLabel.text
        let teachername = response.data.sTeacher
        self.teachername = response.data.sTeacher + " 선생님"
        self.lessonInfoController.teachernameLabel.text = teachername + " 선생님"
        
        // PIP
        if pipDataManager.isDisplayVideoFirstTime {
            pipDataManager.previousTeacherName = teachername
            pipDataManager.currentTeacherName = teachername
        } else {
            pipDataManager.previousTeacherName = pipDataManager.currentTeacherName
            pipDataManager.currentTeacherName = teachername
        }
        
        // "sTitle" -> LessonInfoController.lessonnameLabel.text
        let lessonTitle = response.data.sTitle
        self.lessonname = response.data.sTitle
        self.lessonInfoController.lessonnameLabel.text = lessonTitle
        pipDataManager.previousVideoTitle = lessonTitle
        
        // PIP
        if pipDataManager.isDisplayVideoFirstTime {
            pipDataManager.previousVideoTitle = lessonTitle
            pipDataManager.currentVideoTitle = lessonTitle
        } else {
            pipDataManager.previousVideoTitle = pipDataManager.currentVideoTitle
            pipDataManager.currentVideoTitle = lessonTitle
        }
        
        // "sSubject" -> LessonInfoController.sSubjectLabel.labelText
        let subjectname = response.data.sSubject
        self.lessonInfoController.sSubjectLabel.labelText = subjectname
        
        // "sSubjectColor" -> LessonInfoController.sSubjectLabel.labelBackgroundColor
        let subjectColor = response.data.sSubjectColor
        self.lessonInfoController.sSubjectLabel.labelBackgroundColor = UIColor(hex: "\(subjectColor)")
        
        // "sUnit" -> LessonInfoController.sUnitLabel01.labelText
        let unitname01 = response.data.sUnit
        if unitname01 == "" {
            self.lessonInfoController.sUnitLabel01.labelText = "DEFAULT"
        } else {
            self.lessonInfoController.sUnitLabel01.labelText = unitname01
        }

        // lessionInfo로 VideoID 넘기기
        self.lessonInfoController.videoID = self.id
        self.lessonInfoController.seriesID = self.seriesID
        self.recommendSeriesId = response.data.iSeriesId
        
//        pipPlayer.play()
        
        // PIP
        let pipData = PIPVideoData(isPlayPIP: false,
                                   videoURL: pipDataManager.previousVideoURL,
                                   currentVideoTime: 0.0,
                                   videoTitle: pipDataManager.previousVideoTitle ?? "",
                                   teacherName: pipDataManager.previousTeacherName ?? "")
        
        self.pipData = pipData
        DispatchQueue.main.async {
            self.playVideo()
        }
    }
    
    func failToConnectVideoByTicket() {
        presentAlert(message: "이용권을 구매하세요.")
    }
    
    func networkingByGuestKey(response: GuestKeyResponse) {
        let autoPlayDM = AutoplayDataManager.shared
        autoPlayDM.mainSubjectListCount = 0
        
        self.player.pause()

        self.seriesID = response.data.iSeriesId
        
        // videoURL을 저장한다.
        let videoURL = response.data.source_url
            
        let url = URL(string: videoURL) as NSURL?
        self.videoDataManager.addVideoURLLog(videoURL: url)
        self.videoURL = url
        //            print("DEBUG: time \(self.playerItem.duration.seconds)")
        self.playerItem = AVPlayerItem(url: url! as URL)
        self.videoAndVttURL.videoURL = url
        
        // videoSubtitleURL을 저장한다.
        let subtitleURL = "https://file.gongmanse.com/" + response.data.sSubtitle
        self.videoDataManager.addVideoSubtitleURLLog(videoSubtitleURL: subtitleURL)
        self.vttURL = "https://file.gongmanse.com/" + response.data.sSubtitle
        self.videoAndVttURL.vttURL = self.vttURL
        
        // sTags
        let receivedsTagsData = response.data.sTags
        let sTagsArray = receivedsTagsData.split(separator: ",").map { String($0) }
        self.lessonInfoController.sTagsArray = sTagsArray
        
        // 이전에 sTags 값이 있을 수 있으므로 값을 제거한다.
        self.sTagsArray.removeAll()
        
        // "sTagsArray"는 String.Sequence이므로 String으로 캐스팅한 후, 값을 할당한다.(자막에서 색상칠할 키워드 찾는용도)
        for index in 0 ... sTagsArray.count - 1 {
            let inputData = String(sTagsArray[index])
            self.tempsTagsArray.append(inputData)
        }
        
        // 선생님이름을 저장한다.
        let teachername = response.data.sTeacher
        self.teachername = response.data.sTeacher + " 선생님"
        self.lessonInfoController.teachernameLabel.text = teachername + " 선생님"
        self.videoDataManager.addVideoTeachername(teachername: teachername)
        
        // 영상제목을 저장한다.
        let lessonTitle = response.data.sTitle
        self.lessonname = response.data.sTitle
        self.lessonInfoController.lessonnameLabel.text = lessonTitle
        self.videoDataManager.addVideoTitle(videoTitle: lessonTitle)
        
        // 이후 코드는 이 컨트롤러에서 보여주는 UI를 업데이트 하기 위한 코드
        // "sSubject" -> LessonInfoController.sSubjectLabel.labelText
        let subjectname = response.data.sSubject
        self.lessonInfoController.sSubjectLabel.labelText = subjectname
        
        // "sSubjectColor" -> LessonInfoController.sSubjectLabel.labelBackgroundColor
        let subjectColor = response.data.sSubjectColor
        self.lessonInfoController.sSubjectLabel.labelBackgroundColor = UIColor(hex: "\(subjectColor)")
        
        // "sUnit" -> LessonInfoController.sUnitLabel01.labelText
        let unitname01 = response.data.sUnit
        if unitname01 == "" {
            self.lessonInfoController.sUnitLabel01.labelText = "DEFAULT"
        } else {
            self.lessonInfoController.sUnitLabel01.labelText = unitname01
        }

        // lessionInfo로 VideoID를 전달한다.
        self.lessonInfoController.videoID = self.id
        
        // 재생목록에 데이터를 조회하기 위한 "SeriesID" 를 전달한다.
        self.recommendSeriesId = response.data.iSeriesId
        
        // 썸네일 이미지를 저장한다.
        let imageStringURL = response.data.sThumbnail
        let convertThumbnailImageURL = "https://file.gongmanse.com/" + makeStringKoreanEncoded(imageStringURL)
        let imageURL = URL(string: convertThumbnailImageURL)
        
        do {
            let thumbnailData = try Data(contentsOf: imageURL!)
            videoDataManager.addVideoThumbnailImage(videoImage: UIImage(data: thumbnailData)!)
        } catch {
            print("DEBUG: 이미지를 제대로 못 받아왔습니다.")
        }
        
        DispatchQueue.main.async {
            self.playVideo()
        }
        
        let pipData = PIPVideoData(isPlayPIP: false,
                                   videoURL: videoDataManager.previousVideoURL,
                                   currentVideoTime: 0.0,
                                   videoTitle: self.videoDataManager.previousVideoTitle ?? "",
                                   teacherName: self.videoDataManager.previousVideoTeachername ?? "")
        
        self.pipData = pipData
        
        if !self.videoDataManager.isFirstPlayVideo {
            self.configurePIPView(pipData: pipData)
        }
    }
}

// MARK: - VideoSettingPopupControllerDelegate

extension VideoController: VideoSettingPopupControllerDelegate {
    func updateSubtitleIsOnState(_ subtitleIsOn: Bool) {
        self.isClickedSubtitleToggleButton = subtitleIsOn
    }

    func presentSelectionVideoPlayRateVC() {
        let vc = SelectVideoPlayRateVC()
        vc.currentVideoPlayRate = self.currentVideoPlayRate
        vc.delegate = self
        present(vc, animated: true)
    }
}

// MARK: - VideoFullScreenControllerDelegate

extension VideoController: VideoFullScreenControllerDelegate {
    // 리팩토링하기 위해 작성했던 코드
    func addNotificaionObserver() {
        setNotification()
    }
    
    func setCurrentTime(playerCurrentTime: CMTime?) {
        player.seek(to: playerCurrentTime ?? player.currentTime())
        player.play()
        player.isMuted = false
    }
}

// MARK: - BottomPlaylistCellDelegate

extension VideoController: BottomPlaylistCellDelegate {
    func videoControllerCollectionViewReloadCellInBottommPlaylistCell(videoID: String) {
        self.player.pause()
        setRemoveNotification()

        let inputData = DetailVideoInput(video_id: videoID,
                                         token: Constant.token)
        
        let pipDataManager = PIPDataManager.shared
        pipDataManager.currentVideoID = videoID
        self.id = videoID
        // "상세화면 영상 API"를 호출한다.
        DetailVideoDataManager().DetailVideoDataManager(inputData, viewController: self)
        
        // 노트 데이터를 불러온다.
//        pipContainerView.alpha = 0
        self.pageCollectionView.reloadData()
//        let noteIndexPath = IndexPath(item: 0, section: 0)
//        let qnaIndexPath = IndexPath(item: 1, section: 0)
//        pageCollectionView.reloadItems(at: [noteIndexPath, qnaIndexPath])
    }
    
    func videoControllerPresentVideoControllerInBottomPlaylistCell(videoID: String) {
        let vc = VideoController()
        vc.modalPresentationStyle = .fullScreen
        vc.id = videoID
        present(vc, animated: true) {
            self.player.pause()
        }
    }
}

// MARK: - SelectVideoPlayRateVCDelegate

extension VideoController: SelectVideoPlayRateVCDelegate {
    /// 재생속도를 컨트롤하기 위한 Delegation
    func changeVideoPlayRateByBottomPopup(rate: Float) {
        self.currentVideoPlayRate = rate
    }
}

// MARK: - IntroControllerDelegate

extension VideoController: IntroControllerDelegate {
    /// 인트로 끝나면 호출되는 Delegation 메소드
    func playVideoEndedIntro() {
        setNotification()
        self.player.play()
    }
}

// MARK: - LessonInfoControllerDelegate

/**
 "강의정보" view 내부에 키워드를 클릭 했을 때, 검색화면으로 이동한다.
 그때, 재생되던 영상을 일시정지하기 위해서 Delegation 메소드를 활용한다.
 */

extension VideoController: LessonInfoControllerDelegate {
    func problemSolvingLectureVideoPlay(videoID: String) {
        let inputData = DetailVideoInput(video_id: videoID,
                                         token: Constant.token)
        DetailVideoDataManager().DetailVideoDataManager(inputData, viewController: self)
    }
    
    /// PIP에서 재생시간을 받아와서 현재 영상에 재생하는 Delegate 메소드
    func LessonInfoPassCurrentVideoTimeInPIP(_ currentTime: CMTime) {
        if currentTime != CMTime(value: CMTimeValue(0), timescale: CMTimeScale(0)) {
            print("DEBUG: 받은 시간은 : \(currentTime) 입니다.")
            self.player.seek(to: currentTime)
            self.player.play()
            UIView.animate(withDuration: 0.33) {
                self.pipContainerView.alpha = 0
            }
        }
    }
    
    /// VideoVC에서 재생시간을 slider에서 받아서 LessonInfoVC에 전달해주는 메소드
    func videoVCPassCurrentVideoTimeToLessonInfo() {
        self.lessonInfoController.currentVideoPlayTime = self.timeSlider.value
        self.lessonInfoController.currentVideoURL = self.videoURL
    }
    
    // 화면 이동시 현재 영상을 일시정지하기 위한 메소드
    func videoVCPauseVideo() {
        self.player.pause()
    }
}

extension UIViewController {
    func changeRootVCToMainTabBarVC(completion: @escaping () -> Void) {
        let mainTabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
//        changeRootViewController(mainTabBarVC)
        
        completion()
    }
}

extension VideoController {
    // 영상 토큰이 남아있는 것을 방지하기 위해 "상세검색" 화면에서 토큰을 제거하기 위해 Notification을 이용한다.
    @objc func removeNotificationFromSearchAfterVC(_ notification: Notification) {
        self.player.pause()
        self.setRemoveNotification()
    }
}

// 영상 토큰이 남아있는 것을 방지하기 위해 "상세검색" 화면에서 토큰을 제거하기 위해 Notification을 이용한다.
extension Notification.Name {}
