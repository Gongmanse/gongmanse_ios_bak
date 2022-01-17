import AVFoundation
import UIKit
import FBSDKShareKit
import FBSDKCoreKit
import KakaoSDKCommon
import KakaoSDKLink
import KakaoSDKTemplate

protocol LessonInfoControllerDelegate: AnyObject {
    func videoVCPauseVideo()
    func videoVCPassCurrentVideoTimeToLessonInfo()
    func LessonInfoPassCurrentVideoTimeInPIP(_ currentTime: CMTime)
    func problemSolvingLectureVideoPlay(videoID: String)
    
    func needUpdateRating()
}

class LessonInfoController: UIViewController {
    // MARK: - Properties
    
    var _parent: VideoController?
    var pipVideoData: PIPVideoData? // PIP 재생을 위해 필요한 구조체
    var seriesID: String?
    var thumbnail: String?
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
    public var tagsWidth: CGFloat = 0.0
    public var tagsHeight : NSLayoutConstraint?
    public var sTagsArray = [String]() {
        didSet {
            // 패드에서 태그 줄바꿈 처리를 위한 내용 추가
            if UIDevice.current.userInterfaceIdiom == .pad {
                let fontSize = 18.0
                tagsWidth = 0.0
                for item in sTagsArray {
                    let itemSize = item.size(withAttributes: [NSAttributedString.Key.font: UIFont.appBoldFontWith(size: fontSize)])
                    tagsWidth += itemSize.width
                }
                // 간격합친 총 너비 계산
                tagsWidth += CGFloat(sTagsArray.count - 1) * 10.0
                
                // 패딩 제외한 공간에 배치할 경우 예상되는 라인 수 계산하여 * 30
                let tagHeight = (tagsWidth / (Constant.width - 60)).rounded(.up) * 30
                tagsHeight!.constant = tagHeight
                
                if !UIWindow.isLandscape {
                    _parent?.teacherInfoUnfoldConstraint?.constant = 160 + tagHeight
                }
            }
            
            sTagsCollectionView?.reloadData()
        }
    }
    
    let buttonSize = CGRect(x: 0, y: 0, width: 40, height: 40)
    public var teachernameLabel = PlainLabel("김우성 선생님", fontSize: 11.5)
    public var lessonnameLabel = UILabel() //PlainLabel("분석명제와 종합명제", fontSize: 17)
    public var sTagsCollectionView: UICollectionView?
    private lazy var marginView = UIView()
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
    public lazy var problemSolvingButton = TopImageBottomTitleView(frame: buttonSize,
                                                                    title: "문제풀이",
                                                                    image: UIImage(named: "question")!)
    // videoID
    var videoID: String?
    
