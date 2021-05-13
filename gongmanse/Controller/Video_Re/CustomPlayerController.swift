/*
"CustomPlayerController"는 상세화면의 구조만 담당하도록 설계한다.
 - 영상 재생역할을 수행한다.
 - 영상 자막을 생성하고 클릭 시, 검색화면으로 넘어가는 로직을 수행한다.
 - 자막에 키워드의 색상을 변경한다.
 - 영상 컨트롤을 위한 버튼 로직을 수행한다.
 - 영상 자막 생성 및 소멸 그리고 재생속도 관련된 로직(BottomPopup까지)를 수행한다.
 
 
1. 영상을 담당하는 컨트롤러는 "CustomPlayerController"에서 전담한다.
2. 하단 탭바를 소유한 화면은 "DetailScreenTabController"에서 전담한다.
3. 강의 정보는 "LessonInfoController"에서 전담한다.
*/

import AVFoundation
import AVKit
import Foundation
import UIKit

protocol CustomPlayerControllerDelegate: AnyObject {
    func changeFullScreenMode()
}

class CustomPlayerController: UIViewController {

    // MARK: - Properties
    
    weak var delegate: CustomPlayerControllerDelegate?
    
    var isPlaying: Bool { player.rate != 0 && player.error == nil }
    var isOnSubtitle = true          // 자막 표시 여부 Index
    var currentplayRate = Float(1.0) // 현재 영상 속도 Index
    
    // sTag 텍스트 내용을 클릭했을 때, 이곳에 해당 텍스트의 NSRange가 저장된다.
    /// sTags로 가져온 keyword의 NSRange 정보를 담은 array
    var keywordRanges: [NSRange] = []
    /// sTags로 가져온 keyword의 Range\<Int> 정보를 담은 array
    var sTagsRanges = [Range<Int>]()
    /// 현재 자막에 있는 keyword Array
    /// - 인덱스를 통해 접근하므로 dummy data를 작성한다.
    var currentKeywords = ["", "", "", "", "", "", "", "", "", "", "", ""]
    
    // AVPlayer 관련 프로퍼티
    var playerController = AVPlayerViewController()
    var timeObserverToken: Any?
    lazy var playerItem = AVPlayerItem(url: videoURL! as URL)
    lazy var player = AVPlayer(playerItem: playerItem)
    var videoURL = NSURL(string: "")
    var vttURL = String()
    var sTagsArray = [String]()
//    var tempsTagsArray = ["", "", "", "", "", "", "", "", "", "", ""]
    lazy var subtitles = Subtitles(subtitles: "")
    lazy var gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                      action: #selector(didTappedSubtitle))

    /// AVPlayer 자막역햘을 할 UILabel
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        let backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.backgroundColor = backgroundColor
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "default setting..."
        label.addGestureRecognizer(gesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
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
    let changeFullScreenButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "rectangle.lefthalf.inset.fill.arrow.left")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.addTarget(self, action: #selector(presentFullScreenMode), for: .touchUpInside)
        button.setImage(image, for: .normal)
        return button
    }()
    
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
        button.alpha = 0.77
        button.addTarget(self, action: #selector(handleBackButtonAction), for: .touchUpInside)
        return button
    }()
    
