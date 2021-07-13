//  Created by 김우성 on 2021/03/11.
import AVFoundation
import UIKit
/**
 // 중간 텍스트 글자 색 변경예정
 
 */
private let cellId = "SearchVideoCell"

protocol SearchVideoVCDelegate: AnyObject {
    func serachAfterVCPIPViewDismiss()
}

protocol VideoVCDelegateSearchVideoVC: AnyObject {
    func removeAVPlayerTokenVideoVC()
}

class SearchVideoVC: UIViewController {
    
    
    var comeFromSearchVC: Bool?
    
    //MARK: - Properties
    
    weak var pipDelegate: SearchVideoVCDelegate?
    weak var videoRemoveTokenDelegate: VideoVCDelegateSearchVideoVC?
    
    var isAutoPlay: Bool = false
    
    var pageIndex: Int!
    let searchVideoVM = SearchVideoViewModel()
    
    // singleton
    lazy var searchData = SearchData.shared
    
    //MARK: IBOutlet
    @IBOutlet weak var numberOfLesson: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    @IBOutlet weak var sortButtonTitle: UIButton!
    @IBOutlet weak var autoVideoLabel: UILabel!
    
    var detailVideo: DetailSecondVideoResponse?
    var detailData: DetailVideoInput?
    var detailVideoData: DetailSecondVideoData?
    
    // 상담목록이 없습니다.
    private let consultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rgb(red: 164, green: 164, blue: 164)
        label.textAlignment = .center
        label.font = .appBoldFontWith(size: 16)
        label.text = "검색 내역이 없습니다."
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
    
    //MARK: - Lifecycle
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        emptyStackView.isHidden = true
        collectionView.isHidden = false
        
        if searchVideoVM.responseVideoModel?.data.count == 0{
            
            emptyStackView.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromJsonVideo()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchVideoVM.reloadDelegate = self
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        autoVideoLabel.font = .appBoldFontWith(size: 13.5)
        numberOfLesson.font = .appBoldFontWith(size: 16)
        sortButtonTitle.titleLabel?.font = .appBoldFontWith(size: 13)
        
        // UISwitch UI 속성 설정
        autoPlaySwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        autoPlaySwitch.onTintColor = .mainOrange
        
        // 필터링하고 받는 곳
        NotificationCenter.default.addObserver(self, selector: #selector(receiveFilter(_:)), name: .searchAfterVideoNoti, object: nil)
        
        // 검색 후 검색되면 신호받는 곳 :
        NotificationCenter.default.addObserver(self, selector: #selector(afterSearch(_:)), name: .searchAfterSearchNoti, object: nil)
        
        // 초기 비디오값 get
        getSearchVideoList()
        
        view.addSubview(emptyStackView)
        emptyStackView.addArrangedSubview(emptyAlert)
        emptyStackView.addArrangedSubview(consultLabel)
        
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        autoPlaySwitch.addTarget(self, action: #selector(switchDidTap(_:)), for: .valueChanged)
        AutoplayDataManager.shared.isAutoplaySearchTab = true
    }
    
    func getDataFromJsonVideo() {
        
        //guard let videoId = data?.video_id else { return }
        
        if let url = URL(string: "https://api.gongmanse.com/v/video/details?video_id=9316&token=\(Constant.token)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(DetailSecondVideoResponse.self, from: data) {
                    //print(json.data)
                    self.detailVideo = json
                    self.detailVideoData = json.data
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }.resume()
        }
    }
    
    func getSearchVideoList() {
        
        searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                      grade: searchData.searchGrade,
                                      keyword: searchData.searchText,
                                      offset: "0",
                                      sortid: "4",
                                      limit: "20")
    }
    
    @objc func afterSearch(_ sender: Notification) {
        
        // 정렬 버튼을 다시 기본인 최신순으로 돌린 후 keyword다시 적용 후 api통신
        sortButtonTitle.setTitle("최신순 ▼", for: .normal)
        searchVideoVM.infinityBool = true
        searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                      grade: searchData.searchGrade,
                                      keyword: searchData.searchText,
                                      offset: "0",
                                      sortid: "4",
                                      limit: "20")
    }
    
