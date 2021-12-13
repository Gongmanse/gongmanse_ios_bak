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
    
    var _selectedID: String? = "7"
    
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
        autoVideoLabel.textColor = .black
        
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
    }
    
    func getSearchVideoList() {
        
        searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                      grade: searchData.searchGrade,
                                      keyword: searchData.searchText,
                                      offset: "0",
                                      sortid: "7",
                                      limit: "20")
    }
    
    @objc func afterSearch(_ sender: Notification) {
        
        // 정렬 버튼을 다시 기본인 관련순으로 돌린 후 keyword다시 적용 후 api통신
        sortButtonTitle.setTitle("관련순 ▼", for: .normal)
        searchVideoVM.infinityBool = true
        searchVideoVM.requestVideoAPI(subject: searchData.searchSubjectNumber,
                                      grade: searchData.searchGrade,
                                      keyword: searchData.searchText,
                                      offset: "0",
                                      sortid: "7",
                                      limit: "20")
    }
    
    @objc func receiveFilter(_ sender: Notification) {
        
        let acceptInfo = sender.userInfo
        _selectedID = acceptInfo?["sortID"] as? String ?? nil
        
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
        popupVC._selectedID = _selectedID
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @objc func switchDidTap(_ sender: UISwitch) {
        // 자동재생이 활성화여부를 Boolean에 할당한다.
        autoVideoLabel.textColor = sender.isOn ? .black : .lightGray
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
        cell.teacher.text = "\(indexData.sTeacher!) 선생님"
        cell.rating.text = indexData.iRating?.withDouble() ?? "0.0"
        cell.chemistry.text = indexData.sSubject
        cell.chemistry.backgroundColor = UIColor(hex: "#\(indexData.sSubjectColor ?? "")")
        cell.videoImage.setImageUrl("\(fileBaseURL)/\(indexData.sThumbnail ?? "")")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if Constant.isLogin == false {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
            return
        }
        
        if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else {
            
            let autoPlayDataManager = AutoplayDataManager.shared
            autoPlayDataManager.isAutoPlay = autoPlaySwitch.isOn
            autoPlayDataManager.currentViewTitleView = "검색"
            autoPlayDataManager.videoDataList.removeAll()
            autoPlayDataManager.videoSeriesDataList.removeAll()
            autoPlayDataManager.currentIndex = -1
            autoPlayDataManager.currentSort = Int(_selectedID ?? "7") ?? 7
            autoPlayDataManager.currentSubjectNumber = Int(searchData.searchSubjectNumber ?? "0") ?? 0
            autoPlayDataManager.currentGrade = searchData.searchGrade ?? ""
            autoPlayDataManager.currentKeyword = searchData.searchText ?? ""
            
            if autoPlaySwitch.isOn {
                autoPlayDataManager.currentIndex = indexPath.row
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
                autoPlayDataManager.videoDataList.append(contentsOf: inputArr)
            }
            
            let receviedVideoID = self.searchVideoVM.responseVideoModel?.data[indexPath.row].id
            
            // 검색에서 왔다는 것을 알려주는 Boolean값
            if let comeFromSearchVC = self.comeFromSearchVC {
                
                //0711 - added by hp - pip
                pipDelegate?.serachAfterVCPIPViewDismiss()
                
                let vc = VideoController(isPlayPIP: false)
                
                vc.id = receviedVideoID
                
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
                return
            }
            
            
            //0713 - added by hp
            pipDelegate?.serachAfterVCPIPViewDismiss()
            VideoDataManager.shared.isFirstPlayVideo = false
            
            //video->lectureplaylist->video 와 같은 현상을 방지하기 위한
            let vc = self.presentingViewController as! VideoController
            vc.isFullScreenMode = false
            self.dismiss(animated: false) {
                vc.id = receviedVideoID
                vc.keyword = self.searchData.searchText
                vc.configureDataAndNoti(true)
            }
            
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
                                              sortid: _selectedID,
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
        return 20
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
            let strCount = subString.withCommas()
            let allString = "총 \(strCount)개"
            
            self.numberOfLesson.attributedText = allString.convertStringColor(allString, strCount, .mainOrange)
            self.collectionView.reloadData()
        }
    }
}
