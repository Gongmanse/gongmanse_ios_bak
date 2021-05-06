import AVFoundation
import AVKit
import Foundation
import UIKit

class VideoFullScreenController: UIViewController {
    
    // MARK: - Properties
    
    var isPlaying: Bool { player.rate != 0 && player.error == nil }
    var currentPlayerTime: CMTime?
    
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
        let image = UIImage(systemName: "goforward.10")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(moveForwardPlayer), for: .touchUpInside)
        return button
    }()
    
    /// 동영상 뒤로 가기
    let videoBackwardTimeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "gobackward.10")?.withTintColor(.white, renderingMode: .alwaysOriginal)
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
        let image = UIImage(systemName: "rectangle.lefthalf.inset.fill.arrow.left")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.addTarget(self, action: #selector(handleOrientation), for: .touchUpInside)
        button.setImage(image, for: .normal)
        return button
    }()
    
    let subtitleToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "textbox")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleSubtitleToggle), for: .touchUpInside)
        return button
    }()
    
    var isClickedSubtitleToggleButton: Bool = false
    
    let videoSettingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleSettingButton), for: .touchUpInside)
        return button
    }()
    
    /// 뒤로가기버튼
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        button.tintColor = .white
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
    
    
    // MARK: - Lifecycle
    
    init(playerCurrentTime time: CMTime) {
        super.init(nibName: nil, bundle: nil)
        self.currentPlayerTime = time
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Actions
    
    /// 우측상단에 뒤로가기 버튼 로직
    @objc func handleBackButtonAction() {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        player.pause()
        NotificationCenter.default.removeObserver(self)
        //        removePeriodicTimeObserver()
        self.dismiss(animated: true) {
            AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all, andRotateTo: UIInterfaceOrientation.portrait)
        }
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
    
    /// 화면 Orientation 변경 버튼 호출시, 호출되는 콜백메소드
    @objc func handleOrientation() { // -> 전체화면
    }
    
    /// 자막표시여부 버튼을 클릭하면 호출하는 콜백메소드
    @objc func handleSubtitleToggle() {
        if self.subtitleLabel.alpha == 0 {
            self.isClickedSubtitleToggleButton = true
            UIView.animate(withDuration: 0.22) {
                self.subtitleLabel.alpha = 1
            }
            
        } else {
            self.isClickedSubtitleToggleButton = false
            UIView.animate(withDuration: 0.22) {
                self.subtitleLabel.alpha = 0
            }
            
        }
    }
    
    /// 클릭 시, 설정 BottomPopupController 호출하는 메소드
    @objc func handleSettingButton() {
    }
    
    /// "subtitleLabel"을 클릭 시, 호출될 콜백메소드
    @objc func didTappedSubtitle(sender: UITapGestureRecognizer) {
 
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        view.addSubview(videoContainerView)
        videoContainerView.setDimensions(height: view.frame.height,
                                         width: view.frame.width)
        videoContainerView.anchor(top: view.topAnchor,
                                  left: view.leftAnchor)
        configureVideoControlView()
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
//        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self,
//                                                                    action: #selector(targetViewDidTapped))
        gesture.numberOfTapsRequired = 1
        playerController.view.isUserInteractionEnabled = true
        playerController.view.addGestureRecognizer(gesture)
    }
}

