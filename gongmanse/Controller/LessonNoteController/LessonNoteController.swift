//
//  LectureNoteController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/25.
//

import Alamofire
import UIKit
import AVKit

class LessonNoteViewModel {
    // MARK: - Property
    
    var currentSeriesID = ""
    var videoIDArr = [String]()
    var currentIndex = 0
    
    var videoID = String()
    var seriesID: String?
    var offSet = 0
    
    // MARK: - Init
    
    init(seriesID: String, _ currentVideoID: String) {
        // 시리즈 아이디를 받는다.
        self.seriesID = seriesID
        self.videoID = currentVideoID
        // 시리즈 아이디를 이용하여 API를 호출하고 "videoIDArr"에 시리즈에 해당하는 VideoID를 할당한다.
        networkingAPIBySeriesID(offSet: self.offSet)
    }
    
    //seriesID로 배열을 구성하는것이 아니라 이전 페이지의 노트배열 (검색, 국영수, 과학, 사회, 기타, 나의활동)
    //0711 - added by hp
    init(videoIDArr: [String], _ currentVideoID: String) {
        self.videoIDArr.append(contentsOf: videoIDArr)
        self.videoID = currentVideoID
        
        let currentIndex = findCurrentIDIndexNum(videoIDArr, currentID: self.videoID)
        self.currentIndex = currentIndex
    }
    
    /// 다음 버튼을 클릭했을 때, 다음 VideoID를 주는 연산프로퍼티
    var nextVideoID: String {
//        guard seriesID != nil else { return "" }
        print("DEBUG: currentIndex is \(currentIndex)")
        print("DEBUG: videoIDArr.count is \(videoIDArr.count)")
        if (videoIDArr.count - 1) == currentIndex {
            return "BLOCK"
        } else if videoIDArr.count == 0 {
            return "BLOCK"
        } else {
            currentIndex += 1
            return videoIDArr[currentIndex]
        }
    }
    
    /// 이전 버튼을 클릭했을 때, 다음 VideoID를 주는 연산프로퍼티
    var previousVideoID: String {
        if currentIndex <= 0 {
            return "BLOCK"
        } else {
            currentIndex -= 1
            return videoIDArr[currentIndex]
        }
    }
    
    // 최초에 SeriesID를 통해 VideoID를 호출하는 메소드(노트상세보기에서 사용)
    func networkingAPIBySeriesID(offSet: Int = 0) {
        guard let seriesID = self.seriesID else { return }
        
        VideoPlaylistDataManager()
            .getVideoPlaylistDataFromAPIInNote(VideoPlaylistInput(seriesID: seriesID, offset: "\(offSet)", limit: "20"),
                                               viewController: self)
    }
    
    /// 네트워크 성공 시, 시리즈에 해당하는 VideID를 지역변수에 할당하는 메소드 (노트상세보기에서 사용)
    func didSuccessAPI(response: VideoPlaylistResponse) {
        guard let seriesID = self.seriesID else { return }
        var tempArrVideID = [String]()
        let data = response.data

        // 시리즈에 해당하는 VideoID 모두 Array에 추가한다.
        for index in data.indices {
            tempArrVideID.append(data[index].id)
        }
        
        // isMore가 True 라면 API 메소드를 다시 호출한다. false가 될 때까지 호출한다.
        if response.isMore {
            offSet += 20
            VideoPlaylistDataManager()
                .getVideoPlaylistDataFromAPIInNote(VideoPlaylistInput(seriesID: seriesID, offset: "\(offSet)", limit: "20"),
                                                   viewController: self)
        }
        
        // isMore가 False가 되면 videoIDArr에 VideoID값을 모두 추가한다.
        videoIDArr.append(contentsOf: tempArrVideID)
        let currentIndex = findCurrentIDIndexNum(videoIDArr, currentID: self.videoID)
        self.currentIndex = currentIndex
    }
    
    /// 현재 Video가 위치한 Index를 찾는 메소드
    /// - 현재 Index를 알아야 다음 노트 VideoID를 호출할 수 있음
    func findCurrentIDIndexNum(_ idArr: [String], currentID: String) -> Int {
        var currentIDIndex: Int?
        
        for (index, value) in idArr.enumerated() {
            if value == currentID {
                currentIDIndex = index
            }
        }
        guard let resultIndex = currentIDIndex else { return 0 }
        return resultIndex
    }
}

/// 05.25 이후 노트 컨트롤러 _ 전체화면 노트 보기
class LessonNoteController: UIViewController {
    // MARK: - Properties

    var alertSaveNote: (() -> ())? = nil
    var currentVideoTime: CMTime? = CMTime() // 이전 화면으로 돌아올 때 사용
    
    // MARK: Data
    // PIP 모드를 위한 프로퍼티
    var isOnPIP: Bool = false
    var pipVC: PIPController?
    var pipVideoData: PIPVideoData? {
        didSet {
            setupPIPView()
            pipVC?.pipVideoData = pipVideoData
        }
    }
    