    @objc func receiveFilter(_ sender: Notification) {
        
        let acceptInfo = sender.userInfo
        
        sortButtonTitle.setTitle(acceptInfo?["sort"] as? String, for: .normal)
        
        searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                      grade: searchData.searchGrade,
                                      keyword: searchData.searchText,
                                      offset: "0",
                                      sortid: acceptInfo?["sortID"] as? String ?? nil,
                                      limit: "20")
    }
    
    
    //MARK: - Actions
    
    // 필터링 기능 : BottomPopup
    // TODO: BottomPopup 새로운 Controller로 설정할 것
    // 평점순(Default), 최신순, 이름순, 과목순 
    @IBAction func handleFilter(_ sender: Any) {
        let popupVC = SearchAfterBottomPopup()
        popupVC.selectFilterState = .videoDicionary
        
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @objc func switchDidTap(_ sender: UISwitch) {
        // 자동재생이 활성화여부를 Boolean에 할당한다.
        self.isAutoPlay = sender.isOn
        
        let autoDataManager = AutoplayDataManager.shared
        autoDataManager.isAutoplaySearchTab = sender.isOn
    }
}


//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchVideoVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return searchVideoVM.responseVideoModel?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchVideoCell
        
        guard let indexData = searchVideoVM.responseVideoModel?.data[indexPath.row] else { return UICollectionViewCell() }
        
        cell.title.text = indexData.sTitle
        cell.teacher.text = indexData.sTeacher
        cell.rating.text = indexData.iRating
        cell.chemistry.text = indexData.sSubject
        cell.chemistry.backgroundColor = UIColor(hex: "#\(indexData.sSubjectColor ?? "")")
        cell.videoImage.setImageUrl("\(fileBaseURL)/\(indexData.sThumbnail ?? "")")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }
        
        guard let indexVideoData = detailVideo?.data else { return }
        
        if indexVideoData.source_url == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else if indexVideoData.source_url != nil {
            // 검색에서 왔다는 것을 알려주는 Boolean값
            if let comeFromSearchVC = self.comeFromSearchVC {

                // 자동재생인 경우 아래 코드블럭이 실행된다.
                if self.isAutoPlay {
                    let autoPlayDataManager = AutoplayDataManager.shared
                    
                    /// 최종 넣어야하는 데이터모델
                    var inputArr = [VideoModels]()
                    
                    /// 태욱's 데이터 저장위치
                    guard let vm = searchVideoVM.responseVideoModel else { return }
                    
                    // 태욱's Model -> 현수's Model
                    for dataIndex in vm.data.indices {
                        
                        // 태욱씨가 구성한 Decodable 데이터
                        let receivedData = searchVideoVM.responseVideoModel?.data[dataIndex]
                        
                        // 현수씨가 구성한 Decodable 데이터
                        let videoModels = VideoModels(seriesId: receivedData?.iSeriesId,
                                                      videoId: receivedData?.id,
                                                      title: receivedData?.sTitle,
                                                      tags: receivedData?.sTags,
                                                      teacherName: receivedData?.sTeacher,
                                                      thumbnail: receivedData?.sThumbnail,
                                                      subject: receivedData?.sSubject,
                                                      subjectColor: receivedData?.sSubjectColor,
                                                      unit: "TEST",
                                                      rating: receivedData?.iRating,
                                                      isRecommended: "추천",
                                                      registrationDate: "등록한 날짜",
                                                      modifiedDate: "수정하 날짜",
                                                      totalRows: "1000")
                        inputArr.append(videoModels)
                    }
                    
                    // 1) 바로 싱글톤 데이터에 추가한다.(데이터 == 현재 보여주고있는 cell의 데이터 20개)
                    let inputData = VideoInput(body: inputArr)
                    autoPlayDataManager.videoDataInSearchTab = inputData
                    autoPlayDataManager.currentViewTitleView = "검색"
                    
                    // 2) Switch 값을 넘겨줘야 한다.
                    // -> switchDidTap 에서 AutoPlayDataManager 싱글톤으로 보내고 있음
                    
                    // 3) AutoPlayerDataManager에 viewTitle값을 변경해준다.
                }
                
                //0711 - added by hp - pip
                pipDelegate?.serachAfterVCPIPViewDismiss()
                
                let vc = VideoController(isPlayPIP: false)
                let receviedVideoID = self.searchVideoVM.responseVideoModel?.data[indexPath.row].id
                vc.id = receviedVideoID
                
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
                return
            }
            
            
            //0713 - added by hp
            pipDelegate?.serachAfterVCPIPViewDismiss()

            /**
             검색결과 화면에서 영상을 클릭할 때, rootView를 초기화하는 이유
             - 영상 > 검색결과 > 영상
                이런식으로 넘어오다보니 영상관련 Controller 가 너무 많아져서 메모리 관리가 어려움
             - 그래서 rootView를 변경하는 식으로 구현
             */
            
            //  UIApplication 에서 화면전환을 한다,
            guard let topVC = UIApplication.shared.topViewController() else { return }
            /* 컨트롤러에 남아있는 Notification들을 제거한다. */
            // "VideoController" 에 남아있는 영상 토큰을 제거하기 위한 post
            NotificationCenter.default.post(name: .removeVideoVCToken, object: nil)
            
            // pip에 남아있는 영상 토큰을 제거하기 위한 removeObsercer
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

            let autoDataManager = AutoplayDataManager.shared
//            autoDataManager.currentViewTitleView = ""
            autoDataManager.isAutoplayMainSubject = false
            autoDataManager.isAutoplayScience = false
            autoDataManager.isAutoplaySocialStudy = false
            autoDataManager.isAutoplayOtherSubjects = false

            // 싱글톤 객체에 들어간 데이터를 초기화한다.
//            let pipDataManager = PIPDataManager.shared
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
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            let mainTabVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
            
            // TODO: video ID를 받아서 할당하고, PIPDataManager의 값들을 초기화한다.
            
            topVC.changeRootViewController(mainTabVC) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabVC2 = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                mainTabVC2.modalPresentationStyle = .fullScreen
                let vc = VideoController()
                vc.modalPresentationStyle = .fullScreen
                
                let receviedVideoID = self.searchVideoVM.responseVideoModel?.data[indexPath.row].id

                /**
                 영상을 틀기 위해 "ID" 값을 서브스크립트로 전달한다.
                 동시에 URL도 전달해야 VideoDataManager에서 URL의 PIP영상의 순서가 꼬이지 않는다.
                 pip는 URL로 접근하고있고, VideoController는 ID로 영상을 송출하고 있기 때문이다.
                 */
                
                vc.id = receviedVideoID
                vc.keyword = self.searchData.searchText
                
                let layout = UICollectionViewFlowLayout()
                vc.collectionViewLayout = layout
                vc.modalPresentationStyle = .fullScreen
                
//                let loginVC = LoginVC()
                mainTabVC.present(mainTabVC2, animated: false) {
                    mainTabVC2.present(vc, animated: true)
                }
                
            }
            
