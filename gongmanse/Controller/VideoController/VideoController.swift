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
    private var customMenuBarPorTraitWidthConstraint: NSLayoutConstraint?                 // 세로모드 시, 동영상에 적용될 넓이 제약조건
    // Constraint 객체 - 가로모드
    private var customMenuBarLandscapeRightConstraint: NSLayoutConstraint?                // 가로모드 시, 동영상에 적용될 넓이 제약조건
    private var customMenuBarLandscapeHeightConstraint: NSLayoutConstraint?               // 가로모드 시, 동영상에 적용될 높이 제약조건
    private var customMenuBarLandscapeTopConstraint: NSLayoutConstraint?                  // 가로모드 시, 동영상에 적용될 상단 제약조건
    private var customMenuBarLandscapeLeftConstraint: NSLayoutConstraint?                 // 가로모드 시, 동영상에 적용될 좌측 제약조건
    private var customMenuBarLandscapeWidthConstraint: NSLayoutConstraint?                // 세로모드 시, 동영상에 적용될 넓이 제약조건
    
    /* teacherInfoView */
    // Constraint 객체 - 세로모드
    private var teacherInfoViewPorTraitCenterXConstraint: NSLayoutConstraint?             // 세로모드 시, 동영상에 적용될 넓이 제약조건
    private var teacherInfoViewPorTraitHeightConstraint: NSLayoutConstraint?              // 세로모드 시, 동영상에 적용될 높이 제약조건
    private var teacherInfoViewPorTraitTopConstraint: NSLayoutConstraint?                 // 세로모드 시, 동영상에 적용될 상단 제약조건
    private var teacherInfoViewPorTraitWidthConstraint: NSLayoutConstraint?               // 세로모드 시, 동영상에 적용될 좌측 제약조건

    // Constraint 객체 - 가로모드
    private var teacherInfoViewLandscapeRightConstraint: NSLayoutConstraint?              // 가로모드 시, 동영상에 적용될 넓이 제약조건
    private var teacherInfoViewLandscapeHeightConstraint: NSLayoutConstraint?             // 가로모드 시, 동영상에 적용될 높이 제약조건
    private var teacherInfoViewLandscapeTopConstraint: NSLayoutConstraint?                // 가로모드 시, 동영상에 적용될 상단 제약조건
    private var teacherInfoViewLandscapeLeftConstraint: NSLayoutConstraint?               // 가로모드 시, 동영상에 적용될 좌측 제약조건

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
    lazy var playerItem = AVPlayerItem(url: videoURL! as URL)
    lazy var player = AVPlayer(playerItem: playerItem)
    
    /// AVPlayer 자막역햘을 할 UILabel
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        let backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.backgroundColor = backgroundColor
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "default setting..."
        return label
    }()
    
    lazy var subtitles = Subtitles(subtitles: "")
    lazy var gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedSubtitle))

    
    let videoURL = NSURL(string: "https://file.gongmanse.com/access/lectures/video?access_key=M2NlZThkYjRmZmJkMjJlMzkyMjhkMDIyMDA3NzUwMjNkY2Q2YjY1MjlkZjUzMzY1MzhhZTQzYTYxNTk5ZGEyNmNiYTExMmQ2OTU2OTRiOTU1ZGNjNTM2MmI3NTA1ZmU1NTE5YjFjOGU4ZGM1NzlhYTk0ZDNhMzQ4MTIxZTJkMWE2NjB2Y3pNRjFLSERtU0d3cHNGamZMd0pWSmQ2Z0ZZc3RKWnMzY0FPNFRRa1QrTEczOThjcjd0VWxGVlNIQnBpZlpGU0paNFE1N2h4ajJzOG1QQ2p1NnhRY3ZzV3BVNzFYOU5ienYzRCtLYW91SGwrVWhlWWVObVRPOFJPZ2E1MUR2ZDdoeGNOZkEyTG9hRTBHV2NnZVUwWG52eVRhY1hhSGxBaE9rM2Y3WTVJclFTQVdhOTRhQzJ1SUJFWFNsZC82WXd4MDN5M3lPT3lkZVhnRnJQRlhBZ2t5NVMydXdyaEpJM0piT3Azb3JXdnljQjU4YTNVY2EvS2x6SWxHalBvQmIzZXZ5dVREZ1FkZW1vUHY3ekUzN0ZLTmw3VVJ6cmJaN2lIYVhtQnhxTnlRb1M2MkpBRjV0UWhXQTVXMHZOYnV5M2wwbjBqUGdCQkJYMlNKVG05UFF4b2x6L3lpblZneGVUeTk5Yy9LbUk9")

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
        print("DEBUG: 4Rangs is \(keywordRanges[5])")
        print("DEBUG: 4Rangs is \(keywordRanges[6])")
        print("DEBUG: 4Rangs is \(keywordRanges[7])")

        /// 클릭한 위치와 subtitle의 keyword의 Range를 비교
        /// - keyword Range 내 subtitle 클릭 위치가 있다면, true
        /// - keyword Range 내 subtitle 클릭 위치가 없다면, false
        if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[0] ) {
            print("DEBUG: 지금 sTag가 1 개입니까?")
        } else if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[2]) {
            print("DEBUG: \(currentKeywords[2])?")
        } else if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[4]) {
            print("DEBUG: \(currentKeywords[4])?")
            print("DEBUG: 지금 sTag가 2 개입니까?")
        } else {
            print("DEBUG: 키워드가 없나요?")
        }
    }
    
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
    
    // MARK: - Public methods
    func open(fileFromLocal filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        let contents = try! String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
    }
    
    func open(fileFromRemote filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        subtitleLabel.text = "..."
        URLSession.shared.dataTask(with: filePath, completionHandler: { (data, response, error) -> Void in
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                //Check status code
                if statusCode != 200 {
                    NSLog("Subtitle Error: \(httpResponse.statusCode) - \(error?.localizedDescription ?? "")")
                    return
                }
            }
            
            // Update UI elements on main thread
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
        // Parse
        subtitles.parsedPayload = Subtitles.parseSubRip(string)
        addPeriodicNotification(parsedPayload: (subtitles.parsedPayload!))
    }
    
    func showByDictionary(dictionaryContent: NSMutableDictionary) {
        // Add Dictionary content direct to Payload
        subtitles.parsedPayload = dictionaryContent
        addPeriodicNotification(parsedPayload: (subtitles.parsedPayload!))
    }
    
    
    /* keyword 텍스트에 적절한 변화를 주고, 클릭 시 action이 호출될 수 있도록 관리하는 메소드 */
    /// "Player"가 호출된 후, 일정시간마다 호출되는 메소드
    func addPeriodicNotification(parsedPayload: NSDictionary) {
        // gesture 관련 속성을 설정한다.
        gesture.numberOfTapsRequired = 1
        subtitleLabel.isUserInteractionEnabled = true
        subtitleLabel.addGestureRecognizer(gesture)
        /// keyword의 숫자만큼 "keywordRanges" 인덱스를 생성한다.
        /// - 여기서 추가된 element만큼 클릭 시, keyword 위치를 받을 수 있다.
        /// - 10개를 만든다면 10의 키워드 위치를 저장할 수 있다.
        /// - 키워드 위치를 저장할 프로퍼티에 공간을 확보한다
        for _ in 0...11 {
            // Default 값을 "100,100" 임의로 부여한다.
            self.keywordRanges.append(NSRange(location: 100, length: 100))
        }
        
        for _  in 0...11 {
            // Default 값을 "100...103" 임의로 부여한다.
            self.sTagsRanges.append(Range<Int>(100...103))
        }
        
        // "forInterval"의 시간마다 코드로직을 실행한다.
        self.player.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 60),
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                guard let strongSelf = self else { return }
                let label = strongSelf.subtitleLabel
                
                // "Subtitles"에서 필터링한 자막값을 옵셔널언랩핑한다.
                if let subtitleText = Subtitles.searchSubtitles(strongSelf.subtitles.parsedPayload, time.seconds) {
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
                        subtitleFinal = strongSelf.sliceSubtitleText(slicedText: firstSlicing, arrayIndex: numberOfsTags * 2)
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
                    var sTagsArray = [String]()
                    sTagsArray.append("계절")
                    sTagsArray.append("자전")
                    sTagsArray.append("공전")
                    sTagsArray.append("북극")
                    sTagsArray.append("남극")
                    sTagsArray.append("공전")
                    sTagsArray.append("궤도면")
                    sTagsArray.append("태양")
                    sTagsArray.append("남중 고도")
                    sTagsArray.append("수용론")
                    sTagsArray.append("서술자")
                    sTagsArray.append("내재적 분석")
                    sTagsArray.append("외재적 준거")
                    
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
                        strongSelf.manageTextInSubtitle(numberOfHasgtags: numberOfHasgtags, subtitleArray: subtitleArray, sTagsArray: sTagsArray, keywordAttriString: keywordAttriString, subtitleFinal: subtitleFinal, label: label)
                    }
                }
            })
    }
    
    // View 최상단 영상 시작 메소드
    func playVideo() {
        playerController.delegate = self
        
        // AVPlayer에 외부 URL을 포함한 값을 입력한다.
        player = AVPlayer(url: videoURL! as URL)
        
        playerController.player = player
        
        // AVPlayerController를 "ViewController" childController로 등록한다.
        self.addChild(playerController)
        
        /// 공만세 적용 한글 인코딩 결과 값
        let subtitleInKor = makeStringKoreanEncoded("https://file.gongmanse.com/uploads/videos/2017/김샛별/계절이 변하는 까닭/170630_과학_초등_김샛별_083_계절이 변하는 까닭.vtt")
        let subtitleRemoteUrl = URL(string: subtitleInKor)
        // 자막URL을 포함한 값을 AVPlayer와 연동한다.
         open(fileFromRemote: subtitleRemoteUrl!)
        
        // MARK: Text 색상 변경값 입력
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.textColor = .white
        let convertedHeight = convertHeight(231, standardView: view)
        let convertedConstant = convertHeight(65.45, standardView: view)
        
//        playerController.view.setDimensions(height: convertedHeight - convertedConstant, width: view.frame.width)
        playerController.view.setDimensions(height: view.frame.width * 0.57, width: view.frame.width)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.width, height: convertedHeight - convertedConstant)
        playerController.view.contentMode = .scaleToFill

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
        videoContainerViewPorTraitHeightConstraint = videoContainerView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.57)
        videoContainerViewPorTraitTopConstraint = videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        videoContainerViewPorTraitLeftConstraint = videoContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        // Landscape 제약조건 정의
        videoContainerViewLandscapeWidthConstraint = videoContainerView.widthAnchor.constraint(equalToConstant: view.frame.width)
        videoContainerViewLandscapeHeightConstraint = videoContainerView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.57)
        videoContainerViewLandscapeTopConstraint = videoContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        videoContainerViewLandscapeLeftConstraint = videoContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        
        /* subtitleLabel(자막) */
        view.addSubview(subtitleLabel)
        subtitleLabel.anchor(left: videoContainerView.leftAnchor,
                                               bottom: videoContainerView.bottomAnchor,
                                               width: view.frame.width)
        
        /* CustomTabBar */
        view.addSubview(customMenuBar)
        customMenuBar.delegate = self
        customMenuBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Portrait 제약조건 정의
        customMenuBarPorTraitLeftConstraint = customMenuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        customMenuBarPorTraitRightConstraint = customMenuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        customMenuBarPorTraitTopConstraint = customMenuBar.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        customMenuBarPorTraitHeightConstraint = customMenuBar.heightAnchor.constraint(equalToConstant: view.frame.height * 0.06)
        customMenuBarPorTraitWidthConstraint = customMenuBar.widthAnchor.constraint(equalToConstant: view.frame.width)
        
        // Landscape 제약조건 정의
        customMenuBarLandscapeTopConstraint = customMenuBar.topAnchor.constraint(equalTo: view.topAnchor)
        customMenuBarLandscapeRightConstraint = customMenuBar.rightAnchor.constraint(equalTo: view.rightAnchor)
