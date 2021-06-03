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
    
    var currentVideoPlayRate = Float(1.0) {
        didSet {
            player.playImmediately(atRate: currentVideoPlayRate)
        }
    }
    var id: String?
    
    //추천
    var recommendSeriesId: String?
    var recommendReceiveData: VideoInput?
    
    //인기
    var popularSeriesId: String?
    var popularReceiveData: VideoInput?
    var popularViewTitle: String?
    
    //국영수
    var koreanSeriesId: String?
    var koreanSwitchValue: UISwitch?
    var koreanReceiveData: VideoInput?
    var koreanSelectedBtn: UIButton?
    var koreanViewTitle: String?
    
    //과학
    var scienceSeriesId: String?
    var scienceSwitchValue: UISwitch?
    var scienceReceiveData: VideoInput?
    var scienceSelectedBtn: UIButton?
    var scienceViewTitle: String?
    
    //사회
    var socialStudiesSeriesId: String?
    var socialStudiesSwitchValue: UISwitch?
    var socialStudiesReceiveData: VideoInput?
    var socialStudiesSelectedBtn: UIButton?
    var socialStudiesViewTitle: String?
    
    //기타
    var otherSubjectsSeriesId: String?
    var otherSubjectsSwitchValue: UISwitch?
    var otherSubjectsReceiveData: VideoInput?
    var otherSubjectsSelectedBtn: UIButton?
    var otherSubjectsViewTitle: String?
    
    var videoAndVttURL = VideoURL(videoURL: NSURL(string: ""), vttURL: "")
    lazy var lessonInfoController = LessonInfoController(videoID: id!)

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
        let image = UIImage(named: "영상재생버튼")
        button.setBackgroundImage(image, for: .normal)
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
    var timeSlider: UISlider = {
        let slider = UISlider()
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
        let image = UIImage(named: "자막토글버튼_제거")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleSubtitleToggle), for: .touchUpInside)
        return button
    }()
    
    var isClickedSubtitleToggleButton: Bool = true {
        didSet {
            if isClickedSubtitleToggleButton {
                subtitleLabel.alpha = 1
            } else {
                subtitleLabel.alpha = 0
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
    lazy var playerItem = AVPlayerItem(url: videoURL! as URL)
    lazy var queuePlayerItem = AVQueuePlayer(items: [playerItem])
    
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
        label.font = UIFont.appBoldFontWith(size: 16)
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
        button.setBackgroundImage(image, for: .normal)
        button.backgroundColor = .mainOrange
        return button
    }()
    
    var isPlaying: Bool { player.rate != 0 && player.error == nil }
    
    // sTag 텍스트 내용을 클릭했을 때, 이곳에 해당 텍스트의 NSRange가 저장된다.
    /// sTags로 가져온 keyword의 NSRange 정보를 담은 array
    var keywordRanges: [NSRange] = []
    /// sTags로 가져온 keyword의 Range\<Int> 정보를 담은 array
    var sTagsRanges = [Range<Int>]()
    /// 현재 자막에 있는 keyword Array
    var currentKeywords = ["", "", "", "", "", "", "", "", "", "", "", ""]
    
    var isStartVideo = false
    
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isStartVideo == false {
            
            let vc = IntroController()
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false) {
                self.player.pause()
            }
            self.isStartVideo = true
        }
        
    }
    
    override func viewDidLoad() {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        super.viewDidLoad()
        

        
        configureDataAndNoti()
        configureUI()                    // 전반적인 UI 구현 메소드
        configureToggleButton()          // 선생님 정보 토글버튼 메소드
        configureVideoControlView()      // 비디오 상태바 관련 메소드
    }
    
    // MARK: - Actions
    
    
    
    
    // MARK: - Heleprs
    
    /// Portrait과 Landscape로 전환 될때마다 호출되는 메소드
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // 화면 회전 시, 강제로 "노트보기" Cell로 이동하도록 한다.
//        pageCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
//                                        at: UICollectionView.ScrollPosition.left,
//                                        animated: true)
        super.viewWillTransition(to: size, with: coordinator)
        /// true == 가로모드, false == 세로모드
        if UIDevice.current.orientation.isLandscape {
            changeConstraintToVideoContainer(isPortraitMode: true)
        } else {
            changeConstraintToVideoContainer(isPortraitMode: false) //05.21 주석처리; 1차 배포를 위해
        }
        pageCollectionView.reloadData()
    }
}


//MARK:- UICollectionViewDelegate, UICollectionViewDataSource

extension VideoController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier,for: indexPath) as! BottomNoteCell
            guard let id = self.id else { return  UICollectionViewCell() }
            
