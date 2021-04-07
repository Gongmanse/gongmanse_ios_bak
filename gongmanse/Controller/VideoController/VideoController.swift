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
    
    private var teacherInfoFoldConstraint: NSLayoutConstraint?     // 최초적용될 제약조건
    private var teacherInfoUnfoldConstraint: NSLayoutConstraint?   // 클릭 시, 적용될 제약조건
    
    // MARK: Video 관련 객체
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
    private let timeSlider: UISlider = {
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
    lazy var playerItem = AVPlayerItem(url: videoUrl! as URL)
    lazy var player = AVPlayer(playerItem: playerItem)
    
    let videoUrl = NSURL(string: "https://file.gongmanse.com/access/lectures/video?access_key=NTcxOGE1ZjhkYzExODIwODUxNDFjNzI3ZGNhMTk5YzY3NmJjNDAwODI4OTRlZGUyZDMyMDQyOTkyMmU2ZmI0ZjRlZTVlZTEzYmE2MjQxOTU1Y2U1NGNjNTJiYTIxOWFkNTU3OWFhNzFhMzE5MTUwNGRmN2EyYzZjZTNmNmJjMDQ3SXdUMkdHc1dvS1c1RVZReU5RRENnczVQUGJUYzhreFFlSytwMFpockp2cXRSdFZlL3RlTjExeWpRZ09oelk5ckdmN2YwWTRKWVJXWWFiNE5vUXUvYXlSZHFPZHlpdkMwcUVlMDg2enNhQnpsSlpKM0Mya0I1ZDU0d0gzcHg1ZFlnMGk4RFBsT3JyYnlZTHBORWp0VlIvMXB5N0R3U3lBRzcyQjJ1R3V4dHRUckxjMFNheGcrOWlvd25NVWlDMW1RSEE0VEgzVk5nVExvMTd1WkFzSk5NN0Q2bjJ3VlZ6ajBsSUtaR1Z1dHl3ZU03S2pzMnB3QmU3Qis3MGZudUtNeUFqeWtwcCtxalM4YUhDSkRuRHJCS28wTklNcWIrbkhmN3ZFdkR0SThIVjM4RnU0Q2p6M2tVME94ejhla2JwL29waXdTeGdWVm9SY29maHlWQzEyeFJOajE3Y2oxWnExcGkxS1ZpZXFyZ1U9")

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
    private let teacherInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .progressBackgroundColor
        return view
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("자세히보기", for: .normal)
        button.backgroundColor = .mainOrange
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()                    // 전반적인 UI 구현 메소드
        setupCustomTabBar()              // "노트보기", "강의 QnA" 그리고 "재생목록" 탭바 구현 메소드
        setupPageCollectionView()        // View 중단부터 하단에 있는 "노트보기", "강의 QnA" 그리고 "재생목록" 페이지 구현 메소드
        configureToggleButton()          // 선생님 정보 토글버튼 메소드
        playVideo()                      // 동영상 재생 메소드로 현재 테스트를 위해 이곳에 둠 04.07 추후에 인트로 영상을 호출한 이후에 이 메소드를 호출할 계획
        configureVideoControlView()      // 비디오 상태바 관련 메소드
    }
    
    // MARK: - Actions
    
    @objc func handleToggle() {
        if teacherInfoFoldConstraint?.isActive == true {
            teacherInfoFoldConstraint?.isActive = false
            teacherInfoUnfoldConstraint?.isActive = true
            pageCollectionView.reloadData()
        } else {
            teacherInfoFoldConstraint?.isActive = true
            teacherInfoUnfoldConstraint?.isActive = false
            pageCollectionView.reloadData()
        }
        
    }
    
    @objc func handleBackButtonAction() {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func timeSliderValueChanged(_ slider: UISlider) {
        let seconds: Int64 = Int64(slider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player.seek(to: targetTime)
        
        if player.rate == 0 {
            player.play()
        }
    }
    
    
    
    // MARK: - Helpers
    
    func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        navigationController?.hidesBarsOnSwipe = true
        
        // 영상View
        let convertedHeight = convertZeplinHeightToiPhoneHeight(231, standardView: view)
        let convertedConstant = convertZeplinHeightToiPhoneHeight(65.45, standardView: view)
        
        
        view.addSubview(videoContainerView)
        videoContainerView.setDimensions(height: convertedHeight - convertedConstant,
                                         width: view.frame.width)
        videoContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        videoContainerView.centerX(inView: view)
        
        // 선생님정보 View
    }
    
    func setupCustomTabBar(){
        self.view.addSubview(customMenuBar)
        customMenuBar.delegate = self
        customMenuBar.translatesAutoresizingMaskIntoConstraints = false
        customMenuBar.anchor(top: videoContainerView.bottomAnchor,
                             left: view.leftAnchor)
        customMenuBar.setDimensions(height: view.frame.height * 0.06, width: view.frame.width)
        //        customMenuBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        //        customMenuBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        //        customMenuBar.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor).isActive = true
        //        customMenuBar.heightAnchor.constraint(equalToConstant: view.frame.height * 0.06).isActive = true
        
        view.addSubview(teacherInfoView)
        //        teacherInfoView.setDimensions(height: view.frame.height * 0.167, width: view.frame.width)
        teacherInfoFoldConstraint = teacherInfoView.heightAnchor.constraint(equalToConstant: 0)
        teacherInfoUnfoldConstraint = teacherInfoView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.28)
        
        
        teacherInfoView.centerX(inView: videoContainerView)
        teacherInfoView.anchor(top: customMenuBar.bottomAnchor,
                               width: view.frame.width)
        teacherInfoFoldConstraint?.isActive = true
        
        
        
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
        self.view.addSubview(pageCollectionView)
        pageCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pageCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pageCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        pageCollectionView.topAnchor.constraint(equalTo: self.teacherInfoView.bottomAnchor).isActive = true
    }
    
    
    func configureToggleButton() {
        view.addSubview(toggleButton)
        toggleButton.setDimensions(height: 20, width: 20)
        toggleButton.anchor(top: teacherInfoView.bottomAnchor,
                            right: teacherInfoView.rightAnchor,
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



// MARK: - Video

extension VideoController {
    // View 최상단 영상 시작 메소드
    func playVideo() {
        // 1 URL을 player에 추가한다
        let videoURL = videoUrl
        player = AVPlayer(url: videoURL! as URL)
        playerController.player = player
        self.addChild(playerController)
        
        // 2 자막 파일을 한글 인코딩을 한다
        let subtitleInKor = makeStringKoreanEncoded("https://file.gongmanse.com/uploads/videos/2017/김샛별/계절이 변하는 까닭/170630_과학_초등_김샛별_083_계절이 변하는 까닭.vtt")
        let subtitleURL = URL(string: subtitleInKor)
        
        // 3 playerController에 자막URL을 추가한다
        playerController.addSubtitles(controller: self).open(fileFromRemote: subtitleURL!)
        
        // 4 playController 색상 / frame / subview 추가 처리한다
        self.videoContainerView.addSubview(playerController.view)
        playerController.subtitleLabel?.textColor = .white
        playerController.view.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        playerController.view.centerX(inView: view)
        let convertedHeight = convertZeplinHeightToiPhoneHeight(231, standardView: view)
        let convertedConstant = convertZeplinHeightToiPhoneHeight(65.45, standardView: view)
        
        
        playerController.view.setDimensions(height: convertedHeight - convertedConstant, width: view.frame.width)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.width, height: convertedHeight)
        playerController.view.contentMode = .scaleToFill
        view.addSubview(playerController.subtitleLabel!)
        //        playerController.subtitleLabel?.setDimensions(height: 40, width: view.frame.width)
        playerController.subtitleLabel?.anchor(bottom: videoContainerView.bottomAnchor,
                                               width: view.frame.width)
        playerController.subtitleLabel?.centerX(inView: view)
        playerController.didMove(toParent: self)
        // 5 실행한다
        player.play()
        player.isMuted = true
        // Setting
        playerController.showsPlaybackControls = false  // 하단 상태표시슬라이드 display 여부
    }
    
    func configureVideoControlView() {
        // 동영상 컨트롤 컨테이너뷰 - AutoLayout
        videoContainerView.addSubview(videoControlContainerView)
        let height = convertZeplinHeightToiPhoneHeight(15, standardView: view)
        
        videoControlContainerView.setDimensions(height: height, width: view.frame.width)
        videoControlContainerView.centerX(inView: videoContainerView)
        videoControlContainerView.anchor(bottom: videoContainerView.bottomAnchor,
                                         paddingBottom: 17)
        
        // backButton
        videoContainerView.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left:view.leftAnchor)
        backButton.addTarget(self, action: #selector(handleBackButtonAction), for: .touchUpInside)
        backButton.setDimensions(height: 20, width: 20)
        
        // 타임라인 timerSlider
        let convertedWidth = convertZeplinWidthToiPhoneWidth(244, standardView: view)
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
        
    }
    
    
}
