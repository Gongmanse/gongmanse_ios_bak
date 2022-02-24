//
//  LecturePlaylistVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/16.
//

import UIKit
import AVKit

enum LectureState {
    case lectureList
    case videoList //사용안함
}

private let cellId = "LectureCell"

class LecturePlaylistVC: UIViewController {
    //MARK: - auto play videoCell
    var visibleIP : IndexPath?
    var seekTimes = [String:CMTime]()
    var lastContentOffset: CGFloat = 0
    
    // MARK: - Properties
    
    // MARK: PIP
    var pipVC: PIPController?
    var pipData: PIPVideoData? {
        didSet { configurePIPView(pipData: pipData) }
    }
    
    
    var lectureState: LectureState?
    
    // 강사별 강의
    var getTeacherList: LectureSeriesDataModel?
    var seriesID: String? {
        didSet {
//            print(seriesID)
//
//            isLoading = true
//            detailVM?.lectureDetailApi(seriesID ?? "", offset: 0)
        }
        
    }
    var totalNum: String?
    var gradeText: String?
    var detailVM: LectureDetailViewModel? = LectureDetailViewModel()
    
    
    // Infinity Scroll
    var listCount: Int = 0
    var isLoading = false
    
    // 관련시리즈
    lazy var videoNumber: String = ""
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var ct_margin_bottom: NSLayoutConstraint! //7, 35
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    @IBOutlet weak var lbAutoPlay: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var colorView: UIStackView!
    @IBOutlet weak var ct_bottom_margin: NSLayoutConstraint!
    @IBOutlet weak var scrollBtn: UIButton!
    
    var isAutoScroll = false
    @IBAction func scrollToTop(_ sender: Any) {
        if visibleIP != nil {
            print("LecturePlaylistVC scrollToTop. stop play")
            stopCurrentVideoCell()
        }
        isAutoScroll = true
        self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    // MARK: - Lifecylce
    
    // 강사별강의에서 값 넘겨받음
    init(_ teacherModel: LectureSeriesDataModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.getTeacherList = teacherModel
    }
    
    // 비디오 영상에서 ID받음
    init(_ videoID: String) {
        super.init(nibName: nil, bundle: nil)
        
        videoNumber = videoID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 목록이 없습니다.
    private let lectureQnALabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        label.textAlignment = .center
        label.font = .appBoldFontWith(size: 16)
        label.text = "관련 시리즈 내용이 없습니다."
        return label
    }()
    
    private let emptyAlert: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "alert")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let emptyStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    // MARK: PIP
    private let pipContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.gray.cgColor
        view.alpha = 0
        return view
    }()
    
    private var isPlayPIPVideo: Bool = false
    private let pipPlayPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(playPauseButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let xButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(xButtonDidTap), for: .touchUpInside)
        return button
    }()
    
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
                
        // 동영상 - 관련시리즈
        if seriesID != "" {
            
            let seriesInfo = detailVM?.lectureDetail?.seriesInfo
            
            switch seriesInfo {
            
            case .some(let data):
                
//                if Constant.remainPremiumDateInt != nil {
                    titleText.text = data.sTitle
                    teacherName.text = "\(data.sTeacher ?? "") 선생님"
                    subjectLabel.text = data.sSubject
                    gradeLabel.text = detailVM?.convertGrade(data.sGrade)
                    gradeLabel.textColor = UIColor(hex: data.sSubjectColor ?? "000000")
                    colorView.backgroundColor = UIColor(hex: data.sSubjectColor ?? "000000")
                    configurelabel(value: detailVM?.lectureDetail?.totalNum ?? "")
//                }
                emptyStackView.isHidden = true
            case .none:
                view.addSubview(emptyStackView)
                emptyStackView.addArrangedSubview(emptyAlert)
                emptyStackView.addArrangedSubview(lectureQnALabel)
                
                emptyStackView.translatesAutoresizingMaskIntoConstraints = false
                emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                emptyStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
                emptyStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            }
        }
        // 강사별 강의
        if let getTeacher = getTeacherList {
            
            configurelabel(value: totalNum ?? "")
            
            titleText.text = getTeacher.sTitle
            teacherName.text = "\(getTeacher.sTeacher ?? "") 선생님"
            subjectLabel.text = getTeacher.sSubject
            gradeLabel.text = detailVM?.convertGrade(gradeText)
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavi()             // navigation 관련 설정
        configureUI()               // 태그 UI 설정
        collectionView.delegate = self
        collectionView.dataSource = self
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        
        // UISwitch UI 속성 설정
        autoPlaySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        autoPlaySwitch.onTintColor = .mainOrange
        
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
//        isLoading = true
        detailVM?.lectureDetailApi(seriesID ?? "", offset: 0)
        detailVM?.delegate = self
        
        if videoNumber != "" {
            isLoading = true
            detailVM?.relationSeries(videoNumber, offset: 0)
        }
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
    }
    
    // 탭 이동 시 자동 재생제어
    var isGuest = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        isLoading = true
