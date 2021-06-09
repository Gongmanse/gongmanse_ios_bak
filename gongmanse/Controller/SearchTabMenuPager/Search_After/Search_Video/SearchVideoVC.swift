//  Created by 김우성 on 2021/03/11.

import UIKit
/**
 // 중간 텍스트 글자 색 변경예정
 
 */
private let cellId = "SearchVideoCell"

protocol SearchVideoVCDelegate: AnyObject {
    func serachAfterVCPIPViewDismiss()
}

class SearchVideoVC: UIViewController {
    
    //MARK: - Properties
    
    weak var pipDelegate: SearchVideoVCDelegate?
    
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
        
        if Constant.isLogin {
            
            // PIP를 dismiss한다.
            pipDelegate?.serachAfterVCPIPViewDismiss()
            
            let vc = VideoController()
            let receviedVideoID = self.searchVideoVM.responseVideoModel?.data[indexPath.row].id
            let videoID = receviedVideoID
            vc.id = videoID
            
            // "영상 > 검색 > 영상" 화면이동으로 왔음을 판별하기 위해 id값을 싱글톤에 입력합니다.
            // "currentVideoID" 와 "previousVideoID"를 비교하여 판별합니다.
            let pipDataManager = PIPDataManager.shared
            pipDataManager.currentVideoID = videoID
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        } else {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
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
