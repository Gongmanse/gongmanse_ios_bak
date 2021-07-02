import AVFoundation
import UIKit

protocol LessonInfoControllerDelegate: AnyObject {
    func videoVCPauseVideo()
    func videoVCPassCurrentVideoTimeToLessonInfo()
    func LessonInfoPassCurrentVideoTimeInPIP(_ currentTime: CMTime)
    func problemSolvingLectureVideoPlay(videoID: String)
}

class LessonInfoController: UIViewController {
    // MARK: - Properties
    
    var pipVideoData: PIPVideoData? // PIP 재생을 위해 필요한 구조체
    var seriesID: String?
    // "LessonInfoController"에서 "관련시리즈" 혹은 "sTags"를 클릭했을 때, 영상재생시간을 dataManager에 입력한다.
    var currentVideoPlayTime: Float? {
        didSet {
            let pipDataManager = PIPDataManager.shared
            pipDataManager.currentVideoTime = currentVideoPlayTime ?? 0.0
        }
    }
    
    var currentPIPVideoPlayTime: CMTime? {
        didSet {
            if let currentPIPVideoPlayTime = currentPIPVideoPlayTime {
                delegate?.LessonInfoPassCurrentVideoTimeInPIP(currentPIPVideoPlayTime)
            }
        }
    }
    
    var currentVideoURL: NSURL? // 현재 영싱의 VideoID
    
    weak var delegate: LessonInfoControllerDelegate?
    
    public var sSubjectLabel = sUnitLabel("DEFAULT", .brown)
    public var sUnitLabel01 = sUnitLabel("DEFAULT", .darkGray)
    public var sUnitLabel02 = sUnitLabel("DEFAULT", .mainOrange)
    
    public var sTagsArray = [String]() {
        didSet { sTagsCollectionView?.reloadData() }
    }
    
    let buttonSize = CGRect(x: 0, y: 0, width: 40, height: 40)
    public var teachernameLabel = PlainLabel("김우성 선생님", fontSize: 11.5)
    public var lessonnameLabel = PlainLabel("분석명제와 종합명제", fontSize: 17)
    public var sTagsCollectionView: UICollectionView?
    private lazy var bookmarkButton = TopImageBottomTitleView(frame: buttonSize,
                                                              title: "즐겨찾기",
                                                              image: UIImage(named: "favoriteOff")!)
    private lazy var rateLessonButton = TopImageBottomTitleView(frame: buttonSize,
                                                                title: "평점",
                                                                image: UIImage(named: "gradeOff")!)
    private lazy var shareLessonButton = TopImageBottomTitleView(frame: buttonSize,
                                                                 title: "공유",
                                                                 image: UIImage(named: "share")!)
    private lazy var relatedSeriesButton = TopImageBottomTitleView(frame: buttonSize,
                                                                   title: "관련시리즈",
                                                                   image: UIImage(named: "series")!)
    private lazy var problemSolvingButton = TopImageBottomTitleView(frame: buttonSize,
                                                                    title: "문제풀이",
                                                                    image: UIImage(named: "question")!)
    // videoID
    var videoID: String?
    
    // 문제풀이 누를 때 이름바꾸는 변수
    var isChangedName: Bool = false
    
    // ViewModel
    var videoDetailVM: VideoDetailViewModel? = VideoDetailViewModel()
    
    // 즐겨찾기 여부
    public var isBookmark: Bool = false {
        didSet {
            if isBookmark {
                bookmarkButton.viewTintColor = .mainOrange
            } else {
                bookmarkButton.viewTintColor = .black
            }
        }
    }
    
    /// 내가 준 점수
    var myRating: String?
    
    /// 유저들의 평균 점수
    var userRating: String? {
        didSet {
            // 내가 준 점수가 있다면, 유저들의 평균점수를 보여준다.
            if myRating != nil {
                if let userRating = userRating {
                    if userRating == "" {
                        rateLessonButton.titleLabel.text = "3.0"
                    }
                    rateLessonButton.titleLabel.text = userRating
                    rateLessonButton.viewTintColor = .mainOrange
                }
            } else {
                rateLessonButton.titleLabel.text = "평점"
                rateLessonButton.tintColor = .black
                rateLessonButton.viewTintColor = .black
            }
        }
    }
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(videoID: String?) {
        super.init(nibName: nil, bundle: nil)
        self.videoID = videoID
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        videoDetailVM?.requestVideoDetailApi(videoID ?? "")
//        videoDetailVM?.requestVideoDetailApi("151")
    }
    