//        detailVM?.lectureDetailApi(seriesID ?? "", offset: 0)
//        collectionView.reloadData()
        
        if let pipVC = self.pipVC {
            if !isPlayPIPVideo {
                isPlayPIPVideo = true
                pipVC.player?.play()
            }
        }
        
        print("LecturePlaylistVC viewDidAppear")
        isGuest = Constant.isLogin == false || Constant.remainPremiumDateInt == nil
        if isGuest { print("isGuest") }
    }
    private func startFirstVideoCell(ip: IndexPath) {
        if visibleIP?.item != ip.item {// 재생중인 파일 비교
            if visibleIP != nil {
                let beforeVideoCell = collectionView.cellForItem(at: visibleIP!) as? LectureCell
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
            }
            
            // 첫번째 아이템 재생 처리
            visibleIP = ip
            let afterVideoCell = (collectionView.cellForItem(at: visibleIP!) as! LectureCell)
            afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("LecturePlaylistVC viewDidDisappear")
        guard visibleIP != nil else { return }
        stopCurrentVideoCell()
    }
    
    fileprivate func stopCurrentVideoCell() {
        if let videoCell = collectionView.cellForItem(at: visibleIP!) as? LectureCell {
            let seekTime = videoCell.avPlayer?.currentItem?.currentTime()
            if seekTime?.seconds ?? 0 > 0 {
                seekTimes[videoCell.videoID] = seekTime
            }
            videoCell.stopPlayback(isEnded: false)
            
        }
        visibleIP = nil
    }
    
    
    // MARK: - Actions
    
    // 뒤로가기 버튼 로직
    @objc func dismissVC() {
        
        if let _ = self.pipVC {
//            pipVC.player?.pause()
            
            //0711 - edit by hp
            setRemoveNotification()
            dismissLecturePlaylistVCOnPlayingPIP()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func pipViewDidTap(_ sender: UITapGestureRecognizer) {
        
        setRemoveNotification()
        dismissLecturePlaylistVCOnPlayingPIP()
    }
    
    @objc func xButtonDidTap() {
        
        if let pipVC = self.pipVC {
            isPlayPIPVideo = !isPlayPIPVideo
            pipVC.player?.pause()
        }
        
        UIView.animate(withDuration: 0.33) {
            self.pipContainerView.alpha = 0
            self.ct_bottom_margin.constant = 0
        }
    }
    
    @objc func playPauseButtonDidTap() {
        isPlayPIPVideo = !isPlayPIPVideo
        
        //0713 - edited by hp
        if isPlayPIPVideo {
            pipVC?.player?.play()
            pipPlayPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            pipVC?.player?.pause()
            pipPlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        
        // subjectLabel
        subjectLabel.font = .appBoldFontWith(size: 8)
        subjectLabel.textColor = .white
        
        // gradeLabel
        gradeLabel.backgroundColor = .white
        gradeLabel.font = .appBoldFontWith(size: 8)
        gradeLabel.adjustsFontSizeToFitWidth = true
        gradeLabel.clipsToBounds = true
        gradeLabel.layer.cornerRadius = 9
        gradeLabel.textColor = UIColor(hex: getTeacherList?.sSubjectColor ?? "000000")
        
        // subjectColor
        colorView.backgroundColor = UIColor(hex: getTeacherList?.sSubjectColor ?? "000000")
        colorView.layer.cornerRadius = colorView.frame.size.height / 2
        colorView.layoutMargins = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        colorView.isLayoutMarginsRelativeArrangement = true
        
        titleText.font = .appEBFontWith(size: 17)
        teacherName.font = .appBoldFontWith(size: 12)
    }
    
    func configureNavi() {
        let title = UILabel()
        title.text = videoNumber != "" ? "관련 시리즈" : "강사별 강의"
        ct_margin_bottom.constant = videoNumber != "" ? 45 : 7
        
        autoPlaySwitch.isHidden = videoNumber.isEmpty
        lbAutoPlay.isHidden = videoNumber.isEmpty
        
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
        
        // navigationItem Back button
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = backButton
    }
    
    
    // UILabel 부분 속성 변경 메소드
    func configurelabel(value: String) {
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "총 ",
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        
        attributedString.append(NSAttributedString(string: value,
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange.cgColor]))
        
        attributedString.append(NSAttributedString(string: " 개",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        numberOfLesson.attributedText = attributedString
    }
    
    func configurePIPView(pipData: PIPVideoData?) {
        
        let pipDataManager = PIPDataManager.shared
        
        let videoDataManager = VideoDataManager.shared
        
//        let pipData = PIPVideoData(isPlayPIP: true,
//                                   videoURL: videoDataManager.previousVideoURL,
//                                   currentVideoTime: pipDataManager.currentVideoTime ?? Float(),
//                                   videoTitle: pipDataManager.currentVideoTitle ?? "",
//                                   teacherName: videoDataManager.previousVideoTeachername ?? "")
        
        let pipHeight = Constant.height * 0.085
        self.pipVC = PIPController(isPlayPIP: true)
        guard let pipVC = self.pipVC else { return }
        pipVC.pipVideoData = pipData
        
        //0713 - added by hp
        //영상 재생/일시정지 버튼 이슈관련 해결
        self.isPlayPIPVideo = true
        pipPlayPauseButton.setImage(UIImage(systemName: isPlayPIPVideo ? "pause" : "play.fill"), for: .normal)
        
        /* pipContainerView - Constraint */
        view.addSubview(pipContainerView)
        pipContainerView.alpha = 1
        pipContainerView.anchor(left: view.leftAnchor,
                                bottom: view.bottomAnchor,
                                right: view.rightAnchor,
                                height: pipHeight)
        
        let pipTapGesture = UITapGestureRecognizer(target: self, action: #selector(pipViewDidTap))
        pipContainerView.addGestureRecognizer(pipTapGesture)
        pipContainerView.isUserInteractionEnabled = true
        
        /* pipVC.view - Constraint  */
        pipContainerView.addSubview(pipVC.view)
        pipVC.view.anchor(top:pipContainerView.topAnchor)
        pipVC.view.centerY(inView: pipContainerView)
        pipVC.view.setDimensions(height: pipHeight,
                                 width: pipHeight * 1.77)
        
        /* xButton - Constraint */
        pipContainerView.addSubview(xButton)
        xButton.setDimensions(height: 25,
                              width: 25)
        xButton.centerY(inView: pipContainerView)
        xButton.anchor(right: pipContainerView.rightAnchor,
                       paddingRight: 5)
        
        /* pipPlayPauseButton - Constraint*/
        pipContainerView.addSubview(pipPlayPauseButton)
        pipPlayPauseButton.setDimensions(height: 25,
                                         width: 25)
        pipPlayPauseButton.centerY(inView: xButton)
        pipPlayPauseButton.anchor(right: xButton.leftAnchor,
                                  paddingRight: 10)
        
        /* lessonTitleLabel - Constraint */
        pipContainerView.addSubview(lessonTitleLabel)
        lessonTitleLabel.anchor(left: pipContainerView.leftAnchor,
                                right: pipContainerView.rightAnchor,
                                paddingLeft: pipHeight * 1.77 + 5,
                                paddingRight: 70,
                                height: 17)
        lessonTitleLabel.center(inView: pipContainerView, yConstant: -10)
        lessonTitleLabel.text = pipData?.videoTitle
        
        /* teachernameLabel - Constraint */
        pipContainerView.addSubview(teachernameLabel)
        teachernameLabel.anchor(left: lessonTitleLabel.leftAnchor,
                                height: 15)
        teachernameLabel.center(inView: pipContainerView, yConstant: 10)
        teachernameLabel.text = pipData?.teacherName ?? "" + " 선생님"
        
        ct_bottom_margin.constant = view.frame.height * 0.085
    }
    
    func setRemoveNotification() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    /// PIP 영상이 실행되고 있는데, 이전 영상화면으로 돌아가고 싶은 경우 호출하는 메소드
    func dismissLecturePlaylistVCOnPlayingPIP() {
        // 1 PIP 영상을 제거한다.
        
        // 2 PIP-Player에서 현재까지 재생된 시간을 SingleTon 에 입력한다.
        let pipDataManager = PIPDataManager.shared
        guard let pipVC = self.pipVC else { return }
        
        isPlayPIPVideo = !isPlayPIPVideo
        pipVC.pipVideoData?.isPlayPIP = false
        pipVC.player?.pause()
        setRemoveNotification()
        // 3 싱글톤 객체 프로퍼티에 현재 재생된 시간을 CMTime으로 입력한다.
        pipDataManager.currentVideoCMTime = pipVC.currentVideoTime
        pipDataManager.isForcePlay = true
        dismiss(animated: false)
    }
}


extension LecturePlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch lectureState {
        
        case .lectureList:
            return detailVM?.lectureDetail?.data.count ?? 0
            
        case .videoList:
            return detailVM?.relationSeriesList?.data.count ?? 0
            
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch lectureState {
        case .lectureList:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LectureCell
            guard let detailSeriesData = detailVM?.lectureDetail?.data[indexPath.row] else {
                return UICollectionViewCell() }
//            print(detailSeriesData.sTeacher)
            cell.setSeriesCellData(detailSeriesData)
            cell.delegate = self
            return cell
        case .videoList:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LectureCell
            guard let detailVideoData = detailVM?.relationSeriesList?.data[indexPath.row] else {
                return UICollectionViewCell() }
            
            cell.setVideoCellData(detailVideoData)
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 자동 재생 중지
        if visibleIP != nil {
            stopCurrentVideoCell()
        }
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        switch lectureState {
        case .lectureList:
            
            if Constant.remainPremiumDateInt != nil {
                //0711 - added by hp - pip
                if let receviedVideoID = self.detailVM?.lectureDetail?.data[indexPath.row].id {
                
                    //관련시리즈는 자동재생 on/off 상관없이
                    let autoPlayDataManager = AutoplayDataManager.shared
                    autoPlayDataManager.currentViewTitleView = "강사별강의"
                    autoPlayDataManager.isAutoPlay = false
                    autoPlayDataManager.videoDataList.removeAll()
                    autoPlayDataManager.videoSeriesDataList.removeAll()
                    autoPlayDataManager.currentIndex = indexPath.row
                    
                    if self.videoNumber != "" { //관련시리즈 일때만, 강사별강의는 X
                        VideoDataManager.shared.isFirstPlayVideo = false
                        
                        isPlayPIPVideo = !isPlayPIPVideo
                        pipVC?.player?.pause()
                        setRemoveNotification()
                        PIPDataManager.shared.currentVideoCMTime = CMTime()
                        PIPDataManager.shared.currentVideoTime = pipVC?.currentVideoTimeAsFloat
                        
                        //video->lectureplaylist->video 와 같은 현상을 방지하기 위한
                        let vc = self.presentingViewController as! VideoController
                        self.dismiss(animated: false) {
                            vc.id = receviedVideoID
                            vc.configureDataAndNoti(true)
                        }
                        return
                    }
                    
                    // 비디오 연결
                    let vc = VideoController()
                    vc.id = receviedVideoID
                    if let seekTime = seekTimes[receviedVideoID] {
                        print("set seekTime \(seekTime.seconds)")
                        vc.autoPlaySeekTime = seekTime
                        vc.isStartVideo = true
        //            print("vc.seekTime 1 : \(String(describing: vc.autoPlaySeekTime)), \(String(describing: vc.autoPlaySeekTime?.timescale))")
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true)
                }
                return
            } else {
                presentAlert(message: "이용권을 구매해주세요")
            }
            
        case .videoList: //사용안함
            
            if Constant.isLogin == false {
                presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
                return
            }
            
            if Constant.remainPremiumDateInt != nil {
                
                /**
                 검색결과 화면에서 영상을 클릭할 때, rootView를 초기화하는 이유
                 - 영상 > 검색결과 > 영상
                 이런식으로 넘어오다보니 영상관련 Controller 가 너무 많아져서 메모리 관리가 어려움
                 - 그래서 rootView를 변경하는 식으로 구현
                 */
                
                //  UIApplication 에서 화면전환을 한다,
                guard let topVC = UIApplication.shared.topViewController() else { return }
                NotificationCenter.default.removeObserver(self)
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
                
                
                
                // 싱글톤 객체에 들어간 데이터를 초기화한다.
                
                let videoDataManager = VideoDataManager.shared
                
                
                
                let _ = PIPDataManager.shared
    //            pipDataManager.currentTeacherName = nil
    //            pipDataManager.currentVideoURL = nil
    //            pipDataManager.currentVideoCMTime = nil
    //            pipDataManager.currentVideoID = nil
    //            pipDataManager.currentVideoTitle = nil
    //            pipDataManager.previousVideoID = nil
    //            pipDataManager.previousTeacherName = nil
    //            pipDataManager.previousVideoURL = nil
    //            pipDataManager.previousVideoTitle = nil
    //            pipDataManager.previousVideoURL = nil
                
                // PIP를 dismiss한다.
                //            pipDelegate?.serachAfterVCPIPViewDismiss()
                isPlayPIPVideo = !isPlayPIPVideo
                pipVC?.player?.pause()
                pipVC?.removePeriodicTimeObserver()
                pipVC?.player = nil
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let mainTabVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                
                // TODO: video ID를 받아서 할당하고, PIPDataManager의 값들을 초기화한다.
                
                topVC.changeRootViewController(mainTabVC) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabVC2 = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                    mainTabVC2.modalPresentationStyle = .fullScreen
                    let vc = VideoController()
                    vc.modalPresentationStyle = .overFullScreen
                    videoDataManager.isFirstPlayVideo = false
                    let receviedVideoID = self.detailVM?.relationSeriesList?.data[indexPath.row].id
    //                let receviedVideoID = self.searchVideoVM.responseVideoModel?.data[indexPath.row].id
    //                let receviedVideoID = videoDataManager.currentVideoID
                    vc.id = receviedVideoID
                    
//                    let layout = UICollectionViewFlowLayout()
//                    vc.collectionViewLayout = layout
                    vc.modalPresentationStyle = .fullScreen
                    mainTabVC.present(mainTabVC2, animated: false) {
                        mainTabVC2.present(vc, animated: true)
                    }
                    
                }
                
            } else if Constant.isGuestKey || Constant.remainPremiumDateInt == nil  {
                presentAlert(message: "이용권을 구매해주세요.")
                return
            } else {
                presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            }
        default:
            return
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.frame.height < cell.frame.height * CGFloat(indexPath.row) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        switch lectureState {
        case .lectureList:
            guard let lectureCount = detailVM?.lectureDetail?.data.count else { return }
            if indexPath.row == lectureCount - 1 && !isLoading && (detailVM?.isMoreList ?? false) {
                listCount += 20
                
                isLoading = true
                detailVM?.lectureDetailApi(seriesID ?? "", offset: listCount)
            }
        case .videoList:
            guard let videoCount = detailVM?.relationSeriesList?.data.count else { return }
            if indexPath.row == videoCount - 1 && !isLoading {
                listCount += 20
                
                isLoading = true
                detailVM?.relationSeries(videoNumber, offset: listCount)
            }
        default:
            return
        }


    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isGuest {
            print("isGuest")
            return
        }
        if self.pipContainerView.alpha != 0 {
            print("pipVC is showing")
            return
        }
        
        let indexPaths = collectionView.indexPathsForVisibleItems.sorted(by: {$0.row < $1.row})
        var cells = [Any]()
        for ip in indexPaths {
            if let videoCell = collectionView.cellForItem(at: ip) as? LectureCell {
                cells.append(videoCell)
            }
        }
        
        let cellCount = cells.count
        if cellCount == 0 { return }
        
        // 최상단으로 스크롤된 경우 첫번째 아이템 재생
        if scrollView.contentOffset.y == 0 {
            print("LecturePlaylistVC reached the top of the scrollView, isAutoScroll : \(isAutoScroll)")
            
            if isAutoScroll {
                // auto scroll 시 재생되지 않도록 적용
                isAutoScroll = false
            } else {
                startFirstVideoCell(ip: IndexPath(item: 0, section: 0))
            }
            
//                let delay = isAutoScroll ? 0.3 : 0.0
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    // auto scroll 시 화면 그려진 이후에 재생되도록 딜레이 설정
//                    self.startFirstVideoCell(ip: IndexPath(item: 0, section: 0))
//                    self.isAutoScroll = false
//                }
            return
        }

        // 마지막 아이템까지 스크롤된 경우 마지막 아이템 재생
        // - 이전 재생 videoCell 이 65% 이상 가려지기 전에 다음 항목 재생되도록 별도 처리
        let heightSV = scrollView.frame.size.height
        let offSetY = scrollView.contentOffset.y
        let distanceFromBot = scrollView.contentSize.height - offSetY
        if distanceFromBot <= heightSV {// distanceFromBot == heightSV 인 순간 바닥점 터치.
            print("LecturePlaylistVC reached the bottom of the scrollView")
            if visibleIP != nil && visibleIP!.item != indexPaths[indexPaths.count - 1].item {
                let beforeVideoCell = collectionView.cellForItem(at: visibleIP!) as? LectureCell
                print("LecturePlaylistVC stop current item for bottom")
                if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                    if seekTime.seconds > 0 {
                        seekTimes[beforeVideoCell!.videoID] = seekTime
                    }
                }
                beforeVideoCell?.stopPlayback(isEnded: false)
                
                // 마지막 아이템 재생 처리
                visibleIP = indexPaths[indexPaths.count - 1]
                let afterVideoCell = (collectionView.cellForItem(at: visibleIP!) as! LectureCell)
                afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
            }
            return
        }

        if cellCount >= 2 {
//            print("cellCount : \(cellCount)")
            // 아이템 재생위치 계산
            if visibleIP == nil {// 발생하지 않을 케이스..
                print("LecturePlaylistVC play first item")
                let videoCell = cells[0] as! LectureCell
                visibleIP = indexPaths[0]
                videoCell.startPlayback(seekTimes[videoCell.videoID])
            } else {
                let beforeVideoCell = collectionView.cellForItem(at: visibleIP!) as? LectureCell
                let beforeCellVisibleH = beforeVideoCell?.frame.intersection(collectionView.bounds).height ?? 0.0
                
                // 자동 스크롤이 다음 파일 재생할만큼 충분하지 못한 경우가 있어 0.6 -> 0.65 로 수정
                if (beforeVideoCell != nil && beforeCellVisibleH < beforeVideoCell!.frame.height * 0.65) || beforeVideoCell == nil {
                    print("LecturePlaylistVC stop current item for next")
                    if let seekTime = beforeVideoCell?.avPlayer?.currentItem?.currentTime() {
                        if seekTime.seconds > 0 {
                            seekTimes[beforeVideoCell!.videoID] = seekTime
                        }
                    }
                    beforeVideoCell?.stopPlayback(isEnded: false)
                    
                    print("LecturePlaylistVC visibleIP!.row : \(visibleIP!.row)")
                    // 현재 화면에 보여지고있는 셀들 중에서 다음 재생할 파일 선택.
                    // 빠르게 스크롤 시 재생중이던 셀과 다음 재생하려고 하는 셀이 화면에 안보이는 상태일 수 있어 내용 수정.
                    var indexPath = IndexPath(row: indexPaths[1].row, section: 0)// 중간 데이터로 초기화
                    if (self.lastContentOffset > scrollView.contentOffset.y) {
                        print("LecturePlaylistVC move up")
                        for ip in indexPaths {
//                            print("LecturePlaylistVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 위 셀을 선택
                                var row = visibleIP!.row - 1
                                if row < 0 { row = 0 }
                                indexPath.row = row
                            }
                        }

                    }
                    else if (self.lastContentOffset < scrollView.contentOffset.y) {
                        print("LecturePlaylistVC move down")
                        for ip in indexPaths {
//                            print("LecturePlaylistVC indexPath.row : \(ip.row)")
                            if visibleIP!.row == ip.row {// 재생중이던 셀이 화면에 보인다면 바로 아래 셀을 선택
                                var row = visibleIP!.row + 1
                                if row == detailVM!.lectureDetail!.data.count { row = detailVM!.lectureDetail!.data.count - 1 }
                                indexPath.row = row
                            }
                        }
                    } else {
                        print("???")
                    }
                    self.lastContentOffset = scrollView.contentOffset.y
                    
                    visibleIP = indexPath
                    let afterVideoCell = (collectionView.cellForItem(at: visibleIP!) as! LectureCell)
                    afterVideoCell.startPlayback(seekTimes[afterVideoCell.videoID])
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying forItemAt = \(indexPath.row)")
        if let videoCell = cell as? LectureCell {
            if let seekTime = videoCell.avPlayer?.currentItem?.currentTime() {
                if seekTime.seconds > 0 {
                    seekTimes[videoCell.videoID] = seekTime
                }
            }
            videoCell.stopPlayback(isEnded: false)
        }
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension LecturePlaylistVC: UICollectionViewDelegateFlowLayout {
    
    
    // cell 간격을 설정하는 메소드(가로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //0707 - edited by hp
        return 25
    }
    
    // cell 간격을 설정하는 메소드(세로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    
    // Cell의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //0707 - edited by hp
        let width = UIScreen.main.bounds.width - 40
        return CGSize(width: width, height: width / 16 * 9 + 60)
    }
    
}

extension LecturePlaylistVC: CollectionReloadData {
    
    func reloadCollection() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.collectionView.reloadData()
        }
    }
}

extension LecturePlaylistVC: AutoPlayDelegate {
    func playerItemDidReachEnd() {
        guard visibleIP != nil else { return }
        // set reachEnd item's seek time
        if let videoCell = collectionView.cellForItem(at: visibleIP!) as? LectureCell {
            seekTimes[videoCell.videoID] = nil
        }
        
        // auto play ended. scroll to bottom.
        print("visibleIP!.item : \(visibleIP!.item)")// 현재 위치 파악.
        if visibleIP!.item < detailVM!.lectureDetail!.data.count - 1 {// 마지막 항목이 아닌 경우
            print("has next item & scroll to next.")
            let indexPath = IndexPath(item: visibleIP!.item + 1, section: visibleIP!.section)
            collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        } else {
            print("is last item")
        }
    }
}