    // 문제풀이 누를 때 이름바꾸는 변수
    var isChangedName: Bool = false {
        didSet {
            problemSolvingButton.titleLabel.text = isChangedName ? "개념정리" : "문제풀이"
        }
    }
    
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
                rateLessonButton.viewTintColor = .mainOrange
            } else {
                rateLessonButton.viewTintColor = .black
            }
            rateLessonButton.titleLabel.text = userRating?.withDouble()
        }
    }
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(videoID: String?) {
        super.init(nibName: nil, bundle: nil)
        self.videoID = videoID
        print("init videoID : \(String(describing: self.videoID))")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
//        videoDetailVM?.requestVideoDetailApi(videoID ?? "", problemSolvingButton, completion: {
//            self.isChangedName = self.videoDetailVM?.detailModel?.data.iHasCommentary ?? "" == "0"
//        })
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
        
        pipDataManager.currentVideoCMTime = CMTime() //초기화
    }
    
    // MARK: - Actions
    
    // TODO: 정상적으로 Action 메소드가 호출되는지 TEST -> 05.03 OK
    @objc func presentClickedTagSearchResult() {
        present(TestSearchController(clickedText: "테스트중"), animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

//        if UIDevice.current.orientation.isLandscape {
            sTagsCollectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//        }
        
        // rotate 시 size 재설정
        if UIDevice.current.userInterfaceIdiom == .pad {
            let buttonHeight: CGFloat
            let buttonWidth: CGFloat
            if UIDevice.current.orientation.isLandscape {
                print("set font size Landscape in pad")
                buttonHeight = view.frame.height * 0.14
                buttonWidth = view.frame.height * 0.14
                lessonnameLabel.font = UIFont.appBoldFontWith(size: 22)
                teachernameLabel.font = UIFont.appBoldFontWith(size: 15.5)
                
                bookmarkButton.titleLabel.font = UIFont.appBoldFontWith(size: 16)
                rateLessonButton.titleLabel.font = UIFont.appBoldFontWith(size: 16)
                shareLessonButton.titleLabel.font = UIFont.appBoldFontWith(size: 16)
                relatedSeriesButton.titleLabel.font = UIFont.appBoldFontWith(size: 16)
                problemSolvingButton.titleLabel.font = UIFont.appBoldFontWith(size: 16)
                
                sSubjectLabel.font = UIFont.appBoldFontWith(size: 18)
                sUnitLabel01.font = UIFont.appBoldFontWith(size: 18)
                sUnitLabel02.font = UIFont.appBoldFontWith(size: 18)
                
                marginView.setDimensions(height: 20, width: 15)
            } else {
                print("set font size Portrait in pad")
                buttonHeight = view.frame.width * 0.13
                buttonWidth = view.frame.width * 0.13
                lessonnameLabel.font = UIFont.appBoldFontWith(size: 20)
                teachernameLabel.font = UIFont.appBoldFontWith(size: 13.5)
                
                bookmarkButton.titleLabel.font = UIFont.appBoldFontWith(size: 14)
                rateLessonButton.titleLabel.font = UIFont.appBoldFontWith(size: 14)
                shareLessonButton.titleLabel.font = UIFont.appBoldFontWith(size: 14)
                relatedSeriesButton.titleLabel.font = UIFont.appBoldFontWith(size: 14)
                problemSolvingButton.titleLabel.font = UIFont.appBoldFontWith(size: 14)
                
                sSubjectLabel.font = UIFont.appBoldFontWith(size: 15.5)
                sUnitLabel01.font = UIFont.appBoldFontWith(size: 15.5)
                sUnitLabel02.font = UIFont.appBoldFontWith(size: 15.5)
                
                marginView.setDimensions(height: 10, width: 10)
            }
            
            bookmarkButton.setDimensions(height: buttonHeight, width: buttonWidth)
            rateLessonButton.setDimensions(height: buttonHeight, width: buttonWidth)
            shareLessonButton.setDimensions(height: buttonHeight, width: buttonWidth)
            relatedSeriesButton.setDimensions(height: buttonHeight, width: buttonWidth)
            problemSolvingButton.setDimensions(height: buttonHeight, width: buttonWidth)
        }
        
        sTagsCollectionView?.reloadData()
    }
    
    @objc func handleBookmarkAction(sender: UIView) {
        if !Constant.isLogin {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
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
        if !Constant.isLogin {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        // "관련시리즈" 를 클릭했을 때, 영상 재생시간을 "VideoController"로 부터 가져온다.
//        delegate?.videoVCPassCurrentVideoTimeToLessonInfo()
        
//        if rateLessonButton.titleLabel.text != "평점" {
//            rateLessonButton.viewTintColor = .mainOrange
//        } else {
//            rateLessonButton.viewTintColor = .black
//        }
        
        guard let videoID = self.videoID else { return }
       
        let vc = RatingController(videoID: Int(videoID) ?? 1)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        
        // 변동가능성 있는 부분
//        rateLessonButton.viewTintColor = .mainOrange
        rateLessonButton.titleLabel.text = userRating?.withDouble()
        
        if let myRatingPoint = myRating {
            vc.initPoint = Int(myRatingPoint) ?? 3
            vc.myRating = myRating
        }
        
        vc.userRating = userRating
        
        present(vc, animated: false)
    }
    
    @objc func handleShareLessonAction() {
        // 클릭 시, 클릭에 대한 상태를 나타낼필요가 없으므로 검정색으로 유지시켰다.
        if !Constant.isLogin {
            presentAlert(message: "로그인후 이용해주세요.")
            return
        }
                
        if videoID == nil || videoID!.isEmpty {
            presentAlert(message: "영상이 준비되지 않았습니다.")
            return
        }
        
        ShareDialog.show(self) { _type in
            ShareDataManager().getShareCount(Constant.token) { countFiltered in
                if countFiltered < 5 {
                    self.getShareURL(_type: _type)
                } else {
                    self.presentAlert(message: "하루에 5회만 공유가 가능합니다. 내일 다시 시도해주세요.")
                }
            }
        }
    }

    @objc func handleRelatedSeriesAction() {
        
        //guard let indexVideoData = detailVideo?.data else { return }
        if seriesID == "0" {
            presentAlert(message: "관련 시리즈가 없습니다.")
            return
        }
        let _ = VideoDataManager.shared
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        } else if Constant.isLogin == true {
            delegate?.videoVCPassCurrentVideoTimeToLessonInfo()
            delegate?.videoVCPauseVideo()
            let presentVC = LecturePlaylistVC(videoID ?? "")
            presentVC.lectureState = .lectureList
            presentVC.seriesID = seriesID
            let pipVideoData = PIPVideoData(isPlayPIP: true,
                                            videoURL: currentVideoURL,
                                            currentVideoTime: currentVideoPlayTime ?? Float(0.0),
                                            videoTitle: lessonnameLabel.text ?? "",
                                            teacherName: teachernameLabel.text ?? "")
            presentVC.pipData = pipVideoData
            let nav = UINavigationController(rootViewController: presentVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            // TODO: 관련시리즈를 켠다.
        } else if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else {
            presentAlert(message: "로그인 후 이용해주세요.")
        }
    }
    
    @objc func handleProblemSolvingAction() {
        // TODO: Delegation을 이용해서,영상의 URL의 네트워킹을 통해 변경해주면 될 것 같다.
        // ex) 재생목록 영상 바꾸듯이.
        
        //비로그인
        if Constant.isGuestKey || Constant.remainPremiumDateInt == nil {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        isChangedName = !isChangedName
        
        problemSolvingButton.titleLabel.text = isChangedName ? "개념정리" : "문제풀이"
        
        videoDetailVM?.isCommentary = isChangedName
        VideoDataManager.shared.removeVideoLastLog()
        
        switch isChangedName {
        case true: // 문제풀이
//            videoDetailVM?.requestVideoDetailApi(videoDetailVM?.commantaryID ?? "", problemSolvingButton, completion: {
//                self.isChangedName = self.videoDetailVM?.detailModel?.data.iHasCommentary ?? "" == "0"
//            })
            
            delegate?.problemSolvingLectureVideoPlay(videoID: videoDetailVM?.commantaryID ?? "15188")
            
        case false: // 개념정리
//            videoDetailVM?.requestVideoDetailApi(videoDetailVM?.commantaryID ?? "", problemSolvingButton, completion: {
//                self.isChangedName = self.videoDetailVM?.detailModel?.data.iHasCommentary ?? "" == "0"
//            })
            
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

        // API에서 받아온 값을 레이블에 할당한다.
        sSubjectLabel.labelText = "과목명"
        sUnitLabel01.labelText = "단원명"
//        sUnitLabel02.labelText = "챕터명"
        
        // TODO: 정상적으로 view가 보이는지 TEST -> 05.03 OK
        view.backgroundColor = #colorLiteral(red: 0.9293201566, green: 0.9294758439, blue: 0.9292996526, alpha: 1)
        
        // TODO: [UI] 강의 태그 -> 05.04 OK
        view.addSubview(sSubjectsUnitContainerView)
        sSubjectsUnitContainerView.setDimensions(height: 25,
                                                 width: view.frame.width - 60)
        sSubjectsUnitContainerView.anchor(top: view.topAnchor,
                                          left: view.leftAnchor,
                                          right: view.rightAnchor,
                                          paddingTop: 10, paddingLeft: 30, paddingRight: 30)
        
        sSubjectLabel.layer.cornerRadius = 11.5
        sSubjectsUnitContainerView.addSubview(sSubjectLabel)
        sSubjectLabel.anchor(top: sSubjectsUnitContainerView.topAnchor,
                             left: sSubjectsUnitContainerView.leftAnchor,
                             paddingLeft: 0,
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
        lessonnameLabel.numberOfLines = 1
        lessonnameLabel.lineBreakMode = .byTruncatingTail
        if UIDevice.current.userInterfaceIdiom == .pad {
            lessonnameLabel.font = UIFont.appBoldFontWith(size: 20)
        } else {
            lessonnameLabel.font = UIFont.appBoldFontWith(size: 17)
        }
        lessonnameLabel.anchor(top: sSubjectLabel.bottomAnchor,
                               left: sSubjectLabel.leftAnchor,
                               right: sSubjectsUnitContainerView.rightAnchor,
                               paddingTop: 10, paddingLeft: 0, paddingRight: 0)
        
        // TODO: [UI] 해쉬 태그 -> 05.04 UI 완성
        let tagHeight:CGFloat!
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            layout.scrollDirection = .vertical
            tagHeight = 30.0
        } else {
            layout.scrollDirection = .horizontal
            tagHeight = 20.0
        }
        layout.itemSize.height = 20
        sTagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(sTagsCollectionView ?? UICollectionView())

        tagsHeight = sTagsCollectionView?.heightAnchor.constraint(equalToConstant: tagHeight)
        tagsHeight!.isActive = true
        
        sTagsCollectionView?.centerX(inView: view)
        sTagsCollectionView?.anchor(top: lessonnameLabel.bottomAnchor,
                                    left: lessonnameLabel.leftAnchor,
                                    paddingTop: 10, paddingLeft: 0)
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
        let buttonHeight: CGFloat
        let buttonWidth: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            buttonHeight = 65
            buttonWidth = 65
            
            view.addSubview(marginView)
            marginView.anchor(top: sTagsCollectionView?.bottomAnchor,
                              left: view.leftAnchor,
                              right: view.rightAnchor,
                              paddingLeft: 30,
                              paddingRight: 30)
            marginView.setDimensions(height: 10, width: 10)
            
            view.addSubview(stack)
            stack.isUserInteractionEnabled = true
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .horizontal
            stack.spacing = 10
            stack.distribution = .fillEqually
            stack.setDimensions(height: buttonHeight * 1.2, width: view.frame.width - 60)
            stack.anchor(top: marginView.bottomAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingLeft: 30,
                         paddingRight: 30)
        } else {
            buttonHeight = view.frame.width * 0.12
            buttonWidth = view.frame.width * 0.1
            
            view.addSubview(stack)
            stack.isUserInteractionEnabled = true
            stack.distribution = .equalSpacing
            stack.axis = .horizontal
            stack.spacing = 0
            stack.alignment = .leading
            stack.centerX(inView: view)
    //        stack.setDimensions(height: buttonHeight, width: view.frame.width - 60)
            stack.setHeight(buttonHeight * 1.2)
            view.addSubview(marginView)
            
            marginView.anchor(top: sTagsCollectionView?.bottomAnchor, left: sTagsCollectionView?.leftAnchor)
            marginView.setDimensions(height: 10, width: 10)
            
            stack.anchor(top: marginView.bottomAnchor, left: marginView.leftAnchor)
        }
        
        bookmarkButton.setDimensions(height: buttonHeight, width: buttonWidth)
        rateLessonButton.setDimensions(height: buttonHeight, width: buttonWidth)
        shareLessonButton.setDimensions(height: buttonHeight, width: buttonWidth)
        relatedSeriesButton.setDimensions(height: buttonHeight, width: buttonWidth)
        problemSolvingButton.setDimensions(height: buttonHeight, width: buttonWidth)
    }
    
    func getShareURL(_type: Int) {
        ShareDataManager().getShareURL(videoID!) { shareUrl in
            if _type == 1 {
                self.shareFacebook(shareUrl)
            } else {
                self.shareKakaoTalk(shareUrl)
            }
        }
    }
    
    func shareFacebook(_ shareUrl: String) {
        let content = ShareLinkContent()
        content.contentURL = URL(string: shareUrl)!
        content.quote = "[강추!] 혼자 보기 아까운 공만세 강의를 추천합니다. 우리 함께 보아요~"
        
        let dialog = FBSDKShareKit.ShareDialog(fromViewController: self, content: content, delegate: self)
        dialog.mode = .automatic
        if dialog.canShow {
            dialog.show()
        }
    }
    
    func shareKakaoTalk(_ shareUrl: String) {
        let link = Link(webUrl: URL(string:shareUrl),
                        mobileWebUrl: URL(string:shareUrl))
        let button = Button(title: "웹으로 보기", link: link)
        
        let content = Content(title: self.lessonnameLabel.text!,
                              imageUrl: URL(string:self.thumbnail!)!,
                              imageWidth: 640,
                              imageHeight: 360,
                              description: "[강추!] 혼자 보기 아까운 공만세 강의를 추천합니다. 우리 함께 보아요~",
                              link: link)
        let feedTemplate = FeedTemplate(content: content, social: nil, buttons: [button])

        //메시지 템플릿 encode
        if let feedTemplateJsonData = (try? SdkJSONEncoder.custom.encode(feedTemplate)) {

            //생성한 메시지 템플릿 객체를 jsonObject로 변환
            if let templateJsonObject = SdkUtils.toJsonObject(feedTemplateJsonData) {
                LinkApi.shared.defaultLink(templateObject:templateJsonObject) {(linkResult, error) in
                    if error != nil {
                        self.presentAlert(message: "카카오톡 공유가 실패되었습니다.")
                    }
                    else {
                        print("defaultLink(templateObject:templateJsonObject) success.")

                        //do something
                        guard let linkResult = linkResult else { return }
                        UIApplication.shared.open(linkResult.url, options: [:]) { result in
                            if result {
                                self.updateShareCount("kakao")
                            } else {
                                self.presentAlert(message: "카카오톡 공유가 실패되었습니다.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateShareCount(_ _type: String) {
//        const val CONTENT_SHARE_SNS_TYPE_KK      = "kk"
//        const val CONTENT_SHARE_SNS_TYPE_FB      = "fb"
        let socialType: String
        if _type == "kakao" {
            socialType = "kk"
        } else if _type == "facebook" {
            socialType = "fb"
        } else {
            self.presentAlert(message: "공유가 실패되었습니다.")
            return
        }
        
        ShareDataManager().updateShareCount(Constant.token, videoID!, socialType) {
            
        }
    }
}

extension LessonInfoController: SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("FaceBook 공유 성공")
        self.updateShareCount("facebook")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        self.presentAlert(message: "페이스북 공유가 실패되었습니다.")
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        self.presentAlert(message: "페이스북 공유가 취소되었습니다.")
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
        let fontSize: CGFloat!
        if UIDevice.current.userInterfaceIdiom == .pad {
            fontSize = 18
        } else {
            fontSize = 15
        }
        let item = sTagsArray[indexPath.row]
        let itemSize = item.size(withAttributes: [NSAttributedString.Key.font: UIFont.appBoldFontWith(size: fontSize)])
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
//        let videoDataManager = VideoDataManager.shared
//        videoDataManager.isFirstPlayVideo = false
        
        // "sTags" 를 클릭했을 때, 영상 재생시간을 "VideoController"로 부터 가져온다.
        delegate?.videoVCPassCurrentVideoTimeToLessonInfo()
        
        // 클릭한 키워드를 입력한다.
        let data = sTagsArray[indexPath.row]
        
        // 재생중이던 영상을 일시중지한다. 동시에, PIP를 재생한다. -> Delegation 필요 -> 완료
        delegate?.videoVCPauseVideo()

        let vc = SearchAfterVC()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        vc.searchData.searchText = data.replacingOccurrences(of: "#", with: "")

        guard let videoURL = currentVideoURL else { return }
        
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
//        rateLessonButton.titleLabel.text = "평점"
//        rateLessonButton.viewTintColor = .black
        view.setNeedsDisplay()
    }
    
    func ratingAvaergePassVC(rating: String) {
        myRating = rating
//        rateLessonButton.titleLabel.text = rating
//        rateLessonButton.viewTintColor = .mainOrange
//        view.setNeedsDisplay()
        
        //내 점수가 아닌 유저들의 평균점수 userRating을 보여줘야 한다
        //userRating을 다시 가져오자
        delegate?.needUpdateRating()
        
        self._parent?.presentAlert(message: "평점이 적용되었습니다.")
    }
}