    /// 유사 PIP 기능을 위한 ContainerView
    let pipContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let lessonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DEFAULT"
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
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
    private let playPauseButton: UIButton = {
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
    
//    lazy var viewModel = LessonNoteViewModel(seriesID: seriesID, id ?? "15188")
    lazy var viewModel = LessonNoteViewModel(videoIDArr: videoIDArr, id ?? "15188")
    
    public var seriesID: String = ""
    private var id: String?
    private let token: String?
    private var url: String?
    private var strokesString = ""
    
    //0711 - added by hp
    public var videoIDArr: [String] = []
    //
    public var _type: String = ""
    public var _sort = 7
    public var _subjectNumber = ""
    public var _grade = ""
    public var _keyword = ""
    
    // 노트 이미지 인스턴스
    // Dummydata - 인덱스로 접근하기 위해 미리 배열 요소 생성
    private var noteImageArr: [UIImage] = []
    private var noteImageCount = 0
//    private var receivedNoteImage: UIImage?
    
    // MARK: UI

    // 노트 객체
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView01: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private var ct_iv_height : NSLayoutConstraint?
    
    private let marginViewLeft = UIView()
    private let marginViewRight = UIView()
    private var marginWidth : CGFloat = 0.0
    
    var isLoading = false
    
    // 노트필기 객체
    public let canvas = Canvas()
    private let savingNoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("노트\n저장", for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: buttonFontSize)
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.rgb(red: 21, green: 176, blue: 172)
        button.addTarget(self, action: #selector(handleSavingNote), for: .touchUpInside)
        return button
    }()
    
    private var isFoldingWritingImplement = true // 필기도구 View가 축소된 상태면 false
    private var writingImplementLeftConstraint: NSLayoutConstraint?
    var writingImplementYPosition: NSLayoutConstraint?
    var savingNoteYPosition: NSLayoutConstraint?
    
    private let writingImplement: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainOrange
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(openWritingImplement), for: .touchUpInside)
        return button
    }()
    
    private let redButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "redPencilOff"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "redPencilOn"), for: .selected)
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        button.isSelected = true
        return button
    }()
    
    private let greenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "greenPencilOff"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "greenPencilOn"), for: .selected)
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let blueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "bluePencilOff"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "bluePencilOn"), for: .selected)
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "eraserOff"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "eraserOn"), for: .selected)
//        button.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let writingImplementToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("필기\n도구", for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: buttonFontSize)
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(openWritingImplement), for: .touchUpInside)
        return button
    }()
    
    public let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이전", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: buttonFontSize)
        button.backgroundColor = UIColor.rgb(red: 21, green: 176, blue: 172)
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(previousButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    public let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: buttonFontSize)
        button.backgroundColor = UIColor.rgb(red: 21, green: 176, blue: 172)
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle

    init(id: String, token: String) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        self.id = id
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupLayout()
        setupNoteTaking()
        print("DEBUG: viewModel.videoIDArr \(viewModel.videoIDArr)")
        // 네비게이션 바 색상 변경
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        //네비게이션 바 오른쪽 상단 플레이 버튼
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "play"), style: .plain, target: self, action: #selector(videoPlayAction(_:)))
        
        //가로모드 제한
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //네비게이션 바 bottom border 제거 후 shadow 효과 적용
        self.navigationItem.title = "노트 보기"
        self.navigationController?.navigationBar.topItem?.title = "노트 보기"
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    @objc func videoPlayAction(_ sender: UIButton) {
        //PIP 재생중인 영상인 경우
        if let _ = pipVC?.pipVideoData?.videoURL {
            print("play pip")
//            dismiss(animated: true)
            
            //0711 - edit by hp
            setRemoveNotification()
            dismissSearchAfterVCOnPlayingPIP()
            return
        }
        
        AutoplayDataManager.shared.isAutoPlay = false
        AutoplayDataManager.shared.videoDataList.removeAll()
        AutoplayDataManager.shared.videoSeriesDataList.removeAll()
        AutoplayDataManager.shared.currentIndex = -1
        VideoDataManager.shared.isFirstPlayVideo = true
        
        PIPDataManager.shared.currentVideoCMTime = CMTime() //초기화
        
        let vc = VideoController()
        vc.modalPresentationStyle = .overFullScreen
        let videoID = id
        vc.id = videoID

        if let pvc = self.presentingViewController {
            print("dismiss note & present Video")
            self.dismiss(animated: false, completion: {
                pvc.present(vc, animated: true, completion: nil)
            })
        } else {
            present(vc, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc fileprivate func handleUndo() {
        canvas.undo()
    }
    
    @objc fileprivate func handleClear() {
        canvas.clear()
    }
    
    @objc fileprivate func handleColorChange(button: UIButton) {
        var pencilColor = #colorLiteral(red: 0.7536085248, green: 0.2732567191, blue: 0.3757801056, alpha: 1)
        
        switch button {
        case redButton:
            pencilColor = #colorLiteral(red: 0.7536085248, green: 0.2732567191, blue: 0.3757801056, alpha: 1)
        case greenButton:
            pencilColor = #colorLiteral(red: 0.2518872917, green: 0.6477053165, blue: 0.3158096969, alpha: 1)
        case blueButton:
            pencilColor = #colorLiteral(red: 0.07627140731, green: 0.6886936426, blue: 0.6746042967, alpha: 1)
        case clearButton:
            pencilColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        default:
            pencilColor = #colorLiteral(red: 0.7536085248, green: 0.2732567191, blue: 0.3757801056, alpha: 1)
        }
        
        canvas.setStrokeColor(color: pencilColor)
        
        redButton.isSelected = false
        greenButton.isSelected = false
        blueButton.isSelected = false
        clearButton.isSelected = false
        button.isSelected = true
    }
    
    @objc fileprivate func toggleSketchMode() {
        scrollView.isScrollEnabled.toggle()
    }
    
    @objc fileprivate func openWritingImplement() {
        let width = CGFloat(207)
        let noteMode = scrollView.isScrollEnabled
        scrollView.isScrollEnabled.toggle()

        // !noteMode -> 노트필기 불가능한상태
        if !noteMode {
            writingImplementLeftConstraint?.constant = -(width * 0.75)
            writingImplementToggleButton.setImage(.none, for: .normal)
            writingImplementToggleButton.setTitle("필기\n도구", for: .normal)

            canvas.isUserInteractionEnabled = false
//            canvas.alpha = 0
            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: []) {
                self.savingNoteButton.alpha = 0
                self.previousButton.alpha = 1
                self.nextButton.alpha = 1
                self.view.layoutIfNeeded()
            } completion: { _ in
            }

        } else {
            writingImplementLeftConstraint?.constant = 0
            writingImplementToggleButton.setTitle("", for: .normal)
            writingImplementToggleButton.setImage(#imageLiteral(resourceName: "doubleArrow"), for: .normal)

            canvas.isUserInteractionEnabled = true
//            canvas.alpha = 1
            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: []) {
                self.savingNoteButton.alpha = 1
                self.previousButton.alpha = 0
                self.nextButton.alpha = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
            }
        }
    }
    
    @objc fileprivate func handleSavingNote() {
        if !Constant.isLogin || Constant.remainPremiumDateInt == nil {
            self.presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        // canvas 객체로 부터 x,y 위치 정보를 받는다.
        canvas.saveNoteTakingData()
        
        // 이 클래스의 전역범위에 있는 데이터를 지역변수로 옮긴다.
        guard let token = self.token else { return }
        guard let id = self.id else { return }
        
        // 21.05.26 영상 상세정보 API에서 String으로 넘겨주는데, request 시, Int로 요청하도록 API가 구성되어 있음
        let intID = Int(id)!
        
        let sJson = "{\"aspectRatio\":\"0.5095108695652174\",\"strokes\":[" + "\(strokesString)" + "]}"
        
        let willPassNoteData = NoteTakingInput(token: token,
                                               video_id: intID,
                                               sjson: sJson)

        // 노트 필기 좌표 입력하는 API메소드
        DetailNoteDataManager().savingNoteTakingAPI(willPassNoteData, viewController: self)
    }
    
    func getNoteImageFromGuestKeyNoteAPI(response: GuestKeyNoteResponse) {
        // 노트 이미지를 가져오기 위한 로직으로 한글 URL 변경작업을 한다.
        noteImageCount = response.sNotes.count
        if noteImageCount > 0 {
            getImageFromURL(noteString: response.sNotes, index: 0)
        }
        /*for noteData in 0 ... (self.noteImageCount-1) {
            let convertedURL = makeStringKoreanEncoded("\(fileBaseURL)/" + "\(response.sNotes[noteData])")
            getImageFromURL(url: convertedURL, index: noteData)
        }*/
        
    }
    
    @objc func tapBackbutton() {
//        self.navigationController?.popViewController(animated: true)
        
        //0711 - edit by hp
        if self.pipVC == nil {
            PIPDataManager.shared.currentVideoCMTime = self.currentVideoTime
            
            dismiss(animated: true)
        } else {
            setRemoveNotification()
            dismissSearchAfterVCOnPlayingPIP()
        }
    }
    
    /// 다음 노트를 호출하는 메소드
    @objc func nextButtonDidTap() {
        if isLoading {
            return
        }
        if viewModel.videoIDArr.count == 0 {
            presentAlert(message: "마지막 페이지 입니다.")
        }
        
        
        let nextID = viewModel.nextVideoID
        if nextID == "BLOCK" {
            //수정 다음 videoID를 api를 통해서 가져온다.
            if _type == "검색" {
                getSearchNoteList()
            } else if _type == "나의 활동" {
                getMyNoteList()
            } else if _type == "국영수" {
                getHomeNoteList(KoreanEnglishMath_Video_URL)
            } else if _type == "과학" {
                getHomeNoteList(Science_Video_URL)
            } else if _type == "사회" {
                getHomeNoteList(SocialStudies_Video_URL)
            } else if _type == "기타" {
                getHomeNoteList(OtherSubjects_Video_URL)
            }
//            presentAlert(message: "마지막 페이지 입니다.")
            return
        }
        
        guard let token = self.token else { return }
        
        self.noteImageArr.removeAll()
        self.noteImageCount = 0
        self.isLoading = true
        
        id = nextID
        let dataForSearchNote = NoteInput(video_id: nextID,
                                          token: token)

        // 노트이미지 불러오는 API메소드
        DetailNoteDataManager().DetailNoteDataManager(dataForSearchNote,
                                                      viewController: self)
    }
    
    /// 이전 노트를 호출하는 메소드
    @objc func previousButtonDidTap() {
        if isLoading {
            return
        }
        let previousID = viewModel.previousVideoID
        if previousID == "BLOCK" {
            presentAlert(message: "첫 페이지 입니다.")
            return
        }
        
        guard let token = self.token else { return }
        
        self.noteImageArr.removeAll()
        self.noteImageCount = 0
        self.isLoading = true
        
        id = previousID
        let dataForSearchNote = NoteInput(video_id: previousID,
                                          token: token)

        // 노트이미지 불러오는 API메소드
        DetailNoteDataManager().DetailNoteDataManager(dataForSearchNote,
                                                      viewController: self)
    }
    
    // MARK: - Heleprs
    func getSearchNoteList() {
        
        AF.upload(multipartFormData: { formData in
            
            formData.append("\(self._subjectNumber)".data(using: .utf8) ?? Data(), withName: "subject")
            formData.append("\(self._grade)".data(using: .utf8) ?? Data(), withName: "grade")
            formData.append("\(self._keyword)".data(using: .utf8) ?? Data(), withName: "keyword")
            formData.append("\(self.viewModel.videoIDArr.count)".data(using: .utf8) ?? Data(), withName: "offset")
            formData.append("\(self._sort)".data(using: .utf8) ?? Data(), withName: "sort_id")
            
            
        }, to: "\(apiBaseURL)/v/search/searchnotes")
        .responseDecodable(of: SearchNotesModel.self) { response in
            switch response.result {
            case .success(let data):
                for i in 0..<data.data.count {
                    self.videoIDArr.append(data.data[i].videoID ?? "")
                    self.viewModel.videoIDArr.append(data.data[i].videoID ?? "")
                }
                DispatchQueue.main.async {
                    if data.data.count == 0 {
                        self.presentAlert(message: "마지막 페이지 입니다.")
                    } else {
                        self.nextButtonDidTap()
                    }
                }
            case .failure(_):
                self.presentAlert(message: "마지막 페이지입니다.")
            }
        }
    }
    
    func getHomeNoteList(_ urlStr: String) {
        //type=3노트보기
        
        var inputSortNum = 4
        switch _sort {
        case 0:
            inputSortNum = 4
        case 1:
            inputSortNum = 3
        case 2:
            inputSortNum = 1
        case 3:
            inputSortNum = 2
        default:
            inputSortNum = 4
        }
        if let url = URL(string: urlStr + "offset=\(self.viewModel.videoIDArr.count)&limit=20&sortId=\(inputSortNum)&type=3") {
            
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                
                if let json = try? decoder.decode(VideoInput.self, from: data) {
                    //                        guard let isMores = json.header?.isMore else { return}
                    //                        self.isMoreBool = Bool(isMores) ?? false
                    for i in 0..<json.body.count {
                        self.videoIDArr.append(json.body[i].videoId ?? "")
                        self.viewModel.videoIDArr.append(json.body[i].videoId ?? "")
                    }
                    DispatchQueue.main.async {
                        if json.body.count == 0 {
                            self.presentAlert(message: "마지막 페이지 입니다.")
                        } else {
                            self.nextButtonDidTap()
                        }
                    }
                }
            }.resume()
            
        }
    }
    
    func getMyNoteList() {
        isLoading = true
        var inputSortNum = 4
        
        switch _sort {
        case 0:
            inputSortNum = 4
        case 1:
            inputSortNum = 1
        case 2:
            inputSortNum = 2
        case 3:
            inputSortNum = 3
        default:
            inputSortNum = 4
        }
        
        if let url = URL(string: "\(apiBaseURL)/v/member/mynotes?token=\(Constant.token)&offset=\(self.viewModel.videoIDArr.count)&limit=20&sort_id=\(inputSortNum)") {
            print("노트목록\(url.absoluteString)")
            
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.isLoading = false
                
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(FilterVideoModels.self, from: data) {
                    for i in 0 ..< json.data.count {
                        self.videoIDArr.append(json.data[i].video_id ?? "")
                        self.viewModel.videoIDArr.append(json.data[i].video_id ?? "")
                    }
                    DispatchQueue.main.async {
                        if json.data.count == 0 {
                            self.presentAlert(message: "마지막 페이지 입니다.")
                        } else {
                            self.nextButtonDidTap()
                        }
                    }
                }
                
            }.resume()
        }
    }
    
    private func setupData() {
        guard let id = self.id else { return }
        guard let token = self.token else { return }
        
//        let dataForSearchNote = NoteInput(video_id: id,
//                                          token: token)
//        // 노트이미지 불러오는 API메소드
//        DetailNoteDataManager().DetailNoteDataManager(dataForSearchNote, viewController: self)
        
        if Constant.isGuestKey {
            self.noteImageArr.removeAll()
            self.noteImageCount = 0
            self.isLoading = true
            
            GuestKeyDataManager().GuestKeyAPIGetNoteData(videoID: id, viewController: self)
        } else {
            // 노트이미지 불러오는 API메소드
            guard let token = self.token else { return }
            
//            let videoDataManager = VideoDataManager.shared
//            guard let currentVideoID = videoDataManager.currentVideoID else { return }
            self.noteImageArr.removeAll()
            self.noteImageCount = 0
            self.isLoading = true
            
            let dataForSearchNote = NoteInput(video_id: id,
                                              token: token)
            DetailNoteDataManager().DetailNoteDataManager(dataForSearchNote,
                                                          viewController: self)
        }
    }
    
    private func setupLayout() {
        canvas.delegate = self // canvas position 데이터 전달받기 위한 델리게이션
        setupScrollView()
        setupWritingImplement()
        
        let naviBackButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(tapBackbutton))
        navigationItem.leftBarButtonItem = naviBackButton
    }
    
    private func setupScrollView() {
        view.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        marginViewLeft.translatesAutoresizingMaskIntoConstraints = false
        marginViewRight.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
//        scrollView.centerX(inView: view)
        scrollView.anchor(top: view.topAnchor,
                          left: view.leftAnchor,
                          bottom: view.bottomAnchor,
                          width: view.frame.width)
        
//        contentView.centerX(inView: view)
        contentView.anchor(top: scrollView.topAnchor,
                           bottom: scrollView.bottomAnchor)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.backgroundColor = .white
        
        // 여백이될 marginView 를 추가
        marginWidth = UIDevice.current.userInterfaceIdiom == .pad ?
        ( UIDevice.current.orientation.isLandscape ?
          view.frame.height * 0.4 : view.frame.width * 0.4 ) : 0
        
        contentView.addSubview(marginViewLeft)
        contentView.addSubview(marginViewRight)
        marginViewLeft.anchor(top: contentView.topAnchor,
                              left: contentView.leftAnchor,
                              bottom: contentView.bottomAnchor)
        marginViewRight.anchor(top: contentView.topAnchor,
                               bottom: contentView.bottomAnchor,
                               right: contentView.rightAnchor)
        marginViewLeft.widthAnchor.constraint(equalToConstant: marginWidth*0.55).isActive = true
        marginViewRight.widthAnchor.constraint(equalToConstant: marginWidth*0.45).isActive = true
        
        
        // 배경이 될 imageView를 쌓는다.
        imageView01.contentMode = .scaleAspectFit
        contentView.addSubview(imageView01)
        imageView01.anchor(top: contentView.topAnchor,
                           left: marginViewLeft.rightAnchor,
                           bottom: contentView.bottomAnchor,
                           right: marginViewRight.leftAnchor)
        ct_iv_height = imageView01.heightAnchor.constraint(equalToConstant: CGFloat(1))
        ct_iv_height?.isActive = true
        
        // 필기기능을 적용할 View(canvas)를 쌓는다. -> 최상위에 쌓여있는 상태
        contentView.addSubview(canvas)
        canvas.isUserInteractionEnabled = false
        canvas.alpha = 1
        canvas.backgroundColor = .clear
        canvas.anchor(top: imageView01.topAnchor,
                      left: imageView01.leftAnchor,
                      bottom: imageView01.bottomAnchor,
                      right: imageView01.rightAnchor)
        scrollView.isScrollEnabled = true
    }
    
    private func setupViews() {
        let canvasWidth = CGFloat(1024) //isLandscapeMode ? _parent.view.frame.height : _parent.view.frame.width
        
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            print("pad, do not resize image... make margin")
//        } else {
            for i in 0 ..< noteImageArr.count {
                resize(image: crop(image: noteImageArr[i]), canvasWidth: canvasWidth) { image in
                    self.noteImageArr[i] = image!
                }
            }
//        }
        
        if let convertedImage = mergeVerticallyImagesIntoImage(images: noteImageArr) {
        
            //calc content height
            let height = convertedImage.size.height * (contentView.frame.size.width - marginWidth) / convertedImage.size.width
            ct_iv_height?.constant = height
            imageView01.image = convertedImage
            
            self.canvas.mWidth = Int(imageView01.frame.size.width)
            self.canvas.mHeight = Int(height)
            
            self.isLoading = false
        }
    }
    
    private func setupWritingImplement() {
        let width = CGFloat(207)
        let bottomPadding = CGFloat(10)//UIScreen.main.bounds.size.height * 0.07
        let height = CGFloat(81)
        
        writingImplementToggleButton.setDimensions(height: height, width: width * 0.25)
        
        writingImplement.alpha = 1
        view.addSubview(writingImplement)
        writingImplement.setDimensions(height: height,
                                       width: width)
        writingImplementYPosition
            = writingImplement.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomPadding)
        writingImplementYPosition?.isActive = true
        
        writingImplementLeftConstraint = writingImplement.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -(width * 0.75))
        writingImplementLeftConstraint?.isActive = true
        
        view.addSubview(savingNoteButton)
        savingNoteButton.setDimensions(height: height, width: width * 0.25)
        savingNoteButton.anchor(right: view.rightAnchor)
        savingNoteYPosition
            = savingNoteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomPadding)
        savingNoteYPosition?.isActive = true
        savingNoteButton.alpha = 0
        
        view.addSubview(previousButton)
        previousButton.setDimensions(height: height * 0.45, width: width * 0.25)
        previousButton.anchor(bottom: view.bottomAnchor,
                              right: view.rightAnchor,
                              paddingBottom: bottomPadding + height - (height * 0.45))
        
        view.addSubview(nextButton)
        nextButton.setDimensions(height: height * 0.45, width: width * 0.25)
        nextButton.anchor(top: previousButton.bottomAnchor,
                          right: view.rightAnchor,
                          paddingTop: 10)
        
        let colorStackView = UIStackView(arrangedSubviews: [
            redButton,
            greenButton,
            blueButton,
            clearButton,
            writingImplementToggleButton
        ])
        