//            topVC.present(mainTabVC, animated: true) {
//                let vc = VideoController()
//
//                let receviedVideoID = self.searchVideoVM.responseVideoModel?.data[indexPath.row].id
//
//                vc.id = receviedVideoID  // dummy Data
//
//                let layout = UICollectionViewFlowLayout()
//                vc.collectionViewLayout = layout
//                vc.modalPresentationStyle = .fullScreen
//
//                mainTabVC.present(vc, animated: false)
//            }
            
            //            // PIP를 dismiss한다.
            //            pipDelegate?.serachAfterVCPIPViewDismiss()
            //
            //            let vc = VideoController()
            //            let receviedVideoID = self.searchVideoVM.responseVideoModel?.data[indexPath.row].id
            //            let videoID = receviedVideoID
            //            vc.id = videoID
            //
            //            // "영상 > 검색 > 영상" 화면이동으로 왔음을 판별하기 위해 id값을 싱글톤에 입력합니다.
            //            // "currentVideoID" 와 "previousVideoID"를 비교하여 판별합니다.
            //            let pipDataManager = PIPDataManager.shared
            //            pipDataManager.currentVideoID = videoID
            //
            //
            //            vc.modalPresentationStyle = .fullScreen
            //            present(vc, animated: true)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellCount = searchVideoVM.responseVideoModel?.data.count  else { return }

        if indexPath.row == cellCount - 1 {
            
//            if searchVideoVM.allIntiniteScroll {
//                searchVideoVM.infinityBool = true
//                searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
//                                              grade: searchData.searchGrade,
//                                              keyword: searchData.searchText,
//                                              offset: "",
//                                              sortid: "4",
//                                              limit: "20")
//            }
            if searchVideoVM.infinityBool {
                searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                              grade: searchData.searchGrade,
                                              keyword: searchData.searchText,
                                              offset: "",
                                              sortid: "4",
                                              limit: "20")
            }
            
        }
    }
    
}


//MARK: - UICollectionViewFlowLayout

extension SearchVideoVC: UICollectionViewDelegateFlowLayout {
    
    // cell 간격을 설정하는 메소드(가로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    // cell 간격을 설정하는 메소드(세로)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    // Cell의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 80)
    }
    
}

extension SearchVideoVC: CollectionReloadData {
    
    func reloadCollection() {
        DispatchQueue.main.async {
            
            let subString = self.searchVideoVM.responseVideoModel?.totalNum ?? "0"
            let allString = "총 \(subString)개"
            self.numberOfLesson.attributedText = allString.convertStringColor(allString, subString, .mainOrange)
            self.collectionView.reloadData()
        }
    }
}