    let subtitleToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "textbox")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(switchSubtitleDisplay), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(videoURL: NSURL, vttURL: String, sTags: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.videoURL = videoURL
        self.vttURL = vttURL
        self.sTagsArray = sTags
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        playVideo()
    }
    
    
    // MARK: - Actions
    
    /// 우측상단에 뒤로가기 버튼 로직
    @objc func handleBackButtonAction() {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        player.pause()
        NotificationCenter.default.removeObserver(self)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all, andRotateTo: UIInterfaceOrientation.landscapeRight)
        //        removePeriodicTimeObserver()
        self.dismiss(animated: true, completion: nil)
    }
    
    var isDisplayControlView = false
    
    @objc func targetViewDidTapped() {
        if isDisplayControlView {
            isDisplayControlView = false
        } else {
            isDisplayControlView = true
        }
        UIView.animate(withDuration: 0.22) {
            self.buttonsInVideoControlViewAlphaValueChange(self.isDisplayControlView)
        }
    }

    
    // MARK: - Heleprs
    
    func configureUI() {
        configureConstraint()
        view.backgroundColor = .cyan
    }
    
    func configureConstraint() {
        view.addSubview(videoContainerView)
        videoContainerView.anchor(top: view.topAnchor,
                                  left: view.leftAnchor,
                                  bottom: view.bottomAnchor,
                                  right: view.rightAnchor)
        
        self.videoContainerView.addSubview(playerController.view)
        playerController.view.anchor(top: videoContainerView.topAnchor,
                                     left: videoContainerView.leftAnchor,
                                     bottom: videoContainerView.bottomAnchor,
                                     right: videoContainerView.rightAnchor)
        playerController.showsPlaybackControls = false
        
        let videoControlGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                 action: #selector(targetViewDidTapped))
        videoContainerView.addSubview(videoControlContainerView)
        videoControlContainerView.anchor(top: view.topAnchor,
                                  left: view.leftAnchor,
                                  bottom: view.bottomAnchor,
                                  right: view.rightAnchor)
        videoControlContainerView.backgroundColor = .clear
        videoControlContainerView.alpha = 1
        buttonsInVideoControlViewAlphaValueChange(true)
        videoControlContainerView.isUserInteractionEnabled = true
        videoControlContainerView.addGestureRecognizer(videoControlGesture)

        videoContainerView.addSubview(subtitleLabel)
        subtitleLabel.anchor(left: videoContainerView.leftAnchor,
                             bottom: videoContainerView.bottomAnchor,
                             right: videoContainerView.rightAnchor)

        let playButtonSize = CGFloat(75)
        videoControlContainerView.addSubview(playPauseButton)
        playPauseButton.setDimensions(height: playButtonSize, width: playButtonSize)
        playPauseButton.centerX(inView: videoControlContainerView)
        playPauseButton.centerY(inView: videoControlContainerView)

        let moveVideoButtonSize = CGFloat(50)
        videoControlContainerView.addSubview(videoBackwardTimeButton)
        videoBackwardTimeButton.setDimensions(height: moveVideoButtonSize, width: moveVideoButtonSize)
        videoBackwardTimeButton.centerY(inView: playPauseButton)
        videoBackwardTimeButton.anchor(right: playPauseButton.leftAnchor)

        videoControlContainerView.addSubview(videoForwardTimeButton)
        videoForwardTimeButton.setDimensions(height: moveVideoButtonSize, width: moveVideoButtonSize)
        videoForwardTimeButton.centerY(inView: playPauseButton)
        videoForwardTimeButton.anchor(left : playPauseButton.rightAnchor)

        let settingButtonSize = CGFloat(25)
        videoControlContainerView.addSubview(videoSettingButton)
        videoSettingButton.setDimensions(height: settingButtonSize, width: settingButtonSize)
        videoSettingButton.anchor(top: videoControlContainerView.topAnchor,
                                  right: videoControlContainerView.rightAnchor,
                                  paddingTop: 5,
                                  paddingRight: 15)

        videoControlContainerView.addSubview(subtitleToggleButton)
        subtitleToggleButton.setDimensions(height: settingButtonSize, width: settingButtonSize)
        subtitleToggleButton.anchor(top: videoControlContainerView.topAnchor,
                                    right: videoSettingButton.leftAnchor,
                                    paddingTop: 5,
                                    paddingRight: 10)

        let backButtonSize = CGFloat(25)
        videoControlContainerView.addSubview(backButton)
        backButton.setDimensions(height: backButtonSize, width: backButtonSize)
        backButton.anchor(top: videoControlContainerView.topAnchor,
                          left: videoControlContainerView.leftAnchor,
                          paddingTop: 5,
                          paddingLeft: 10)
        
        let sliderWidth = view.frame.width * 0.52
        videoControlContainerView.addSubview(timeSlider)
        timeSlider.setDimensions(height: 5, width: sliderWidth)
        timeSlider.centerX(inView: videoControlContainerView)
        timeSlider.anchor(bottom: videoControlContainerView.bottomAnchor,
                          paddingBottom: 27)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged),
                             for: .valueChanged)
        
        videoControlContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.centerY(inView: timeSlider)
        currentTimeLabel.anchor(right: timeSlider.leftAnchor,
                                paddingRight: 5, height: 11)
        
        videoControlContainerView.addSubview(endTimeTimeLabel)
        endTimeTimeLabel.centerY(inView: timeSlider)
        endTimeTimeLabel.anchor(left: timeSlider.rightAnchor,
                                paddingLeft: 5, height: 11)
        
        videoControlContainerView.addSubview(changeFullScreenButton)
        changeFullScreenButton.centerY(inView: timeSlider)
        changeFullScreenButton.anchor(left: endTimeTimeLabel.rightAnchor,
                                      paddingLeft: 10)
        
    }
    
    func buttonsInVideoControlViewAlphaValueChange(_ state: Bool) {
        self.backButton.alpha = state ? 1 : 0
        self.subtitleToggleButton.alpha = state ? 1 : 0
        self.videoSettingButton.alpha = state ? 1 : 0
        self.videoBackwardTimeButton.alpha = state ? 1 : 0
        self.videoForwardTimeButton.alpha = state ? 1 : 0
        self.playPauseButton.alpha = state ? 1 : 0
        self.timeSlider.alpha = state ? 1 : 0
        self.currentTimeLabel.alpha = state ? 1 : 0
        self.endTimeTimeLabel.alpha = state ? 1 : 0
    }
}