//        colorStackView.spacing = 4
        colorStackView.distribution = .equalSpacing
        writingImplement.addSubview(colorStackView)
        colorStackView.centerY(inView: writingImplement)
        colorStackView.anchor(left: writingImplement.leftAnchor,
                              bottom: writingImplement.bottomAnchor,
                              paddingLeft: 15,
                              width: width - 15,
                              height: 59)
    }
    
    func setupNoteTaking() {}
    
    func setupPIPView() {
        
        let pipHeight = Constant.height * 0.085
//
//        switch Constant.height {
//        case 896.0:
//            // pro max
//        case 812.0
//        //
//        }
//
        
        /*switch Constant.width {
        case 375.0:
            pipHeight = view.frame.height * 0.085
            break
        case 414.0:
            pipHeight = view.frame.height * 0.070
            break
        default:
            pipHeight = view.frame.height * 0.085
            break
        }*/
        
        
        view.addSubview(pipContainerView)
        pipContainerView.anchor(left: view.leftAnchor,
                                bottom: view.bottomAnchor,
                                right: view.rightAnchor,
                                height: pipHeight)
        
        pipVC = PIPController()
        guard let pipVC = self.pipVC else { return }
        
        //0713 - added by hp
        //영상 재생/일시정지 버튼 이슈관련 해결
        self.isPlayPIPVideo = pipVideoData?.isPlayPIP ?? false
        playPauseButton.setImage(UIImage(systemName: isPlayPIPVideo ? "pause" : "play.fill"), for: .normal)
        
        let pipContainerViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(pipContainerViewDidTap))
        pipContainerView.addGestureRecognizer(pipContainerViewTapGesture)
        pipContainerView.isUserInteractionEnabled = true
        pipContainerView.layer.borderColor = UIColor.gray.cgColor
        pipContainerView.layer.borderWidth = CGFloat(0.5)
        pipContainerView.addSubview(pipVC.view)
        pipVC.view.anchor(top:pipContainerView.topAnchor)
        pipVC.view.centerY(inView: pipContainerView)
        pipVC.view.setDimensions(height: pipHeight,
                                 width: pipHeight * 1.77)
        
        pipContainerView.addSubview(xButton)
        xButton.setDimensions(height: 25, width: 25)
        xButton.centerY(inView: pipContainerView)
        xButton.anchor(right: pipContainerView.rightAnchor,
                       paddingRight: 5)
        
        pipContainerView.addSubview(playPauseButton)
        playPauseButton.setDimensions(height: 25,
                                      width: 25)
        playPauseButton.centerY(inView: pipContainerView)
        playPauseButton.anchor(right: xButton.leftAnchor,
                       paddingRight: 20)
        
        pipContainerView.addSubview(lessonTitleLabel)
        lessonTitleLabel.anchor(left: pipContainerView.leftAnchor,
                                right: pipContainerView.rightAnchor,
                                paddingLeft: pipHeight * 1.77 + 5,
                                paddingRight: 80,
                                height: 17)
        lessonTitleLabel.center(inView: pipContainerView, yConstant: -10)
        lessonTitleLabel.text = pipVideoData?.videoTitle ?? ""
        
        pipContainerView.addSubview(teachernameLabel)
        teachernameLabel.anchor(left: lessonTitleLabel.leftAnchor,
                                height: 15)
        teachernameLabel.center(inView: pipContainerView, yConstant: 10)
        teachernameLabel.text = pipVideoData?.teacherName ?? ""
        
        //0713 - added by hp
        //필기도구 버튼 위로 이동
        let bottomPadding = CGFloat(pipHeight + 10)//UIScreen.main.bounds.size.height * 0.07 + 40
        writingImplementYPosition?.constant = -bottomPadding
        savingNoteYPosition?.constant = -bottomPadding
    }
    
    func dismissPIPView() {
        // PIP 모드가 실행중이였다면, 종료시킨다.
        pipVC?.player?.pause()
        pipVC?.player = nil
        pipVC?.removePeriodicTimeObserver()
        pipVC?.removeFromParent()
        pipVC = nil
    }
    
    // 가장 최근에 재생하던 Video로 돌아갑니다.
    // 그러므로 새로운 VC 인스턴스를 생성하지 않고 dismiss + videoLogic으로 처리합니다. 21.06.09 김우성
    @objc func pipContainerViewDidTap(_ sender: UITapGestureRecognizer) {
        
        setRemoveNotification()
        dismissSearchAfterVCOnPlayingPIP()
        // PIP에 이전영상에 대한 기록이 있으므로 화면을 새로 생성하지 않고 이전영상으로 돌아간다.
        // 재생된 시간은 전달해줘서 PIP AVPlayer가 진행된 부분부터 진행한다.
        // Delegation을 사용하지 말고, VideoController
        // 이전 영상의 Player를 조작해야하므로 Delegation을 사용한다.
        // Delegation Method를 통해 "player.seek()" 를 호출한다.
        // 이 때 seek 메소드의 파라미터로 "pipDataManager.currentPlayTime"을 입력한다.
    }
    
    func setRemoveNotification() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    /// PIP 영상이 실행되고 있는데, 이전 영상화면으로 돌아가고 싶은 경우 호출하는 메소드
    func dismissSearchAfterVCOnPlayingPIP() {
        // 1 PIP 영상을 제거한다.

        // 2 PIP-Player에서 현재까지 재생된 시간을 SingleTon 에 입력한다.
        let pipDataManager = PIPDataManager.shared
        guard let pipVC = self.pipVC else { return }
            
        pipVC.player?.pause()
        setRemoveNotification()
        // 3 싱글톤 객체 프로퍼티에 현재 재생된 시간을 CMTime으로 입력한다.
        pipDataManager.currentVideoCMTime = pipVC.currentVideoTime
        PIPDataManager.shared.isForcePlay = true
        
        dismissPIPView()
        dismiss(animated: false)
    }
    
    @objc func playPauseButtonDidTap() {
        isPlayPIPVideo = !isPlayPIPVideo
        
        //0713 - edited by hp
        if isPlayPIPVideo {
            pipVC?.player?.play()
            playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        } else {
            pipVC?.player?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc func xButtonDidTap() {
        
        pipVC?.player?.pause()
//        pipVC?.player = nil //감추기만 하고 없애지는 말자
        
        UIView.animate(withDuration: 0.22, animations: {
            self.pipContainerView.alpha = 0
        }, completion: nil)
        
        //0713 - added by hp
        //필기도구 버튼 아래로 이동
        let bottomPadding = CGFloat(10)//UIScreen.main.bounds.size.height * 0.07
        writingImplementYPosition?.constant = -bottomPadding
        savingNoteYPosition?.constant = -bottomPadding
    }
}

extension LessonNoteController {
    internal func didSaveNote() {
        print("LessonNoteController didSaveNote")
//        let alert = UIAlertController(title: nil, message: "저장 완료", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
        presentAlert(message: "저장 완료")
        alertSaveNote?()
    }
    func setSaveNoteResut(result: @escaping () -> ()) {
        alertSaveNote = result
    }
    
    internal func didSucceedReceiveNoteData(responseData: NoteResponse) {
        guard let data = responseData.data else { return }
        
        // 노트 이미지를 가져오기 위한 로직으로 한글 URL 변경작업을 한다.
        noteImageCount = data.sNotes.count
        if noteImageCount > 0 {
            getImageFromURL(noteData: data, index: 0)
        }
    }
    
    func loadLines(_ data: NoteData) {
        // MARK: 노트필기를 불러오는 로직

        // 서버에 저장되어 있는 좌표값을 canvas에 그릴 수 있는 형태로 변환한다.
        var previousNoteTakingData = [Line]()
        
        if let jsonData = data.sJson {
            if let strokes = jsonData.strokes { // "strokes" 에 LineData가 모두 있다.
                print("DEBUG: 불러온데이터 \(strokes)")
                for stroke in strokes {
                    // 3 개의 데이터
                    var xyPoints = [CGPoint]()
                    var penColorArr = [UIColor]()
                    // TODO: line 구조체 변경하여 color를 String으로 변경하면서 "color"를 사용할 예정이다.
                    let color = stroke.color // 핵사코드로 전달해준다.
                    var penColor = UIColor()

                    switch color {
                    case "#d82579":
                        penColor = .redPenColor
                    case "#a7c645":
                        penColor = .greenPenColor
                    case "#29b3df":
                        penColor = .bluePenColor
                    case "transparent":
                        penColor = .eraserColor
                    default:
                        penColor = .redPenColor
                    }
                    
//                    for (i, p) in strokes.enumerated() {
//                        // 색상을 고른다.
//
//                        // 셋중 하나를 고른 후 penColorArr에 추가한다.
//                        penColorArr.append(penColor)
//                    }
                    // x,y 좌표 값을 arr에 append 한다.
                    for (_, p) in stroke.points.enumerated() {
                        let xyPoint = CGPoint(x: CGFloat(p.x), y: CGFloat(p.y))
                        xyPoints.append(xyPoint)
                    }
                    //                        print("DEBUG: xyPoint데이터 \n\(xyPoints)")
                    let line = Line(strokeWidth: 2, color: penColor, points: xyPoints)
                    previousNoteTakingData.append(line)
                    //                        print("DEBUG: line데이터 \(line)")
                }
            }
        }
        
//        canvas.lines = previousNoteTakingData // 이전에 필기한 노트정보를 canvas 인스턴스에 전달한다.
        canvas.setLines(previousNoteTakingData)
    }
    
    private func getImageFromURL(noteData: NoteData, index: Int) {
        let convertedURL = makeStringKoreanEncoded("\(fileBaseURL)/" + "\(noteData.sNotes[index])")
        if let url = URL(string: convertedURL) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    if noteData.sNotes.count > index + 1 {
                        self.getImageFromURL(noteData: noteData, index: index + 1)
                    } else {
                        self.setupViews()
                        self.loadLines(noteData)
                    }
                    return
                }
                DispatchQueue.main.async {
                    let resultImage = UIImage(data: data)!
                    self.noteImageArr.append(resultImage)
                    
                    if noteData.sNotes.count > index + 1 {
                        self.getImageFromURL(noteData: noteData, index: index + 1)
                    } else {
                        self.setupViews()
                        self.loadLines(noteData)
                    }
                }
            }
            task.resume()
        } else {
            if noteData.sNotes.count > index + 1 {
                self.getImageFromURL(noteData: noteData, index: index + 1)
            } else {
                self.setupViews()
                self.loadLines(noteData)
            }
        }
    }
    
    private func getImageFromURL(noteString: [String], index: Int) {
        let convertedURL = makeStringKoreanEncoded("\(fileBaseURL)/" + "\(noteString[index])")
        if let url = URL(string: convertedURL) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    if noteString.count > index + 1 {
                        self.getImageFromURL(noteString: noteString, index: index + 1)
                    } else {
                        self.setupViews()
                    }
                    return
                }
                DispatchQueue.main.async {
                    let resultImage = UIImage(data: data)!
                    self.noteImageArr.append(resultImage)
                    
                    if noteString.count > index + 1 {
                        self.getImageFromURL(noteString: noteString, index: index + 1)
                    } else {
                        self.setupViews()
                    }
                }
            }
            task.resume()
        } else {
            if noteString.count > index + 1 {
                self.getImageFromURL(noteString: noteString, index: index + 1)
            } else {
                self.setupViews()
            }
        }
    }
    
    /*private func getImageFromURL(url: String, index: Int) {
        var resultImage = UIImage()
        
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    resultImage = UIImage(data: data)!
                    self.noteImageArr[index] = resultImage
                    self.setupViews()
                }
            }
            task.resume()
        }
    }*/
}