//        customMenuBarLandscapeRightConstraint = customMenuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        customMenuBarLandscapeLeftConstraint = customMenuBar.leadingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        customMenuBarLandscapeHeightConstraint = customMenuBar.heightAnchor.constraint(equalToConstant: view.frame.height * 0.06)
//        customMenuBarLandscapeWidthConstraint = customMenuBar.widthAnchor.constraint(equalToConstant: view.frame.width)
        
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
//        pageCollectionViewLandscapeRightConstraint = pageCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width)
        pageCollectionViewLandscapeRightConstraint = pageCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
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
            topBorderLine.alpha = 1
            bottomBorderLine.alpha = 1
        } else {            // 가로모드인 경우
            print("DEBUG: 가로모드")
            portraitConstraint(false)
            landscapeConstraint(true)
            topBorderLine.alpha = 0
            bottomBorderLine.alpha = 0
        }
    }
    
    // Portait 제약조건 활성화 메소드
    func portraitConstraint(_ isActive: Bool) {
        pageCollectionView.reloadData()
        customMenuBar.setNeedsLayout()
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
        customMenuBar.setNeedsLayout()
        // "videoContainerView" 제약조건
        videoContainerViewLandscapeWidthConstraint?.isActive = isActive
        videoContainerViewLandscapeHeightConstraint?.isActive = isActive
        videoContainerViewLandscapeTopConstraint?.isActive = isActive
        videoContainerViewLandscapeLeftConstraint?.isActive = isActive
        
        // "customTabBar" 제약조건
        customMenuBarLandscapeRightConstraint?.isActive = isActive
        customMenuBarLandscapeTopConstraint?.isActive = isActive
        customMenuBarLandscapeLeftConstraint?.isActive = isActive
        customMenuBarLandscapeHeightConstraint?.isActive = isActive
        customMenuBar.videoMenuBarTabBarCollectionView.reloadData()
        
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


extension UITapGestureRecognizer {

    /*
     * "didTapAttributedTexxtInLabel() 메소드의 로직
     * label의 전체 크기만큼 textContainer를 크기를 설정한다.
     * 좌표와 글자크기를 동기화 시켜서 좌표 == 글자 순서로 변환한다.
     */
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = 0
        
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        print("DEBUG: indexOfCharacter: \(indexOfCharacter)")
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}


// MARK: - Subtitles Methond
/// 동영상 자막 keyword 색상 변경 및 클릭 시 호출을 위한 커스텀 메소드

extension VideoController {
    func setUpAttributeString(_ attributedString: NSMutableAttributedString, text: String,array: [String], arrayIndex aIndex: Int, label: UILabel) {
        // "keyword"에 해당하는 텍스트에 텍스트 색상과 폰트를 설정한다.
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: (text as NSString).range(of: ("#\(array[aIndex])")))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.orange, range: (text as NSString).range(of: ("#\(array[aIndex])")))
        
        // 설정한 값을 UILabel에 추가한다.
        label.attributedText = attributedString
    }
    
    func sliceSubtitleText(slicedText: [String.SubSequence], arrayIndex index: Int) -> String {
        /// "<" 기준으로 슬라이싱한 array[i]를 입력받을 프로퍼티
        var textArray = [String?]()
        
        /// "textArray"의 옵셔널 해제한 element를 입력받을 프로퍼티
        var optionalUnwrappingArray = [String]()
        
        for i in 0...index {
            /// ">" 기준으로 슬라이싱한 array[i]를 입력한 scanner
            let scanner = Scanner(string: String(slicedText[i]))
            
            /// "textArray"의 옵셔널 해제한 element를 입력받을 프로퍼티
            textArray.append(scanner.scanUpToString("<"))
        }
        
        for j in 0...index {
            if let element = textArray[j] {
                optionalUnwrappingArray.append(element)
            }
        }
        
        let result = optionalUnwrappingArray.joined()
        return result
    }
    
    func detectSTagsAndChangeColor(text: String, sTagsArray: [String], j: Int, i: Int) {
        
            // (클래스의 전역변수에 해당하는)"keywordRanges"로 클릭된 텍스트위 range 값을 전달한다.
            let keywordRangeInstance = (text as NSString).range(of: ("#\(sTagsArray[j])"))
            
            // keyword의 위치를 Range로 캐스팅한다. 이를 통해 어떤 키워드를 클릭했는지 유효성판단을 한다.(didTappedSubtitle메소드에서)
            if let rangeOfKeywordTapped = Range(keywordRangeInstance) {
                self.sTagsRanges[i] = rangeOfKeywordTapped
            }
            // keywordRanges의 index가 "i"인 이유는 2나 4 모두를 포함하기위해서 i로 코드를 줄였다.
            self.keywordRanges[i] = keywordRangeInstance
    }
    
    func detectKeywrodAndTapRange(subtitleArray: [String.SubSequence], i: Int, sTagsArray: [String], keywordAttriString: NSMutableAttributedString, subtitleFinal: String, label: UILabel) {
        // "#" 가 있는 인덱스는 무조건 "2"와 "4" 이므로 "2"와 "4"일 때만 제한을 둔다.
        /// `#` 를 가지고 있는 텍스트
        let textAfterHashtag = subtitleArray[i]
        // 그 인덱스 값을 String으로 캐스팅 후, Scanner에 입력한다.
        /// `#` 를 가지고 있는 텍스트를 입력받은 Scanner
        let scanner = Scanner(string: String(textAfterHashtag))
        // "<" 이전까지의 값을 가져온다. 이 때 그 값은 keyword가 된다.
        /// `#` 이후 keyword를 추출한 텍스트
        let keyword = scanner.scanUpToString("<")
        
        // #keyword 와 일치하는 값이 sTags 중 있는지 확인한다.
        for j in 0...sTagsArray.count-1 {
            /* #이후에 있는 단어와 API로부터 받은 sTags와 동일한 경우 */
            if keyword == sTagsArray[j] {
                // "Stags" 글자색 변경 및 폰트를 변경한다.
                setUpAttributeString(keywordAttriString, text: subtitleFinal, array: sTagsArray, arrayIndex: j, label: label)
                if let keyword = keyword {
                    self.currentKeywords[i] = keyword
                }
                
                detectSTagsAndChangeColor(text: subtitleFinal, sTagsArray: sTagsArray, j: j, i: i)
            }
        }
    }
    
    func manageTextInSubtitle(numberOfHasgtags: Int,subtitleArray: [String.SubSequence], sTagsArray: [String], keywordAttriString: NSMutableAttributedString, subtitleFinal: String, label: UILabel) {
        for i in 0...(2 * numberOfHasgtags) {
            // "#"가 있는 (subtitleArray의)인덱스는 2와 4 이므로 2와 4일 때만 아래 로직을 실행한다.
            // sTagsRange 저장위치도 2와 4로 통일한다. 같은 for문에서 순회하기 때문이다.
            if i % 2 == 0 && i > 0 {
                detectKeywrodAndTapRange(subtitleArray: subtitleArray, i: i, sTagsArray: sTagsArray, keywordAttriString: keywordAttriString, subtitleFinal: subtitleFinal, label: label)
            }
        }
    }
    
}