// MARK: - AVPlayer Method

extension CustomPlayerController {
    @objc func playPausePlayer() {
        print("DEBUG: 재생 / 일시정지 버튼이 클릭되었습니다.")
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
    
    @objc func presentFullScreenMode() {
        delegate?.changeFullScreenMode()
    }
    
    @objc func handleSettingButton() {
        let vc = VideoSettingPopupController()
        vc.delegate = self
        vc.currentStateSubtitle = isOnSubtitle
        present(vc, animated: true, completion: nil)
    }
    
    @objc func switchSubtitleDisplay() {
        UIView.animate(withDuration: 0.22) {
            if self.isOnSubtitle {
                self.isOnSubtitle = false
                self.subtitleLabel.alpha = 0
            } else {
                self.isOnSubtitle = true
                self.subtitleLabel.alpha = 1
            }
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
    
    /// 알림 호출 시, 호출될 콜백메소드
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        player.seek(to: CMTime.zero)
        player.pause()
    }
    
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
    
    /// 1,2,....100과 같은 값을 받았을 때, 00:00 의 형식으로 출력해주는 메소드
    func convertTimeToFitText(time: Int) -> String {
        
        // 초와 분을 나눈다.
        let minute = time / 60
        let sec = time % 60
        
        // 1분이 넘는 경우
        if minute > 0 {
            return "\(minute):\(sec < 10 ? "0\(sec)" : "\(sec)")"
            
            // 1 분이 넘지 않는 경우
        } else {
            return "0:\(sec < 10 ? "0\(sec)" : "\(sec)")"
        }
    }
    
    /// .vtt 내용 중 Text만 받아서 font Tag를 제거하는 메소드
    func filteringFontTagInSubtitleText(text: String) -> String {
        
        let text = text
        
        /// 1차 필터링: #에 있는 font tag 제거
        let firstFilteringText = text.replacingOccurrences(of: "<font color=\"#ffff00\">", with: "")
        
        /// 2차 필터링: 이 외 font tag 제거
        let secondFilteringText = firstFilteringText.replacingOccurrences(of: "<font color=\"#ff8000\">", with: "")
        
        /// 3차 필터링: </font> tag 제거
        let thirdFilteringText = secondFilteringText.replacingOccurrences(of: "</font>", with: "")
        
        return thirdFilteringText
    }
    
    func setUpAttributeString(_ attributedString: NSMutableAttributedString,
                              text: String,
                              array: [String],
                              arrayIndex aIndex: Int,
                              label: UILabel) {
        
        // "keyword"에 해당하는 텍스트에 텍스트 색상과 폰트를 설정한다.
        attributedString
            .addAttribute(NSAttributedString.Key.font,
                          value: UIFont.systemFont(ofSize: 16),
                          range: (text as NSString).range(of: ("\(array[aIndex])")))
        attributedString
            .addAttribute(NSAttributedString.Key.foregroundColor,
                          value: UIColor.orange,
                          range: (text as NSString).range(of: ("\(array[aIndex])")))
        
        // 설정한 값을 UILabel에 추가한다.
        label.attributedText = attributedString
    }
    
    func detectSTagsAndChangeColor(text: String, sTagsArray: [String], j: Int, i: Int) {
        
        // (클래스의 전역변수에 해당하는)"keywordRanges"로 클릭된 텍스트위 range 값을 전달한다.
        let keywordRangeInstance = (text as NSString).range(of: ("\(sTagsArray[j])"))
//        print("DEBUG: keywordRangeInstance \(keywordRangeInstance)")
        
        // keyword의 위치를 Range로 캐스팅한다. 이를 통해 어떤 키워드를 클릭했는지 유효성판단을 한다.(didTappedSubtitle메소드에서)
        if let rangeOfKeywordTapped = Range(keywordRangeInstance) {
            self.sTagsRanges[i] = rangeOfKeywordTapped
        }
        // keywordRanges의 index가 "i"인 이유는 2나 4 모두를 포함하기위해서 i로 코드를 줄였다.
        self.keywordRanges[i] = keywordRangeInstance
    }
    
    func detectKeywrodAndTapRange(subtitleArray: [String.SubSequence],
                                  i: Int,
                                  sTagsArray: [String],
                                  keywordAttriString: NSMutableAttributedString,
                                  subtitleFinal: String,
                                  label: UILabel) {
        
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
            if ("#" + keyword!) == sTagsArray[j] {
                // "Stags" 글자색 변경 및 폰트를 변경한다.
                setUpAttributeString(keywordAttriString,
                                     text: subtitleFinal,
                                     array: sTagsArray,
                                     arrayIndex: j,
                                     label: label)
                
                if let keyword = keyword {
                    self.currentKeywords[i] = keyword
                }
                
                detectSTagsAndChangeColor(text: subtitleFinal,
                                          sTagsArray: sTagsArray,
                                          j: j,
                                          i: i)
            }
        }
    }
    
    func manageTextInSubtitle(numberOfHasgtags: Int,
                              subtitleArray: [String.SubSequence],
                              sTagsArray: [String],
                              keywordAttriString: NSMutableAttributedString,
                              subtitleFinal: String,
                              label: UILabel) {
        
        for i in 0...(2 * numberOfHasgtags) {
            // "#"가 있는 (subtitleArray의)인덱스는 2와 4 이므로 2와 4일 때만 아래 로직을 실행한다.
            // sTagsRange 저장위치도 2와 4로 통일한다. 같은 for문에서 순회하기 때문이다.
            if i % 2 == 0 && i > 0 {
                detectKeywrodAndTapRange(subtitleArray: subtitleArray,
                                         i: i,
                                         sTagsArray: sTagsArray,
                                         keywordAttriString: keywordAttriString,
                                         subtitleFinal: subtitleFinal,
                                         label: label)
            }
        }
    }
}

extension CustomPlayerController: AVPlayerViewControllerDelegate {
    