// MARK: - CanvasDelegate

extension LessonNoteController: CanvasDelegate {
    /// "02021. 동영상 노트 수정" (PATCH) 메소드 수행을 위한 메소드
    /// - 작성일시: 21.05.26
    /// - 기구현된 Web와 AOS 양식을 맞추기 위해 구현한 메소드
    /// - 이 외 연동 방법이 없다고 하여 구현함. 변경할 수 있다면, 노트필기 로직자체가 변경되는 것이 괜찮아보임
    func passLinePositionDataForLectureNoteController(points: [String], color: [UIColor]) {
        // "노트저장"을 클릭하면 이 메소드를 호출한다.
        
        // MARK: 노트필기를 작성하는 로직

        var tempArr = [String]() // x, y 값이 있는 arr를 임시로 저장할 배열
        var uiColor2StringColorArr = [String]()

        // color 배열에 있는 UIColor 데이터를 string으로 변경한다. 이유는 API 양식에 맞추기 위함이다.
        for (_, p) in color.enumerated() {
            var tempColorString = String()
            // 색상을 고른다.
            switch p {
            case .redPenColor:
                tempColorString = "#d82579"
            case .greenPenColor:
                tempColorString = "#a7c645"
            case .bluePenColor:
                tempColorString = "#29b3df"
            case .eraserColor:
                tempColorString = "transparent"
            default:
                tempColorString = "#d82579"
            }
            uiColor2StringColorArr.append(tempColorString)
        }
        
        // 1:n = color:(x,y) 관계이므로 하나의 색상에 많은 좌표가 포함된다.
        // 그러므로 하나의 String에 하나의 색상에 다수의 x,y좌표를 입력한다.
        for (i, p) in points.enumerated() {
            // "strokes" String에 x,y 좌표값과 color를 String으로 입력한다.
            let strokes: String
            if uiColor2StringColorArr[i] == "transparent" {
                strokes = "{\"points\":[\(String(p.dropLast(1)))],\"color\":\"\(uiColor2StringColorArr[i])\",\"size\":0.06772009,\"cap\":\"round\",\"join\":\"round\",\"miterLimit\":10}"
            } else {
                strokes = "{\"points\":[\(String(p.dropLast(1)))],\"color\":\"\(uiColor2StringColorArr[i])\",\"size\":0.004514673,\"cap\":\"round\",\"join\":\"round\",\"miterLimit\":10}"
            }

            
            // tempArr에 {points: 다수의 x,y좌표값들, color: 한개의 색상 ...} 의 구조 구성요소를 가지며
            // 이러한 구성요소를 배열의 형태로 저장하고 있다.
            tempArr.append(strokes)
        }
        
        // 하나의 String으로 하나의 Line을 표현했지만, 이것들을 다시 하나의 String으로 묶어서
        // API에 request해주어야 PATCH가 동작한다. (API가 이런식으로 되어있어서 어쩔 수 없음)
        var tempString = ""
        
        for (_, p) in tempArr.enumerated() {
            tempString += (p + ",")
        }

        // element의 끝에 "," 가 모두 추가되어 있기 때문에 마지막 ","는 제거한다.
        strokesString = String(tempString.dropLast(1))
    }
}