    /**
      1. PIP에서 재생된 시간을 받아서 class 내부 변수에 값을 할당합니다.
      2. 값을 받는 변수에 didSet을 통해 delegate Method를 호출합니다.
      3. delegate Method를 통해서 videoController의 재생 시작위치를 변경합니다.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        print("DEBUG: LessonInfoController Appear!!!")
        let pipDataManager = PIPDataManager.shared
        currentPIPVideoPlayTime = pipDataManager.currentVideoCMTime
    }
    
    // MARK: - Actions
    
    // TODO: 정상적으로 Action 메소드가 호출되는지 TEST -> 05.03 OK
    @objc func presentClickedTagSearchResult() {
        present(TestSearchController(clickedText: "테스트중"), animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            sTagsCollectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    @objc func handleBookmarkAction(sender: UIView) {
        guard let videoID = self.videoID else { return }
        if bookmarkButton.viewTintColor == .mainOrange {
            // 즐겨찾기를 삭제한다.
            
            bookmarkButton.viewTintColor = .black
            BookmarkDataManager().deleteBookmarkToVideo(DeleteBookmarkInput(token: Constant.token,
                                                                            video_id: "\(videoID)"),
                                                        viewController: self)
        } else {
            // 즐겨찾기를 추가한다.
            bookmarkButton.viewTintColor = .mainOrange
            BookmarkDataManager().addBookmarkToVideo(BookmarkInput(video_id: Int(videoID) ?? 0,
                                                                   token: Constant.token),
                                                     viewController: self)
        }
    }
    
    /// 평점 버튼을 클릭하면 호출되는 콜백메소드
    @objc func handleRateLessonAction() {
        // "관련시리즈" 를 클릭했을 때, 영상 재생시간을 "VideoController"로 부터 가져온다.
//        delegate?.videoVCPassCurrentVideoTimeToLessonInfo()
        
        if rateLessonButton.titleLabel.text != "평점" {
            rateLessonButton.viewTintColor = .mainOrange
        } else {
            rateLessonButton.viewTintColor = .black
        }
        
        guard let videoID = self.videoID else { return }
       
        let vc = RatingController(videoID: Int(videoID) ?? 1)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        
        // 변동가능성 있는 부분
        rateLessonButton.viewTintColor = .mainOrange
        rateLessonButton.titleLabel.text = userRating
        
        if let myRatingPoint = myRating {
            vc.clickedNumber = Int(myRatingPoint) ?? 3
            vc.myRating = myRating
        }
        
        vc.userRating = userRating
        
        present(vc, animated: false)
    }
    
    @objc func handleShareLessonAction() {
        // 클릭 시, 클릭에 대한 상태를 나타낼필요가 없으므로 검정색으로 유지시켰다.
        presentAlert(message: "서비스 준비중입니다.")
    }

    @objc func handleRelatedSeriesAction() {
        let videoDataManager = VideoDataManager.shared
        
        if Constant.isLogin {
            delegate?.videoVCPauseVideo()
            let presentVC = LecturePlaylistVC(videoID ?? "")
            presentVC.lectureState = .lectureList
            presentVC.seriesID = seriesID
            let pipVideoData = PIPVideoData(isPlayPIP: true,
                                            videoURL: videoDataManager.previousVideoURL,
                                            currentVideoTime: currentVideoPlayTime ?? Float(0.0),
                                            videoTitle: lessonnameLabel.text ?? "",
                                            teacherName: teachernameLabel.text ?? "")
            presentVC.pipData = pipVideoData
            let nav = UINavigationController(rootViewController: presentVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            // TODO: 관련시리즈를 켠다.
        } else {
            presentAlert(message: "로그인 후 이용해주세요.")
        }
    }
    
    @objc func handleProblemSolvingAction() {
        // TODO: Delegation을 이용해서,영상의 URL의 네트워킹을 통해 변경해주면 될 것 같다.
        // ex) 재생목록 영상 바꾸듯이.
        
        isChangedName = !isChangedName
        
        problemSolvingButton.titleLabel.text = isChangedName ? "개념정리" : "문제풀이"
        
        videoDetailVM?.isCommentary = isChangedName
        
        switch isChangedName {
        case true: // 문제풀이
            videoDetailVM?.requestVideoDetailApi(videoDetailVM?.commantaryID ?? "")
            
            delegate?.problemSolvingLectureVideoPlay(videoID: videoDetailVM?.commantaryID ?? "15188")
            
        case false: // 개념정리
            videoDetailVM?.requestVideoDetailApi(videoDetailVM?.commantaryID ?? "")
            
            delegate?.problemSolvingLectureVideoPlay(videoID: videoDetailVM?.commantaryID ?? "15188")
        }
    }
    
    // TODO: 태그 클릭 시, 검색결과화면으로 이동하는 메소드
    // TODO: 즐겨찾기 클릭 시, 즐겨칮가 API호출
    // TODO: 평점 클릭 시, 평점 View present (No animation)
    // TODO: 공유 클릭 시, 페이스북 & 카카오톡 View present (No animtaion)
    // TODO: 관련시리즈 클릭 시, 어떤 기준으로 영상리스트를 부르는지는 모르겠으나 영상 리스트 Controller present
    // TODO: 문제풀이는 현재 Zeplin에 업데이트가 안된 상태 -> 안드로이드보고 내용 추가 05.03
    
    // MARK: - Helpers
    
    func configureUI() {
        let sSubjectsUnitContainerView = UIView()
        let paddingConstant = view.frame.height * 0.025

        // API에서 받아온 값을 레이블에 할당한다.
        sSubjectLabel.labelText = "과목명"
        sUnitLabel01.labelText = "단원명"
//        sUnitLabel02.labelText = "챕터명"
        
        // TODO: 정상적으로 view가 보이는지 TEST -> 05.03 OK
        view.backgroundColor = #colorLiteral(red: 0.9293201566, green: 0.9294758439, blue: 0.9292996526, alpha: 1)
        
        // TODO: [UI] 강의 태그 -> 05.04 OK
        view.addSubview(sSubjectsUnitContainerView)
        sSubjectsUnitContainerView.setDimensions(height: 25,
                                                 width: view.frame.width * 0.9)
        sSubjectsUnitContainerView.anchor(top: view.topAnchor,
                                          left: view.leftAnchor,
                                          paddingTop: paddingConstant, paddingLeft: 30)
        
        sSubjectLabel.layer.cornerRadius = 11.5
        sSubjectsUnitContainerView.addSubview(sSubjectLabel)
        sSubjectLabel.anchor(top: sSubjectsUnitContainerView.topAnchor,
                             left: sSubjectsUnitContainerView.leftAnchor,
                             paddingLeft: 2.5,
                             height: 25)
        configuresUnit(sSubjectsUnitContainerView, sSubjectLabel, label: sUnitLabel01)
        configuresUnit(sSubjectsUnitContainerView, sUnitLabel01, label: sUnitLabel02)
        
        // TODO: [UI] 선생님이름 -> 05.04 OK
        sSubjectsUnitContainerView.addSubview(teachernameLabel)
        teachernameLabel.centerY(inView: sSubjectLabel)
        teachernameLabel.anchor(right: sSubjectsUnitContainerView.safeAreaLayoutGuide.rightAnchor,
                                height: 25)
        
        // TODO: [UI] 강의 명 -> 05.04 OK
        sSubjectsUnitContainerView.addSubview(lessonnameLabel)
        lessonnameLabel.numberOfLines = 2
        lessonnameLabel.anchor(top: sSubjectLabel.bottomAnchor,
                               left: sSubjectLabel.leftAnchor,
                               paddingTop: 10, paddingLeft: 5, height: 20)
        
        // TODO: [UI] 해쉬 태그 -> 05.04 UI 완성
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 2.5)
        layout.scrollDirection = .horizontal
        layout.itemSize.height = 20
        sTagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(sTagsCollectionView ?? UICollectionView())
        sTagsCollectionView?.setDimensions(height: 20, width: view.frame.width * 0.9)
        sTagsCollectionView?.anchor(top: lessonnameLabel.bottomAnchor,
                                    left: view.leftAnchor,
                                    paddingTop: 10, paddingLeft: 10)
        configureCollectionView()
        configureAdditionalFunctions() // 05.21 주석처리; 1차 배포를 위해 (기능 미구현상태)
        configureAddActions()
    }
    
    func configureCollectionView() {
        sTagsCollectionView?.delegate = self
        sTagsCollectionView?.dataSource = self
        sTagsCollectionView?.register(sTagsCell.self, forCellWithReuseIdentifier: "sTagsCell")
        sTagsCollectionView?.backgroundColor = #colorLiteral(red: 0.9293201566, green: 0.9294758439, blue: 0.9292996526, alpha: 1)
        sTagsCollectionView?.isScrollEnabled = true
        sTagsCollectionView?.showsHorizontalScrollIndicator = false
    }
    
    func configureAddActions() {
        let bookmarkButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleBookmarkAction))
        let rateLessonButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleRateLessonAction))
        let shareLessonButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleShareLessonAction))
        let relatedSeriesButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleRelatedSeriesAction))
        let problemSolvingButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleProblemSolvingAction))
        bookmarkButton.addGestureRecognizer(bookmarkButtonGesture)
        rateLessonButton.addGestureRecognizer(rateLessonButtonGesture)
        shareLessonButton.addGestureRecognizer(shareLessonButtonGesture)
        relatedSeriesButton.addGestureRecognizer(relatedSeriesButtonGesture)
        problemSolvingButton.addGestureRecognizer(problemSolvingButtonGesture)
    }
    
    func configureAdditionalFunctions() {
        // TODO: [UI] 즐겨찾기, 평점, 공유, 관련시리즈, 문제풀이 -> 05.04 UI 완성
        let stack = UIStackView(arrangedSubviews:
            [bookmarkButton, rateLessonButton, shareLessonButton, relatedSeriesButton, problemSolvingButton])
        let buttonHeight = view.frame.width * 0.12
        let buttonWidth = view.frame.width * 0.1
        bookmarkButton.setDimensions(height: buttonHeight, width: buttonWidth)
        rateLessonButton.setDimensions(height: buttonHeight, width: buttonWidth)
        shareLessonButton.setDimensions(height: buttonHeight, width: buttonWidth)
        relatedSeriesButton.setDimensions(height: buttonHeight, width: buttonWidth)
        problemSolvingButton.setDimensions(height: buttonHeight, width: buttonWidth)
        view.addSubview(stack)
        stack.isUserInteractionEnabled = true
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        stack.spacing = buttonWidth - 5
        stack.alignment = .leading
        stack.centerX(inView: view)
        stack.anchor(top: sTagsCollectionView?.bottomAnchor, paddingTop: 10)
    }
}

// MARK: - Common UI Attribute setting Method

extension LessonInfoController {
    func configuresUnit(_ containerView: UIView, _ leftView: UIView, label: UILabel) {
        containerView.addSubview(label)
        label.anchor(top: containerView.topAnchor, left: leftView.rightAnchor,
                     paddingLeft: 2.5, height: 25)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension LessonInfoController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return sTagsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let item = sTagsArray[indexPath.row]
        let cell = sTagsCollectionView?.dequeueReusableCell(withReuseIdentifier: "sTagsCell", for: indexPath) as! sTagsCell
        cell.cellLabel.text = item
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let item = sTagsArray[indexPath.row]
        let itemSize = item.size(withAttributes: [NSAttributedString.Key.font: UIFont.appBoldFontWith(size: 15)])
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        let videoDataManager = VideoDataManager.shared
        videoDataManager.isFirstPlayVideo = false
        
        // "sTags" 를 클릭했을 때, 영상 재생시간을 "VideoController"로 부터 가져온다.
        delegate?.videoVCPassCurrentVideoTimeToLessonInfo()
        
        // 클릭한 키워드를 입력한다.
        let data = sTagsArray[indexPath.row]
        
        // 재생중이던 영상을 일시중지한다. 동시에, PIP를 재생한다. -> Delegation 필요 -> 완료
        delegate?.videoVCPauseVideo()

        let vc = SearchAfterVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        vc.searchData.searchText = data

        guard let videoURL = currentVideoURL else { return }
        
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        present(nav, animated: true) {
            let pipVideoData = PIPVideoData(isPlayPIP: true,
                                            videoURL: videoURL,
                                            currentVideoTime: self.currentVideoPlayTime ?? Float(0.0),
                                            videoTitle: self.lessonnameLabel.text ?? "",
                                            teacherName: self.teachernameLabel.text ?? "")
            vc.pipVideoData = pipVideoData
            
            // isPlayPIP 값을 "SearchAfterVC" 에 전달한다. -> 완료
            // 그 값에 따라서 PIP 재생여부를 결정한다.
            vc.isOnPIP = true // PIP 모드를 실행시키기 위한 변수
        }
    }
}

extension LessonInfoController: RatingControllerDelegate {
    func dismissRatingView() {
        rateLessonButton.titleLabel.text = "평점"
        rateLessonButton.viewTintColor = .black
        view.setNeedsDisplay()
    }
    
    func ratingAvaergePassVC(rating: String) {
        myRating = rating
        rateLessonButton.titleLabel.text = rating
        rateLessonButton.viewTintColor = .mainOrange
        view.setNeedsDisplay()
    }
}