    func show(subtitles string: String) {
        // subtitle에 파싱한 값을 넣는다.
        subtitles.parsedPayload = Subtitles.parseSubRip(string)
        addPeriodicNotification(parsedPayload: (subtitles.parsedPayload!))
    }
    
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
                    // 05.11 로직상 필요없어져서 주석처리함 - 추후 필요할 일을 대비하여 일단 남겨둠.
//                    strongSelf.sTagsArray.removeAll()
//                    for index in 0 ... strongSelf.tempsTagsArray.count - 1 {
//                        strongSelf.sTagsArray.append(strongSelf.tempsTagsArray[index])
//                    }
                    
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
        subtitleLabel.textColor = .white
        
        playerController.view.setDimensions(height: view.frame.height,
                                            width: view.frame.width)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.width,
                                             height: videoContainerView.frame.height)
        playerController.view.contentMode = .scaleToFill
        
        playerController.didMove(toParent: self)
        
        player.play()
        player.isMuted = false
    }
}


// MARK: - BottomPopUp Delegate for change Subtitle display or not

extension CustomPlayerController: VideoSettingPopupControllerDelegate {
    func updateSubtitleIsOnState(_ subtitleIsOn: Bool) {
        UIView.animate(withDuration: 0.22) {
            if subtitleIsOn {
                self.subtitleLabel.alpha = 1
            } else {
                self.subtitleLabel.alpha = 0
            }
        }
    }
    
    func presentSelectionVideoPlayRateVC() {
        let vc = SelectVideoPlayRateVC()
        vc.delegate = self
        present(vc, animated: true)
    }
}

// MARK: - BottomPopUp Delegate for VideoPlayRate
extension CustomPlayerController: SelectVideoPlayRateVCDelegate {
    func changeVideoPlayRateByBottomPopup(rate: Float) {
        player.playImmediately(atRate: rate)
    }
}