//            let testVC = TestSearchController(clickedText: "2 개 생기는 이유좀 알려줘요")
//            let noteVC = DetailNoteController(id: id, token: Constant.token) // 05.25이전 노트컨트롤러
            let noteVC = LectureNoteController(id: id, token: Constant.token)  // 05.25이후 노트컨트롤러
            self.addChild(noteVC)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomPlaylistCell.reusableIdentifier, for: indexPath) as! BottomPlaylistCell
            
            //추천
            cell.recommendSeriesID = self.recommendSeriesId ?? ""
            cell.receiveRecommendModelData = self.recommendReceiveData
            
            //인기
            cell.popularSeriesID = self.popularSeriesId ?? ""
            cell.receivePopularModelData = self.popularReceiveData
            cell.popularViewTitleValue = self.popularViewTitle ?? ""
            
            //국영수
            cell.koreanSeriesID = self.koreanSeriesId ?? ""
            cell.koreanSwitchOnOffValue = self.koreanSwitchValue
            cell.receiveKoreanModelData = self.koreanReceiveData
            cell.koreanSelectedBtnValue = self.koreanSelectedBtn
            cell.koreanViewTitleValue = self.koreanViewTitle ?? ""
            
            //과학
            cell.scienceSeriesID = self.scienceSeriesId ?? ""
            cell.scienceSwitchOnOffValue = self.scienceSwitchValue
            cell.recieveScienceModelData = self.scienceReceiveData
            cell.scienceSelectedBtnValue = self.scienceSelectedBtn
            cell.scienceViewTitleValue = self.scienceViewTitle ?? ""
            
            //사회
            cell.socialStudiesSeriesID = self.socialStudiesSeriesId ?? ""
            cell.socialStudiesSwitchOnOffValue = self.socialStudiesSwitchValue
            cell.recieveSocialStudiesModelData = self.socialStudiesReceiveData
            cell.socialStudiesSelectedBtnValue = self.socialStudiesSelectedBtn
            cell.socialStudiesViewTitleValue = self.socialStudiesViewTitle ?? ""
            
            //기타
            cell.otherSubjectsSeriesID = self.otherSubjectsSeriesId ?? ""
            cell.otherSubjectsSwitchOnOffValue = self.otherSubjectsSwitchValue
            cell.recieveOtherSubjectsModelData = self.otherSubjectsReceiveData
            cell.otherSubjectsSelectedBtnValue = self.otherSubjectsSelectedBtn
            cell.otherSubjectsViewTitleValue = self.otherSubjectsViewTitle ?? ""
            
            cell.delegate = self
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomNoteCell.reusableIdentifier,for: indexPath) as! BottomNoteCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { return 3 }
    
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


// MARK: - API

extension VideoController {
    
    func didSucceedNetworking(response: DetailVideoResponse) {
        // source_url -> VideoURL
        if let sourceURL = response.data.source_url {
            let url = URL(string: sourceURL) as NSURL?
            self.videoURL = url
            self.videoAndVttURL.videoURL = url
        }
        
        // sSubtitles -> vttURL
        self.vttURL =  "https://file.gongmanse.com/" + response.data.sSubtitle
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
        self.lessonInfoController.teachernameLabel.text = teachername
        
        // "sTitle" -> LessonInfoController.lessonnameLabel.text
        let lessonTitle = response.data.sTitle
        self.lessonInfoController.lessonnameLabel.text = lessonTitle
        
        // "sSubject" -> LessonInfoController.sSubjectLabel.labelText
        let subjectname = response.data.sSubject
        self.lessonInfoController.sSubjectLabel.labelText = subjectname
        
        // "sSubjectColor" -> LessonInfoController.sSubjectLabel.labelBackgroundColor
        let subjectColor = response.data.sSubjectColor
        self.lessonInfoController.sSubjectLabel.labelBackgroundColor = UIColor.init(hex: "\(subjectColor)")
        
        // "sUnit" -> LessonInfoController.sUnitLabel01.labelText
        let unitname01 = response.data.sUnit
        if unitname01 == "" {
            self.lessonInfoController.sUnitLabel01.labelText = "DEFAULT"
        } else {
            self.lessonInfoController.sUnitLabel01.labelText = unitname01
        }

        // lessionInfo로 VideoID 넘기기
        self.lessonInfoController.videoID = id
        playVideo()
    }
    
    func failToConnectVideoByTicket() {
        presentAlert(message: "이용권을 구매하세요.")
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
}


// MARK: - BottomPlaylistCellDelegate

extension VideoController: BottomPlaylistCellDelegate {
    
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
    // 재생속도를 컨트롤하기 위한 Delegation
    func changeVideoPlayRateByBottomPopup(rate: Float) {
        self.currentVideoPlayRate = rate
    }
    
    
}


// MARK: - IntroControllerDelegate

extension VideoController: IntroControllerDelegate {
    func playVideoEndedIntro() {
        player.play()
    }
}


// MARK: - OuttroVideoControllerDelegate

extension VideoController: OuttroVideoControllerDelegate {
    func playVideoEndedOuttro() {
        print("DEBUG: 끝나면 호출되는 메소드")
    }
    
    
}
